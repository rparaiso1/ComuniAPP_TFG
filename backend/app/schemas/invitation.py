"""
Schemas para invitaciones simplificadas (sin SMS).
"""
from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional
from datetime import datetime
from uuid import UUID

from app.schemas.validators import validate_password_strength


class InvitationCreate(BaseModel):
    email: EmailStr
    full_name: str
    phone: Optional[str] = None
    dwelling: str
    role: str  # PRESIDENT o NEIGHBOR

    @field_validator('role')
    @classmethod
    def validate_role(cls, v: str) -> str:
        valid_roles = ['president', 'neighbor']
        if v.lower() not in valid_roles:
            raise ValueError(f'Role must be one of: {", ".join(valid_roles)}')
        return v.upper()


class RegisterWithInvitationRequest(BaseModel):
    token: str
    password: str

    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        return validate_password_strength(v)


class InvitationResponse(BaseModel):
    id: UUID
    email: str
    full_name: str
    phone: Optional[str] = None
    dwelling: str
    role: str
    status: str
    token: Optional[str] = None  # Solo visible para admin al crear
    created_at: datetime
    expires_at: datetime

    class Config:
        from_attributes = True


class InvitationVerifyResponse(BaseModel):
    valid: bool
    message: str
    invitation: Optional[InvitationResponse] = None
