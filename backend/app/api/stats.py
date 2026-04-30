"""
Router de estadísticas — delega la lógica a StatsService.
"""
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.core.database import get_db
from app.core.deps import get_current_user, get_filtered_org_ids
from app.models.user import User
from app.services.stats_service import StatsService

router = APIRouter()


# ── Schemas locales ──────────────────────────────────────────────────
class DashboardStats(BaseModel):
    bookings_count: int
    incidents_count: int
    documents_count: int
    posts_count: int
    pending_invitations: int

    class Config:
        from_attributes = True


class BookingsStats(BaseModel):
    total: int
    confirmed: int
    pending: int
    cancelled: int


class IncidentsStats(BaseModel):
    total: int
    open: int
    in_progress: int
    resolved: int


# ── Endpoints ────────────────────────────────────────────────────────
@router.get("/dashboard", response_model=DashboardStats)
def get_dashboard_stats(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Estadísticas para el dashboard del usuario."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    data = StatsService(db).dashboard(current_user.id, org_ids, current_user.role)
    return DashboardStats(**data)


@router.get("/bookings", response_model=BookingsStats)
def get_bookings_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Estadísticas detalladas de reservas."""
    data = StatsService(db).bookings(current_user.id)
    return BookingsStats(**data)


@router.get("/incidents", response_model=IncidentsStats)
def get_incidents_stats(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Estadísticas detalladas de incidencias."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    data = StatsService(db).incidents(org_ids)
    return IncidentsStats(**data)
