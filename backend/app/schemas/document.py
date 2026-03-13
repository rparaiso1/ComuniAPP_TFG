"""
Schemas para documentos con workflow de aprobación.
"""
from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, Field


class DocumentBase(BaseModel):
    title: str = Field(max_length=200)
    file_url: str = Field(max_length=500)
    file_type: str = Field(max_length=50)
    file_size: Optional[int] = None
    description: Optional[str] = Field(default=None, max_length=5000)
    category: Optional[str] = Field(default=None, max_length=100)  # acta, norma, documento, otro


class DocumentCreate(DocumentBase):
    requires_approval: bool = False  # Si true, se crea como 'pending_approval'


class DocumentResponse(DocumentBase):
    id: UUID
    organization_id: UUID
    uploaded_by_id: UUID
    uploaded_by_name: Optional[str] = None
    approval_status: str
    approved_by_id: Optional[UUID] = None
    approved_by_name: Optional[str] = None
    approved_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class DocumentApproveRequest(BaseModel):
    """Para aprobar o rechazar un documento"""
    approved: bool
    rejection_reason: Optional[str] = None
