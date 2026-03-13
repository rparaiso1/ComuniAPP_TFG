from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional, List
from datetime import datetime
from uuid import UUID

from app.schemas.validators import validate_password_strength


class UserBase(BaseModel):
    email: EmailStr
    full_name: str = Field(max_length=150)
    role: str = "NEIGHBOR"


class UserCreate(UserBase):
    password: str

    @field_validator('password')
    @classmethod
    def password_strength(cls, v: str) -> str:
        return validate_password_strength(v)

    @field_validator('role')
    @classmethod
    def role_must_be_neighbor(cls, v: str) -> str:
        """El registro abierto solo permite rol NEIGHBOR. Admin/President se asignan por invitación."""
        if v.upper() not in ('NEIGHBOR',):
            raise ValueError('Solo se permite el rol NEIGHBOR en registro abierto')
        return v.upper()


class UserUpdate(BaseModel):
    full_name: Optional[str] = Field(default=None, max_length=150)
    phone: Optional[str] = Field(default=None, max_length=20)
    dwelling: Optional[str] = Field(default=None, max_length=100)


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str

    @field_validator('new_password')
    @classmethod
    def password_strength(cls, v: str) -> str:
        return validate_password_strength(v)


class UserResponse(UserBase):
    id: UUID
    is_active: bool
    phone: Optional[str] = None
    dwelling: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    name: Optional[str] = None  # Alias para full_name

    class Config:
        from_attributes = True


class UserWithOrganizationsResponse(UserResponse):
    """User response with list of organizations"""
    organizations: List[dict] = []  # List of {org_id, org_name, org_code, role, dwelling}


class Token(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str = "bearer"


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
