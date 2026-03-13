"""
Router de calendario — delega la lógica a CalendarService.
"""
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date, datetime
from uuid import UUID
from pydantic import BaseModel
from enum import Enum

from app.core.database import get_db
from app.core.deps import get_current_user, get_filtered_org_ids
from app.models.user import User
from app.services.calendar_service import CalendarService

router = APIRouter()


# ── Schemas locales ──────────────────────────────────────────────────
class EventType(str, Enum):
    BOOKING = "booking"
    COMMUNITY = "community"
    MAINTENANCE = "maintenance"


class CalendarEventResponse(BaseModel):
    id: UUID
    title: str
    description: Optional[str]
    start_date: datetime
    end_date: datetime
    event_type: str
    color: str
    all_day: bool = False
    location: Optional[str] = None
    created_by: Optional[str] = None

    class Config:
        from_attributes = True


class CalendarMonthResponse(BaseModel):
    year: int
    month: int
    events: List[CalendarEventResponse]
    bookings_count: int
    community_events_count: int


# ── Endpoints ────────────────────────────────────────────────────────
@router.get("/events", response_model=List[CalendarEventResponse])
def get_calendar_events(
    request: Request,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    event_type: Optional[EventType] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener eventos del calendario."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    events = CalendarService(db).get_events(
        org_ids,
        start_date,
        end_date,
        event_type.value if event_type else None,
    )
    return events


@router.get("/month/{year}/{month}", response_model=CalendarMonthResponse)
def get_month_calendar(
    request: Request,
    year: int,
    month: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener calendario de un mes específico."""
    if month < 1 or month > 12:
        raise HTTPException(status_code=400, detail="Mes inválido")
    org_ids = get_filtered_org_ids(request, db, current_user)
    return CalendarService(db).get_month(org_ids, year, month)


@router.get("/today", response_model=List[CalendarEventResponse])
def get_today_events(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener eventos de hoy."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    return CalendarService(db).get_today(org_ids)


@router.get("/upcoming", response_model=List[CalendarEventResponse])
def get_upcoming_events(
    request: Request,
    days: int = 7,
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener próximos eventos."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    return CalendarService(db).get_upcoming(org_ids, days, limit)
