from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional
from datetime import datetime
import uuid


class OrganizationBase(BaseModel):
    name: str = Field(max_length=150)
    code: str = Field(max_length=50)
    address: Optional[str] = Field(default=None, max_length=300)
    logo_url: Optional[str] = Field(default=None, max_length=500)
    primary_color: Optional[str] = Field(default="#6366F1", max_length=20)
    phone: Optional[str] = Field(default=None, max_length=20)
    email: Optional[EmailStr] = None

    @field_validator('code')
    @classmethod
    def code_must_be_uppercase(cls, v: str) -> str:
        return v.upper().replace(' ', '_')


class OrganizationCreate(OrganizationBase):
    pass


class OrganizationUpdate(BaseModel):
    name: Optional[str] = Field(default=None, max_length=150)
    address: Optional[str] = Field(default=None, max_length=300)
    logo_url: Optional[str] = Field(default=None, max_length=500)
    primary_color: Optional[str] = Field(default=None, max_length=20)
    phone: Optional[str] = Field(default=None, max_length=20)
    email: Optional[EmailStr] = None
    is_active: Optional[bool] = None


class OrganizationResponse(OrganizationBase):
    id: uuid.UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class UserOrganizationResponse(BaseModel):
    """Response for user's organizations with their role in each"""
    organization_id: uuid.UUID
    organization_name: str
    organization_code: str
    role: str
    dwelling: Optional[str] = None
    is_active: bool
    joined_at: datetime

    class Config:
        from_attributes = True
