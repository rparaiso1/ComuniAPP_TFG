"""
Router de administración — panel de control para admins y presidentes.

Endpoints:
  GET  /admin/dashboard          — estadísticas globales
  GET  /admin/users              — listar usuarios
  GET  /admin/users/{id}         — detalle de usuario
  PUT  /admin/users/{id}/role    — cambiar rol
  PUT  /admin/users/{id}/toggle  — activar/desactivar
  PUT  /admin/users/{id}/reset-password — resetear contraseña
  POST /admin/import/users       — importar usuarios desde CSV/Excel
  POST /admin/import/zones       — importar zonas desde CSV/Excel
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Request, UploadFile, File
from sqlalchemy.orm import Session
from typing import Optional, List
from uuid import UUID
import csv
import io
import logging
import re

from app.core.database import get_db
from app.core.deps import get_current_admin_or_president, get_filtered_org_ids, get_active_org_id
from app.core.config import settings
from app.core.security_utils import InputSanitizer
from app.models.user import User, UserRole
from app.models.user_organization import UserOrganization
from app.services.admin_service import AdminService
from app.schemas.admin import AdminDashboard, ChangeRoleRequest, ResetPasswordRequest, ImportResult

router = APIRouter()
logger = logging.getLogger(__name__)


def _prevent_president_modifying_admin(db: Session, caller: User, target_user_id: UUID, org_ids: List[UUID]):
    """Prevent a PRESIDENT from modifying an ADMIN user (toggle, reset-password)."""
    # Check if caller is NOT an admin themselves
    caller_is_admin = db.query(UserOrganization).filter(
        UserOrganization.user_id == caller.id,
        UserOrganization.role == UserRole.ADMIN,
        UserOrganization.is_active == True,
    ).first()
    if caller_is_admin:
        return  # Admins can modify anyone
    
    # Check if target is an admin in any of these orgs
    target_is_admin = db.query(UserOrganization).filter(
        UserOrganization.user_id == target_user_id,
        UserOrganization.organization_id.in_(org_ids),
        UserOrganization.role == UserRole.ADMIN,
        UserOrganization.is_active == True,
    ).first()
    if target_is_admin:
        raise HTTPException(
            status_code=403,
            detail="Un presidente no puede modificar a un administrador",
        )


# ── Endpoints ────────────────────────────────────────────────────────────────────
@router.get("/dashboard", response_model=AdminDashboard)
def admin_dashboard(
    request: Request,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Dashboard con estadísticas globales (admin/presidente)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    data = AdminService(db).dashboard(org_ids)
    return AdminDashboard(**data)


@router.get("/users")
def list_users(
    request: Request,
    role: Optional[str] = None,
    active_only: bool = False,
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=50, le=500),
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Listar usuarios de la organización (admin/presidente)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    return AdminService(db).list_users(org_ids, role, active_only, skip=skip, limit=limit)


@router.get("/users/{user_id}")
def get_user(
    request: Request,
    user_id: UUID,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Obtener detalle de un usuario."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    return AdminService(db).get_user(user_id, org_ids)


@router.put("/users/{user_id}/role")
def change_user_role(
    request: Request,
    user_id: UUID,
    body: ChangeRoleRequest,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Cambiar el rol de un usuario."""
    if str(user_id) == str(current_user.id):
        raise HTTPException(status_code=400, detail="No puedes cambiar tu propio rol")

    # Solo un ADMIN puede asignar el rol ADMIN
    if body.role.upper() == "ADMIN":
        from app.models.user_organization import UserOrganization as UO
        caller_is_admin = db.query(UO).filter(
            UO.user_id == current_user.id,
            UO.role == "ADMIN",
            UO.is_active == True,
        ).first()
        if not caller_is_admin:
            raise HTTPException(
                status_code=403,
                detail="Solo un administrador puede asignar el rol ADMIN",
            )

    org_ids = get_filtered_org_ids(request, db, current_user)

    # Verify target user belongs to caller's organizations
    target_in_org = db.query(UserOrganization).filter(
        UserOrganization.user_id == user_id,
        UserOrganization.organization_id.in_(org_ids),
        UserOrganization.is_active == True,
    ).first()
    if not target_in_org:
        raise HTTPException(status_code=404, detail="Usuario no encontrado en tus organizaciones")

    return AdminService(db).update_user_role(user_id, body.role, org_ids)


