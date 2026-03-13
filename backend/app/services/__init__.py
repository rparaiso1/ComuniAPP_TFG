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

from app.services.auth_service import AuthService, AuthError
from app.services.booking_service import BookingService, BookingError
from app.services.incident_service import IncidentService, IncidentError
from app.services.notification_service import NotificationService
from app.services.post_service import PostService, PostError
from app.services.document_service import DocumentService, DocumentError
from app.services.organization_service import OrganizationService, OrganizationError
from app.services.invitation_service import InvitationService, InvitationError
from app.services.zone_service import ZoneService, ZoneError
from app.services.stats_service import StatsService
from app.services.calendar_service import CalendarService
from app.services.admin_service import AdminService, AdminError

__all__ = [
    # Excepciones semánticas
    "ServiceError", "NotFoundError", "ForbiddenError",
    "ConflictError", "UnauthorizedError",
    # Servicios + alias de error por retrocompatibilidad
    "AuthService", "AuthError",
    "BookingService", "BookingError",
    "IncidentService", "IncidentError",
    "NotificationService",
    "PostService", "PostError",
    "DocumentService", "DocumentError",
    "OrganizationService", "OrganizationError",
    "InvitationService", "InvitationError",
    "ZoneService", "ZoneError",
    "StatsService",
    "CalendarService",
    "AdminService", "AdminError",
]
