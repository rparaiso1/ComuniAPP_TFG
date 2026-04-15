"""
Servicio de administración — gestión de usuarios, dashboard admin, zonas, documentos.
"""
from sqlalchemy.orm import Session
from sqlalchemy import func, case
from uuid import UUID
from typing import List, Optional

from app.core.security import get_password_hash
from app.models.user import User, UserRole
from app.models.user_organization import UserOrganization
from app.models.organization import Organization
from app.models.booking import Booking, BookingStatus
from app.models.incident import Incident, IncidentStatus
from app.models.document import Document, DocumentApprovalStatus
from app.models.post import Post
from app.models.invitation import Invitation, InvitationStatus
from app.models.zone import Zone
from app.models.notification import Notification
from app.core.exceptions import ServiceError, NotFoundError


class AdminService:
    """Operaciones administrativas para el panel de control."""

    def __init__(self, db: Session):
        self.db = db

    # ── Dashboard global ─────────────────────────────────────────────

    def dashboard(self, org_ids: List[UUID]) -> dict:
        """Estadísticas globales para el admin dashboard (optimizado: 4 queries)."""
        if not org_ids:
            return self._empty_dashboard()

        # Query 1: usuarios (total + activos) en una sola query
        user_stats = (
            self.db.query(
                func.count(UserOrganization.user_id.distinct()).label("total"),
                func.count(
                    case(
                        (User.is_active == True, UserOrganization.user_id),  # noqa: E712
                    ).distinct()
                ).label("active"),
            )
            .join(User, User.id == UserOrganization.user_id)
            .filter(
                UserOrganization.organization_id.in_(org_ids),
                UserOrganization.is_active == True,  # noqa: E712
            )
            .first()
        )

        # Query 2: bookings (total + pending) en una sola query
        booking_stats = (
            self.db.query(
                func.count(Booking.id).label("total"),
                func.count(
                    case((Booking.status == BookingStatus.PENDING, Booking.id))
                ).label("pending"),
            )
            .filter(Booking.organization_id.in_(org_ids))
            .first()
        )

        # Query 3: documents (total + pending) + incidents abiertos + zones + invitaciones
        open_incidents = (
            self.db.query(func.count(Incident.id))
            .filter(
                Incident.organization_id.in_(org_ids),
                Incident.status.notin_([IncidentStatus.RESOLVED]),
            )
            .scalar() or 0
        )

        doc_stats = (
            self.db.query(
                func.count(Document.id).label("total"),
                func.count(
                    case((Document.approval_status == DocumentApprovalStatus.PENDING_APPROVAL.value, Document.id))
                ).label("pending"),
            )
            .filter(Document.organization_id.in_(org_ids))
            .first()
        )

        # Query 4: zones + invitaciones pendientes
        total_zones = (
            self.db.query(func.count(Zone.id))
            .filter(Zone.organization_id.in_(org_ids), Zone.is_active == True)  # noqa: E712
            .scalar() or 0
        )
        pending_invitations = (
            self.db.query(func.count(Invitation.id))
            .filter(Invitation.organization_id.in_(org_ids), Invitation.status == InvitationStatus.PENDING)
            .scalar() or 0
        )

        return {
            "total_users": user_stats.total if user_stats else 0,
            "active_users": user_stats.active if user_stats else 0,
            "total_bookings": booking_stats.total if booking_stats else 0,
            "pending_bookings": booking_stats.pending if booking_stats else 0,
            "open_incidents": open_incidents,
            "total_documents": doc_stats.total if doc_stats else 0,
            "pending_documents": doc_stats.pending if doc_stats else 0,
            "total_zones": total_zones,
            "pending_invitations": pending_invitations,
        }

    @staticmethod
    def _empty_dashboard() -> dict:
        return {
            "total_users": 0, "active_users": 0,
            "total_bookings": 0, "pending_bookings": 0,
            "open_incidents": 0,
            "total_documents": 0, "pending_documents": 0,
            "total_zones": 0, "pending_invitations": 0,
        }

    # ── Gestión de usuarios ──────────────────────────────────────────

    def list_users(self, org_ids: List[UUID], role: Optional[str] = None, active_only: bool = False, skip: int = 0, limit: int = 50) -> List[dict]:
        """Listar usuarios de las organizaciones del admin con su información de organización."""
        query = (
            self.db.query(User, UserOrganization)
            .join(UserOrganization, User.id == UserOrganization.user_id)
            .filter(UserOrganization.organization_id.in_(org_ids))
        )
        if active_only:
            query = query.filter(User.is_active == True, UserOrganization.is_active == True)
        if role:
            query = query.filter(UserOrganization.role == role.upper())

        results = query.order_by(User.full_name).offset(skip).limit(limit).all()
        users = []
        for user, uo in results:
            users.append({
                "id": str(user.id),
                "email": user.email,
                "full_name": user.full_name,
                "phone": user.phone,
                "dwelling": uo.dwelling or user.dwelling,
                "role": uo.role if isinstance(uo.role, str) else uo.role.value,
                "is_active": user.is_active,
                "created_at": user.created_at.isoformat(),
                "organization_id": str(uo.organization_id),
            })
        return users

    def get_user(self, user_id: UUID, org_ids: List[UUID]) -> dict:
        """Obtener detalle de un usuario."""
        result = (
            self.db.query(User, UserOrganization)
            .join(UserOrganization, User.id == UserOrganization.user_id)
            .filter(User.id == user_id, UserOrganization.organization_id.in_(org_ids))
            .first()
        )
        if not result:
            raise NotFoundError("Usuario no encontrado")
        user, uo = result
        return {
            "id": str(user.id),
            "email": user.email,
            "full_name": user.full_name,
            "phone": user.phone,
            "dwelling": uo.dwelling or user.dwelling,
            "role": uo.role if isinstance(uo.role, str) else uo.role.value,
            "is_active": user.is_active,
            "created_at": user.created_at.isoformat(),
            "updated_at": user.updated_at.isoformat(),
            "organization_id": str(uo.organization_id),
        }

    def update_user_role(self, user_id: UUID, new_role: str, org_ids: List[UUID]) -> dict:
        """Cambiar el rol de un usuario."""
        uo = (
            self.db.query(UserOrganization)
            .filter(
                UserOrganization.user_id == user_id,
                UserOrganization.organization_id.in_(org_ids),
            )
            .first()
        )
        if not uo:
            raise NotFoundError("Usuario no encontrado en la organización")

        valid_roles = [r.value for r in UserRole]
        if new_role.upper() not in valid_roles:
            raise ServiceError(f"Rol inválido. Roles válidos: {valid_roles}")

        uo.role = new_role.upper()
        # Sincronizar en tabla users también
        user = self.db.query(User).filter(User.id == user_id).first()
        if user:
            user.role = new_role.upper()
        self.db.commit()
        return self.get_user(user_id, org_ids)

    def toggle_user_active(self, user_id: UUID, org_ids: List[UUID]) -> dict:
        """Activar/desactivar un usuario."""
        user = (
            self.db.query(User)
            .join(UserOrganization, User.id == UserOrganization.user_id)
            .filter(User.id == user_id, UserOrganization.organization_id.in_(org_ids))
            .first()
        )
        if not user:
            raise NotFoundError("Usuario no encontrado")
        user.is_active = not user.is_active
        self.db.commit()
        return self.get_user(user_id, org_ids)

    def reset_user_password(self, user_id: UUID, new_password: str, org_ids: List[UUID]) -> None:
        """Resetear la contraseña de un usuario."""
        user = (
            self.db.query(User)
            .join(UserOrganization, User.id == UserOrganization.user_id)
            .filter(User.id == user_id, UserOrganization.organization_id.in_(org_ids))
            .first()
        )
        if not user:
            raise NotFoundError("Usuario no encontrado")
        user.hashed_password = get_password_hash(new_password)
        self.db.commit()

    # ── Importación masiva ───────────────────────────────────────────

    def import_user(
        self,
        email: str,
        full_name: str,
        role: str,
        phone: Optional[str],
        dwelling: Optional[str],
        password: str,
        organization_id: UUID,
    ) -> User:
        """Importar un usuario: crearlo si no existe, o actualizar si ya existe."""
        existing = self.db.query(User).filter(User.email == email).first()

        if existing:
            # Si ya existe, actualizar datos y asegurar que está en la organización
            existing.full_name = full_name
            if phone:
                existing.phone = phone
            if dwelling:
                existing.dwelling = dwelling
            # Verificar si ya está en la organización
            uo = (
                self.db.query(UserOrganization)
                .filter(
                    UserOrganization.user_id == existing.id,
                    UserOrganization.organization_id == organization_id,
                )
                .first()
            )
            if not uo:
                uo = UserOrganization(
                    user_id=existing.id,
                    organization_id=organization_id,
                    role=role,
                    dwelling=dwelling,
                    is_active=True,
                )
                self.db.add(uo)
            else:
                uo.role = role
                if dwelling:
                    uo.dwelling = dwelling
                uo.is_active = True
            self.db.flush()
            return existing
        else:
            # Crear nuevo usuario
            new_user = User(
                email=email,
                full_name=full_name,
                hashed_password=get_password_hash(password),
                role=role,
                phone=phone,
                dwelling=dwelling,
                is_active=True,
            )
            self.db.add(new_user)
            self.db.flush()  # Para obtener el ID

            uo = UserOrganization(
                user_id=new_user.id,
                organization_id=organization_id,
                role=role,
                dwelling=dwelling,
                is_active=True,
            )
            self.db.add(uo)
            self.db.flush()
            return new_user

    def import_zone(
        self,
        name: str,
        zone_type: str,
        description: Optional[str],
        max_capacity: Optional[int],
        requires_approval: bool,
        organization_id: UUID,
    ) -> None:
        """Importar una zona: crearla si no existe (por nombre + org)."""
        existing = (
            self.db.query(Zone)
            .filter(Zone.name == name, Zone.organization_id == organization_id)
            .first()
        )
        if existing:
            # Actualizar
            existing.zone_type = zone_type
            if description:
                existing.description = description
            if max_capacity is not None:
                existing.max_capacity = max_capacity
            existing.requires_approval = requires_approval
            existing.is_active = True
        else:
            zone = Zone(
                name=name,
                zone_type=zone_type,
                description=description,
                organization_id=organization_id,
                max_capacity=max_capacity,
                requires_approval=requires_approval,
                is_active=True,
            )
            self.db.add(zone)
        self.db.flush()
