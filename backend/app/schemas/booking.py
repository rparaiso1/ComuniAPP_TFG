"""
Schemas para reservas de zonas comunes.
"""
from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional
from datetime import datetime
from uuid import UUID


class BookingBase(BaseModel):
    zone_id: UUID
    start_time: datetime
    end_time: datetime
    notes: Optional[str] = Field(default=None, max_length=1000)

    @model_validator(mode='after')
    def end_after_start(self):
        if self.end_time <= self.start_time:
            raise ValueError('end_time debe ser posterior a start_time')
        return self


class BookingCreate(BookingBase):
    pass


class BookingUpdate(BaseModel):
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    notes: Optional[str] = Field(default=None, max_length=1000)

    @model_validator(mode='after')
    def end_after_start_if_both(self):
        if self.start_time and self.end_time and self.end_time <= self.start_time:
            raise ValueError('end_time debe ser posterior a start_time')
        return self


class BookingCancelRequest(BaseModel):
    reason: Optional[str] = Field(default=None, max_length=1000)


class BookingResponse(BaseModel):
    id: UUID
    zone_id: UUID
    zone_name: Optional[str] = None
    zone_type: Optional[str] = None
    user_id: UUID
    user_name: Optional[str] = None
    organization_id: UUID
    start_time: datetime
    end_time: datetime
    status: str = Field(max_length=50)
    notes: Optional[str] = None
    cancellation_reason: Optional[str] = None
    cancelled_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
