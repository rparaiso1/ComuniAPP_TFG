"""
Schemas para zonas comunes.
"""
from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime, time
from uuid import UUID


class ZoneBase(BaseModel):
    name: str = Field(max_length=100)
    zone_type: str = Field(max_length=50)  # pool, court, room, gym, etc.
    description: Optional[str] = Field(default=None, max_length=1000)
    max_capacity: Optional[int] = None
    max_booking_hours: int = 2
    max_bookings_per_user_day: int = 1
    advance_booking_days: int = 30
    requires_approval: bool = False
    available_from: time = time(8, 0)
    available_until: time = time(22, 0)

    @field_validator('zone_type')
    @classmethod
    def validate_zone_type(cls, v: str) -> str:
        return v.lower().strip()


class ZoneCreate(ZoneBase):
    pass


class ZoneUpdate(BaseModel):
    name: Optional[str] = Field(default=None, max_length=100)
    zone_type: Optional[str] = Field(default=None, max_length=50)
    description: Optional[str] = Field(default=None, max_length=1000)
    max_capacity: Optional[int] = None
    max_booking_hours: Optional[int] = None
    max_bookings_per_user_day: Optional[int] = None
    advance_booking_days: Optional[int] = None
    requires_approval: Optional[bool] = None
    available_from: Optional[time] = None
    available_until: Optional[time] = None
    is_active: Optional[bool] = None


class ZoneResponse(ZoneBase):
    id: UUID
    organization_id: UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
