"""
Modelo Document - Documentos de la comunidad (actas, normas, PDFs, etc.)

Incluye workflow de aprobación para documentos importantes (actas):
  draft → pending_approval → approved / rejected

Documentos informativos se pueden publicar directamente como 'approved'.
"""
from sqlalchemy import Column, String, DateTime, ForeignKey, Integer, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid
import enum
from app.core.database import Base


class DocumentApprovalStatus(str, enum.Enum):
    """Estados del workflow de aprobación de documentos."""
    DRAFT = "draft"
    PENDING_APPROVAL = "pending_approval"
    APPROVED = "approved"
    REJECTED = "rejected"


class Document(Base):
    __tablename__ = "documents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String, nullable=False)
    file_url = Column(String, nullable=False)
    file_type = Column(String, nullable=False)  # pdf, doc, image, etc.
    file_size = Column(Integer, nullable=True)  # in bytes
    uploaded_by_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    organization_id = Column(UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True)
    description = Column(Text, nullable=True)
    category = Column(String, nullable=True)  # acta, norma, documento, otro
    
    # Workflow de aprobación
    # draft: borrador, pending_approval: pendiente, approved: aprobado, rejected: rechazado
    approval_status = Column(String(50), default="approved")  # Por defecto publicado
    approved_by_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    approved_at = Column(DateTime, nullable=True)
    rejection_reason = Column(Text, nullable=True)
    
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    uploaded_by = relationship("User", foreign_keys=[uploaded_by_id], backref="documents")
    approved_by = relationship("User", foreign_keys=[approved_by_id], backref="approved_documents")

    def __repr__(self):
        return f"<Document {self.title} ({self.approval_status})>"
