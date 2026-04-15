"""
Capa de servicios — Lógica de negocio separada de los routers (controladores).

Arquitectura:
    Routers (API) → Services (lógica) → Models (ORM) → Schemas (validación)

Los services reciben una Session de SQLAlchemy y realizan las operaciones
de negocio sin depender de FastAPI (HTTPException se lanza en el router).

Las excepciones semánticas de servicio viven en app.core.exceptions:
    ServiceError  → 400   (base / validación)
    NotFoundError → 404
    ForbiddenError→ 403
    ConflictError → 409
    UnauthorizedError → 401

Los exception handlers globales en main.py las mapean a HTTP status codes.
"""

from app.core.exceptions import (
    ServiceError, NotFoundError, ForbiddenError,
    ConflictError, UnauthorizedError,
)

from app.services.auth_service import AuthService
from app.services.booking_service import BookingService
from app.services.incident_service import IncidentService
from app.services.notification_service import NotificationService
from app.services.post_service import PostService
from app.services.document_service import DocumentService
from app.services.organization_service import OrganizationService
from app.services.invitation_service import InvitationService
from app.services.zone_service import ZoneService
from app.services.stats_service import StatsService
from app.services.calendar_service import CalendarService
from app.services.admin_service import AdminService

__all__ = [
    # Excepciones semánticas
    "ServiceError", "NotFoundError", "ForbiddenError",
    "ConflictError", "UnauthorizedError",
    # Servicios
    "AuthService",
    "BookingService",
    "IncidentService",
    "NotificationService",
    "PostService",
    "DocumentService",
    "OrganizationService",
    "InvitationService",
    "ZoneService",
    "StatsService",
    "CalendarService",
    "AdminService",
]
