"""
Schemas para el panel de administración.
"""
from pydantic import BaseModel, field_validator
from typing import List

from app.schemas.validators import validate_password_strength


class AdminDashboard(BaseModel):
    total_users: int
    active_users: int
    total_bookings: int
    pending_bookings: int
    open_incidents: int
    total_documents: int
    pending_documents: int
    total_zones: int
    pending_invitations: int


class ChangeRoleRequest(BaseModel):
    role: str

    @field_validator('role')
    @classmethod
    def role_must_be_valid(cls, v: str) -> str:
        valid = ('ADMIN', 'PRESIDENT', 'NEIGHBOR')
        if v.upper() not in valid:
            raise ValueError(f"Rol inválido. Roles válidos: {', '.join(valid)}")
        return v.upper()


class ResetPasswordRequest(BaseModel):
    new_password: str

    @field_validator('new_password')
    @classmethod
    def password_strength(cls, v: str) -> str:
        return validate_password_strength(v)


class ImportResult(BaseModel):
    total_rows: int
    imported: int
    errors: List[str]