@router.put("/users/{user_id}/toggle")
def toggle_user(
    request: Request,
    user_id: UUID,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Activar/desactivar un usuario."""
    if str(user_id) == str(current_user.id):
        raise HTTPException(status_code=400, detail="No puedes desactivarte a ti mismo")
    # President cannot toggle admin users
    org_ids = get_filtered_org_ids(request, db, current_user)
    _prevent_president_modifying_admin(db, current_user, user_id, org_ids)
    return AdminService(db).toggle_user_active(user_id, org_ids)


@router.put("/users/{user_id}/reset-password")
def reset_password(
    request: Request,
    user_id: UUID,
    body: ResetPasswordRequest,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Resetear la contraseña de un usuario."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    # President cannot reset admin passwords
    _prevent_president_modifying_admin(db, current_user, user_id, org_ids)
    AdminService(db).reset_user_password(user_id, body.new_password, org_ids)
    return {"success": True, "message": "Contraseña actualizada correctamente"}


# ── Importación masiva ───────────────────────────────────────────


def _parse_csv_content(content: bytes) -> list[dict]:
    """Parsear contenido CSV/texto a lista de diccionarios."""
    text = content.decode('utf-8-sig')  # utf-8-sig para manejar BOM
    reader = csv.DictReader(io.StringIO(text), delimiter=';')
    # Intentar con coma si no hay columnas con punto y coma
    rows = list(reader)
    if rows and len(rows[0]) <= 1:
        reader = csv.DictReader(io.StringIO(text), delimiter=',')
        rows = list(reader)
    return rows


def _parse_excel_content(content: bytes) -> list[dict]:
    """Parsear contenido Excel (.xlsx) a lista de diccionarios."""
    try:
        import openpyxl
    except ImportError:
        raise HTTPException(
            status_code=400,
            detail="Para importar Excel (.xlsx), instale openpyxl: pip install openpyxl"
        )
    wb = openpyxl.load_workbook(io.BytesIO(content), read_only=True)
    ws = wb.active
    rows_iter = ws.iter_rows(values_only=True)
    headers = [str(h).strip().lower() if h else '' for h in next(rows_iter)]
    rows = []
    for row in rows_iter:
        row_dict = {}
        for i, val in enumerate(row):
            if i < len(headers) and headers[i]:
                row_dict[headers[i]] = str(val).strip() if val is not None else ''
        if any(row_dict.values()):
            rows.append(row_dict)
    wb.close()
    return rows


def _parse_file(content: bytes, filename: str) -> list[dict]:
    """Detectar formato y parsear el archivo."""
    name_lower = filename.lower()
    if name_lower.endswith('.xlsx') or name_lower.endswith('.xls'):
        return _parse_excel_content(content)
    else:
        return _parse_csv_content(content)


@router.post("/import/users", response_model=ImportResult)
async def import_users(
    request: Request,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """
    Importar usuarios desde archivo CSV o Excel (.xlsx).
    
    Columnas esperadas:
      - email (obligatorio)
      - nombre / full_name / name (obligatorio)
      - rol / role (ADMIN, PRESIDENT, NEIGHBOR) — por defecto NEIGHBOR
      - telefono / phone (opcional)
      - vivienda / dwelling (opcional)
      - password / contraseña (opcional, por defecto: configurado en settings)
    """
    org_id = get_active_org_id(request, db, current_user)

    content = await file.read()
    try:
        rows = _parse_file(content, file.filename or 'data.csv')
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error al leer el archivo: {str(e)}")

    if not rows:
        raise HTTPException(status_code=400, detail="El archivo está vacío o no tiene el formato correcto")

    imported = 0
    errors = []

    for i, row in enumerate(rows, start=2):
        # Normalizar claves (minúsculas, sin espacios)
        norm = {k.lower().strip(): v for k, v in row.items()}

        email = norm.get('email', '').strip()
        # Validar formato email básico
        if email and not re.match(r'^[^@\s]+@[^@\s]+\.[^@\s]+$', email):
            errors.append(f"Fila {i}: email '{email}' con formato inválido, omitida")
            continue
        name = (norm.get('nombre', '') or norm.get('full_name', '') or norm.get('name', '')).strip()
        name = InputSanitizer.sanitize_string(name, max_length=255)
        role = (norm.get('rol', '') or norm.get('role', '')).strip().upper() or 'NEIGHBOR'
        phone = (norm.get('telefono', '') or norm.get('phone', '')).strip() or None
        dwelling = (norm.get('vivienda', '') or norm.get('dwelling', '')).strip() or None
        password = (norm.get('password', '') or norm.get('contraseña', '') or norm.get('contrasena', '')).strip() or settings.DEFAULT_IMPORT_PASSWORD

        # Validar política de contraseña si se especificó en el CSV
        if password != settings.DEFAULT_IMPORT_PASSWORD:
            from app.schemas.validators import validate_password_strength
            try:
                validate_password_strength(password)
            except ValueError as ve:
                errors.append(f"Fila {i} ({email}): contraseña inválida — {ve}, se asigna la contraseña por defecto")
                password = settings.DEFAULT_IMPORT_PASSWORD

        if not email:
            errors.append(f"Fila {i}: email vacío, omitida")
            continue
        if not name:
            errors.append(f"Fila {i}: nombre vacío para {email}, omitida")
            continue
        if role not in ('ADMIN', 'PRESIDENT', 'NEIGHBOR'):
            errors.append(f"Fila {i}: rol '{role}' inválido para {email}, se asigna NEIGHBOR")
            role = 'NEIGHBOR'

        # PRESIDENT cannot assign ADMIN role — only true ADMIN users can
        caller_is_admin = db.query(UserOrganization).filter(
            UserOrganization.user_id == current_user.id,
            UserOrganization.role == UserRole.ADMIN,
            UserOrganization.is_active == True,
        ).first() is not None
        if role == 'ADMIN' and not caller_is_admin:
            errors.append(f"Fila {i} ({email}): Solo un ADMIN puede crear usuarios con rol ADMIN, se asigna PRESIDENT")
            role = 'PRESIDENT'

        try:
            with db.begin_nested():
                AdminService(db).import_user(
                    email=email,
                    full_name=name,
                    role=role,
                    phone=phone,
                    dwelling=dwelling,
                    password=password,
                    organization_id=org_id,
                )
            imported += 1
        except Exception as e:
            errors.append(f"Fila {i} ({email}): {str(e)}")

    db.commit()
    logger.info(f"Import users: {imported}/{len(rows)} imported by {current_user.email}")
    return ImportResult(total_rows=len(rows), imported=imported, errors=errors)


@router.post("/import/zones", response_model=ImportResult)
async def import_zones(
    request: Request,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """
    Importar zonas comunes desde archivo CSV o Excel (.xlsx).
    
    Columnas esperadas:
      - nombre / name (obligatorio)
      - tipo / zone_type / type (obligatorio: pool, court, room, gym, garden, etc.)
      - descripcion / description (opcional)
      - capacidad / max_capacity / capacity (opcional, número)
      - requiere_aprobacion / requires_approval (opcional: si/sí/true/1)
    """
    org_id = get_active_org_id(request, db, current_user)

    content = await file.read()
    try:
        rows = _parse_file(content, file.filename or 'data.csv')
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error al leer el archivo: {str(e)}")

    if not rows:
        raise HTTPException(status_code=400, detail="El archivo está vacío o no tiene el formato correcto")

    imported = 0
    errors = []

    for i, row in enumerate(rows, start=2):
        norm = {k.lower().strip(): v for k, v in row.items()}

        name = (norm.get('nombre', '') or norm.get('name', '')).strip()
        zone_type = (norm.get('tipo', '') or norm.get('zone_type', '') or norm.get('type', '')).strip().lower()
        description = (norm.get('descripcion', '') or norm.get('description', '')).strip() or None
        capacity_str = (norm.get('capacidad', '') or norm.get('max_capacity', '') or norm.get('capacity', '')).strip()
        requires_approval_str = (norm.get('requiere_aprobacion', '') or norm.get('requires_approval', '')).strip().lower()

        if not name:
            errors.append(f"Fila {i}: nombre vacío, omitida")
            continue
        if not zone_type:
            errors.append(f"Fila {i}: tipo vacío para '{name}', omitida")
            continue

        max_capacity = None
        if capacity_str:
            try:
                max_capacity = int(float(capacity_str))
            except ValueError:
                errors.append(f"Fila {i}: capacidad '{capacity_str}' no es un número para '{name}'")

        requires_approval = requires_approval_str in ('si', 'sí', 'true', '1', 'yes')

        try:
            with db.begin_nested():
                AdminService(db).import_zone(
                    name=name,
                    zone_type=zone_type,
                    description=description,
                    max_capacity=max_capacity,
                    requires_approval=requires_approval,
                    organization_id=org_id,
                )
            imported += 1
        except Exception as e:
            errors.append(f"Fila {i} ({name}): {str(e)}")

    db.commit()
    logger.info(f"Import zones: {imported}/{len(rows)} imported by {current_user.email}")
    return ImportResult(total_rows=len(rows), imported=imported, errors=errors)


# ── Exportación de datos ─────────────────────────────────────────────

@router.get("/export/{resource}")
def export_data(
    request: Request,
    resource: str,
    format: str = "csv",
    max_rows: int = Query(default=10000, ge=1, le=50000),
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """
    Exportar datos en CSV o Excel.
    Recursos: users, bookings, incidents, documents, zones
    """
    from fastapi.responses import StreamingResponse
    import io

    org_ids = get_filtered_org_ids(request, db, current_user)

    format = (format or "csv").lower()
    if format not in {"csv", "json"}:
        raise HTTPException(status_code=400, detail="Formato no soportado. Use 'csv' o 'json'")

    if resource == "users":
        data = AdminService(db).list_users(org_ids, limit=max_rows)
        headers = ["email", "full_name", "phone", "dwelling", "role", "is_active", "organization_id"]
    elif resource == "bookings":
        from app.services.booking_service import BookingService
        bookings = BookingService(db).list(org_ids, limit=max_rows)
        data = []
        for b in bookings:
            data.append({
                "id": str(b.id),
                "zone_name": b.zone.name if b.zone else "",
                "user_name": b.user.full_name if b.user else "",
                "start_time": b.start_time.isoformat() if b.start_time else "",
                "end_time": b.end_time.isoformat() if b.end_time else "",
                "status": b.status.value if hasattr(b.status, 'value') else str(b.status),
                "notes": b.notes or "",
            })
        headers = ["id", "zone_name", "user_name", "start_time", "end_time", "status", "notes"]
    elif resource == "incidents":
        from app.services.incident_service import IncidentService
        incidents = IncidentService(db).list(org_ids, limit=max_rows)
        data = []
        for i in incidents:
            data.append({
                "id": str(i.id),
                "title": i.title, "description": i.description,
                "priority": i.priority.value if hasattr(i.priority, 'value') else str(i.priority),
                "status": i.status.value if hasattr(i.status, 'value') else str(i.status),
                "reporter_name": i.reporter.full_name if i.reporter else "",
                "location": i.location or "",
                "created_at": i.created_at.isoformat() if i.created_at else "",
            })
        headers = ["id", "title", "description", "priority", "status", "reporter_name", "location", "created_at"]
    elif resource == "documents":
        from app.services.document_service import DocumentService
        docs = DocumentService(db).list(org_ids, is_admin=True, limit=max_rows)
        data = []
        for d in docs:
            data.append({
                "id": str(d.id),
                "title": d.title, "category": d.category or "",
                "approval_status": d.approval_status,
                "uploaded_by": d.uploaded_by.full_name if d.uploaded_by else "",
                "created_at": d.created_at.isoformat() if d.created_at else "",
            })
        headers = ["id", "title", "category", "approval_status", "uploaded_by", "created_at"]
    elif resource == "zones":
        from app.services.zone_service import ZoneService
        zones = ZoneService(db).list(org_ids, active_only=False, limit=max_rows)
        data = []
        for z in zones:
            data.append({
                "id": str(z.id),
                "name": z.name,
                "zone_type": z.zone_type,
                "description": z.description or "",
                "max_booking_hours": z.max_booking_hours,
                "advance_booking_days": z.advance_booking_days,
                "max_bookings_per_user_day": z.max_bookings_per_user_day,
                "requires_approval": z.requires_approval,
                "is_active": z.is_active,
            })
        headers = [
            "id", "name", "zone_type", "description",
            "max_booking_hours", "advance_booking_days", "max_bookings_per_user_day",
            "requires_approval", "is_active",
        ]
    else:
        raise HTTPException(status_code=400, detail=f"Recurso '{resource}' no soportado")

    # Generate output
    if format == "json":
        return data if isinstance(data, list) else list(data)

    # Generate CSV
    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=headers, delimiter=";", extrasaction="ignore")
    writer.writeheader()
    for row in data:
        writer.writerow({k: row.get(k, "") for k in headers})

    output.seek(0)
    filename = f"{resource}_export.csv"
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename={filename}"},
    )

