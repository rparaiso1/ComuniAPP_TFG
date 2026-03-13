"""
Servicio de documentos — CRUD + workflow de aprobación.
"""
from sqlalchemy.orm import Session, joinedload
from datetime import datetime, timezone
from uuid import UUID
from typing import List, Optional

from app.models.document import Document, DocumentApprovalStatus
from app.schemas.document import DocumentCreate, DocumentResponse, DocumentApproveRequest
from app.core.exceptions import ServiceError, NotFoundError, ForbiddenError

# Alias mantenido por retrocompatibilidad con imports existentes
DocumentError = ServiceError


class DocumentService:

    def __init__(self, db: Session):
        self.db = db

    @staticmethod
    def to_response(doc: Document) -> DocumentResponse:
        return DocumentResponse(
            id=doc.id, title=doc.title, file_url=doc.file_url,
            file_type=doc.file_type, file_size=doc.file_size,
            description=doc.description, category=doc.category,
            organization_id=doc.organization_id,
            uploaded_by_id=doc.uploaded_by_id,
            uploaded_by_name=doc.uploaded_by.full_name if doc.uploaded_by else None,
            approval_status=doc.approval_status,
            approved_by_id=doc.approved_by_id,
            approved_by_name=doc.approved_by.full_name if doc.approved_by else None,
            approved_at=doc.approved_at,
            rejection_reason=doc.rejection_reason,
            created_at=doc.created_at, updated_at=doc.updated_at,
        )

    def list(
        self, org_ids: List[UUID], is_admin: bool,
        category: str = None, approval_status: str = None,
        skip: int = 0, limit: int = 100,
    ) -> List[Document]:
        query = self.db.query(Document).filter(Document.organization_id.in_(org_ids))
        if not is_admin:
            query = query.filter(Document.approval_status == DocumentApprovalStatus.APPROVED.value)
        elif approval_status:
            query = query.filter(Document.approval_status == approval_status)
        if category:
            query = query.filter(Document.category == category)
        return (
            query.options(joinedload(Document.uploaded_by), joinedload(Document.approved_by))
            .order_by(Document.created_at.desc()).offset(skip).limit(limit).all()
        )

    def get(self, document_id: UUID, org_ids: List[UUID], is_admin: bool) -> Document:
        doc = (
            self.db.query(Document)
            .options(joinedload(Document.uploaded_by), joinedload(Document.approved_by))
            .filter(
                Document.id == document_id, Document.organization_id.in_(org_ids),
            ).first()
        )
        if not doc:
            raise NotFoundError("Documento no encontrado")
        if not is_admin and doc.approval_status != DocumentApprovalStatus.APPROVED.value:
            raise NotFoundError("Documento no encontrado")
        return doc

    def create(self, data: DocumentCreate, user_id: UUID, org_id: UUID) -> Document:
        doc = Document(
            title=data.title, file_url=data.file_url, file_type=data.file_type,
            file_size=data.file_size, description=data.description,
            category=data.category, organization_id=org_id,
            uploaded_by_id=user_id,
            approval_status=DocumentApprovalStatus.PENDING_APPROVAL.value if data.requires_approval else DocumentApprovalStatus.APPROVED.value,
        )
        self.db.add(doc)
        self.db.commit()
        self.db.refresh(doc)
        return doc

    def approve(self, document_id: UUID, approval: DocumentApproveRequest, user_id: UUID, org_ids: List[UUID]) -> Document:
        doc = self.db.query(Document).filter(
            Document.id == document_id, Document.organization_id.in_(org_ids),
        ).first()
        if not doc:
            raise NotFoundError("Documento no encontrado")
        if doc.approval_status != DocumentApprovalStatus.PENDING_APPROVAL.value:
            raise ServiceError("El documento no está pendiente de aprobación")
        if approval.approved:
            doc.approval_status = DocumentApprovalStatus.APPROVED.value
            doc.approved_by_id = user_id
            doc.approved_at = datetime.now(timezone.utc)
            doc.rejection_reason = None
        else:
            doc.approval_status = DocumentApprovalStatus.REJECTED.value
            doc.rejection_reason = approval.rejection_reason
        self.db.commit()
        self.db.refresh(doc)
        return doc

    def delete(self, document_id: UUID, user_id: UUID, org_ids: List[UUID], is_admin: bool) -> None:
        doc = self.db.query(Document).filter(
            Document.id == document_id, Document.organization_id.in_(org_ids),
        ).first()
        if not doc:
            raise NotFoundError("Documento no encontrado")
        if doc.uploaded_by_id != user_id and not is_admin:
            raise ForbiddenError("No tienes permisos")
        self.db.delete(doc)
        self.db.commit()
