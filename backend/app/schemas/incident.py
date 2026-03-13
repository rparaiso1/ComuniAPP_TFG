"""
Schemas para incidencias y comentarios de seguimiento.
"""
from pydantic import BaseModel, Field, field_validator
from typing import Optional, List
from datetime import datetime
from uuid import UUID

# Enums definidos en el modelo — fuente de verdad única
from app.models.incident import IncidentPriority as PriorityEnum, IncidentStatus as StatusEnum


class IncidentBase(BaseModel):
    title: str = Field(max_length=200)
    description: str = Field(max_length=5000)
    priority: PriorityEnum = PriorityEnum.MEDIUM
    location: Optional[str] = Field(default=None, max_length=200)
    image_url: Optional[str] = Field(default=None, max_length=500)

    @field_validator('title')
    @classmethod
    def title_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError('El título no puede estar vacío')
        if len(v) > 255:
            raise ValueError('El título no puede superar 255 caracteres')
        return v.strip()

    @field_validator('description')
    @classmethod
    def description_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError('La descripción no puede estar vacía')
        return v.strip()


class IncidentCreate(IncidentBase):
    pass


class IncidentUpdate(BaseModel):
    title: Optional[str] = Field(default=None, max_length=200)
    description: Optional[str] = Field(default=None, max_length=5000)
    priority: Optional[PriorityEnum] = None
    status: Optional[StatusEnum] = None
    assigned_to_id: Optional[UUID] = None
    location: Optional[str] = Field(default=None, max_length=200)
    image_url: Optional[str] = Field(default=None, max_length=500)


# --- Comentarios ---

class IncidentCommentCreate(BaseModel):
    content: str = Field(max_length=5000)
    image_url: Optional[str] = Field(default=None, max_length=500)


class IncidentCommentResponse(BaseModel):
    id: UUID
    incident_id: UUID
    author_id: UUID
    author_name: Optional[str] = None
    content: str
    image_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class IncidentResponse(IncidentBase):
    id: UUID
    status: str = Field(max_length=50)
    reporter_id: UUID
    reporter_name: Optional[str] = None
    assigned_to_id: Optional[UUID] = None
    assigned_to_name: Optional[str] = None
    organization_id: Optional[UUID] = None
    created_at: datetime
    updated_at: datetime
    resolved_at: Optional[datetime] = None
    comments: List[IncidentCommentResponse] = []

    class Config:
        from_attributes = True
