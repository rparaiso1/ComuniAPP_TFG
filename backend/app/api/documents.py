"""
Router de documentos — delega la lógica a DocumentService.
Soporta subida real de archivos y workflow de aprobación.
"""
import os
import uuid as uuid_mod
from typing import List, Optional
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Request, UploadFile, File, Form, status
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import decode_access_token
from app.models.user import User
from app.core.deps import (
    get_current_user, get_current_admin_or_president,
    get_active_org_id, get_filtered_org_ids,
    is_admin_or_president_in_org,
)
from app.schemas.document import DocumentCreate, DocumentResponse, DocumentApproveRequest
from app.services.document_service import DocumentService

router = APIRouter()

UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.get("", response_model=List[DocumentResponse])
def get_documents(
    request: Request,
    skip: int = 0, limit: int = 100,
    category: Optional[str] = None,
    approval_status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener documentos. Vecinos solo ven aprobados; admin/presidente ven todos."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    if not org_ids:
        return []
    is_admin = is_admin_or_president_in_org(db, current_user, org_ids)
    docs = DocumentService(db).list(
        org_ids, is_admin, category=category,
        approval_status=approval_status, skip=skip, limit=limit,
    )
    return [DocumentService.to_response(d) for d in docs]


@router.get("/{document_id}", response_model=DocumentResponse)
def get_document(
    request: Request,
    document_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener un documento específico."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    doc = DocumentService(db).get(document_id, org_ids, is_admin_or_president_in_org(db, current_user, org_ids))
    return DocumentService.to_response(doc)


@router.post("", response_model=DocumentResponse, status_code=status.HTTP_201_CREATED)
def create_document(
    request: Request,
    document_in: DocumentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_or_president),
):
    """Crear un nuevo documento (admin/presidente)."""
    org_id = get_active_org_id(request, db, current_user)
    doc = DocumentService(db).create(document_in, current_user.id, org_id)
    return DocumentService.to_response(doc)


@router.post("/upload", response_model=DocumentResponse, status_code=status.HTTP_201_CREATED)
async def upload_document(
    request: Request,
    file: UploadFile = File(...),
    title: str = Form(...),
    description: Optional[str] = Form(None),
    category: Optional[str] = Form(None),
    requires_approval: bool = Form(False),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_or_president),
):
    """Subir un archivo y crear el documento asociado."""
    org_id = get_active_org_id(request, db, current_user)

    # Validate file size (max 10MB)
    content = await file.read()
    max_size = 10 * 1024 * 1024
    if len(content) > max_size:
        raise HTTPException(status_code=400, detail="El archivo no puede superar 10MB")

    # Determine file type
    ext = os.path.splitext(file.filename or "file")[1].lower()
    file_type_map = {
        ".pdf": "pdf", ".doc": "doc", ".docx": "doc",
        ".xls": "excel", ".xlsx": "excel",
        ".jpg": "image", ".jpeg": "image", ".png": "image", ".gif": "image",
        ".txt": "text", ".csv": "text",
    }
    file_type = file_type_map.get(ext, "other")

    # Save to disk
    unique_name = f"{uuid_mod.uuid4().hex}{ext}"
    file_path = os.path.join(UPLOAD_DIR, unique_name)
    with open(file_path, "wb") as f:
        f.write(content)

    # Build a URL for the file
    file_url = f"/api/documents/files/{unique_name}"

    doc_data = DocumentCreate(
        title=title, file_url=file_url, file_type=file_type,
        file_size=len(content), description=description,
        category=category, requires_approval=requires_approval,
    )
    doc = DocumentService(db).create(doc_data, current_user.id, org_id)
    return DocumentService.to_response(doc)


@router.get("/files/{filename}")
def serve_file(
    filename: str,
    token: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """Servir un archivo subido (requiere autenticación via header o query param)."""
    # Authenticate via query token
    if not token:
        raise HTTPException(status_code=401, detail="Token requerido")
    payload = decode_access_token(token)
    if payload is None or payload.get("type") == "refresh":
        raise HTTPException(status_code=401, detail="Token inválido")
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=401, detail="Token inválido")
    user = db.query(User).filter(User.id == UUID(user_id)).first()
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="Usuario no válido")

    # Path traversal protection
    safe_filename = os.path.basename(filename)
    file_path = os.path.join(UPLOAD_DIR, safe_filename)
    if not os.path.abspath(file_path).startswith(os.path.abspath(UPLOAD_DIR)):
        raise HTTPException(status_code=400, detail="Nombre de archivo inválido")

    # Verify org access BEFORE reading file
    from app.models.document import Document
    from app.models.user_organization import UserOrganization
    doc = db.query(Document).filter(
        Document.file_url.contains(safe_filename)
    ).first()
    if not doc:
        raise HTTPException(status_code=404, detail="Documento no encontrado")
    user_org = db.query(UserOrganization).filter(
        UserOrganization.user_id == user.id,
        UserOrganization.organization_id == doc.organization_id,
        UserOrganization.is_active == True,
    ).first()
    if not user_org:
        raise HTTPException(status_code=403, detail="No tienes acceso a este documento")

    if not os.path.isfile(file_path):
        raise HTTPException(status_code=404, detail="Archivo no encontrado")
    return FileResponse(file_path)


@router.post("/{document_id}/approve", response_model=DocumentResponse)
def approve_document(
    request: Request,
    document_id: UUID,
    approval: DocumentApproveRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_or_president),
):
    """Aprobar o rechazar un documento pendiente."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    doc = DocumentService(db).approve(document_id, approval, current_user.id, org_ids)
    return DocumentService.to_response(doc)


@router.delete("/{document_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_document(
    request: Request,
    document_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Eliminar un documento (creador o admin)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    DocumentService(db).delete(
        document_id, current_user.id, org_ids,
        is_admin_or_president_in_org(db, current_user, org_ids),
    )
