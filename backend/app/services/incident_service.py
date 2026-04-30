"""
Servicio de incidencias — CRUD + comentarios.
"""
import logging
from sqlalchemy.orm import Session, joinedload, subqueryload
from datetime import datetime, timezone
from uuid import UUID
from typing import List, Optional

from app.models.incident import Incident, IncidentStatus, IncidentPriority
from app.models.incident_comment import IncidentComment
from app.schemas.incident import (
    IncidentCreate, IncidentUpdate, IncidentResponse,
    IncidentCommentCreate, IncidentCommentResponse,
)
from app.core.exceptions import ServiceError, NotFoundError, ForbiddenError

logger = logging.getLogger(__name__)


class IncidentService:

    def __init__(self, db: Session):
        self.db = db

    # ---- Helpers ----

    @staticmethod
    def to_response(inc: Incident) -> IncidentResponse:
        comments = [
            IncidentCommentResponse(
                id=c.id, incident_id=c.incident_id, author_id=c.author_id,
                author_name=c.author.full_name if c.author else None,
                content=c.content, image_url=c.image_url, created_at=c.created_at,
            )
            for c in (inc.comments or [])
        ]
        return IncidentResponse(
            id=inc.id, title=inc.title, description=inc.description,
            priority=inc.priority.value if hasattr(inc.priority, 'value') else inc.priority,
            status=inc.status.value if hasattr(inc.status, 'value') else inc.status,
            reporter_id=inc.reporter_id,
            reporter_name=inc.reporter.full_name if inc.reporter else None,
            assigned_to_id=inc.assigned_to_id,
            assigned_to_name=inc.assigned_to.full_name if inc.assigned_to else None,
            organization_id=inc.organization_id,
            location=inc.location, image_url=inc.image_url,
            created_at=inc.created_at, updated_at=inc.updated_at,
            resolved_at=inc.resolved_at, comments=comments,
        )

    # ---- CRUD ----

    def create(self, data: IncidentCreate, user_id: UUID, org_id: UUID) -> Incident:
        incident = Incident(
            title=data.title, description=data.description,
            priority=data.priority, location=data.location,
            image_url=data.image_url, reporter_id=user_id, organization_id=org_id,
        )
        self.db.add(incident)
        self.db.commit()
        self.db.refresh(incident)
        return incident

    def list(
        self, org_ids: List[UUID], status_filter: str = None,
        priority_filter: str = None,
        user_id: UUID = None, my_only: bool = False,
        skip: int = 0, limit: int = 100,
    ) -> List[Incident]:
        query = self.db.query(Incident).filter(Incident.organization_id.in_(org_ids))
        if status_filter:
            try:
                status_enum = IncidentStatus(status_filter)
                query = query.filter(Incident.status == status_enum)
            except ValueError:
                raise ServiceError(f"Estado inv\u00e1lido: {status_filter}")
        if priority_filter:
            try:
                priority_enum = IncidentPriority(priority_filter)
                query = query.filter(Incident.priority == priority_enum)
                logger.info("Priority filter applied: %s -> %s", priority_filter, priority_enum)
            except ValueError:
                raise ServiceError(f"Prioridad inválida: {priority_filter}")
        if my_only and user_id:
            query = query.filter(Incident.reporter_id == user_id)
        incidents = (
            query.options(
                joinedload(Incident.reporter),
                joinedload(Incident.assigned_to),
                subqueryload(Incident.comments).joinedload(IncidentComment.author),
            )
            .order_by(Incident.created_at.desc())
            .offset(skip).limit(limit).all()
        )
        return incidents

    def get(self, incident_id: UUID, org_ids: List[UUID]) -> Incident:
        incident = (
            self.db.query(Incident)
            .options(
                joinedload(Incident.reporter),
                joinedload(Incident.assigned_to),
                subqueryload(Incident.comments).joinedload(IncidentComment.author),
            )
            .filter(
                Incident.id == incident_id, Incident.organization_id.in_(org_ids),
            ).first()
        )
        if not incident:
            raise NotFoundError("Incidencia no encontrada")
        return incident

    def update(
        self, incident_id: UUID, data: IncidentUpdate,
        user_id: UUID, org_ids: List[UUID], is_admin: bool,
    ) -> tuple[Incident, Optional[str]]:
        """Retorna (incident, old_status_value_or_None)."""
        incident = self.get(incident_id, org_ids)
        if (incident.reporter_id != user_id
                and incident.assigned_to_id != user_id
                and not is_admin):
            raise ForbiddenError("No tienes permisos")

        update_data = data.model_dump(exclude_unset=True)
        old_status = incident.status.value if hasattr(incident.status, 'value') else str(incident.status)

        if update_data.get("status") == "resolved" and incident.status != IncidentStatus.RESOLVED:
            incident.resolved_at = datetime.now(timezone.utc)

        for field, value in update_data.items():
            setattr(incident, field, value)

        self.db.commit()
        self.db.refresh(incident)

        new_status = update_data.get("status")
        status_changed = new_status and str(new_status) != old_status
        return incident, (old_status if status_changed else None)

    def delete(self, incident_id: UUID, org_ids: List[UUID], is_admin: bool, user_id: UUID = None) -> None:
        incident = self.get(incident_id, org_ids)
        # Admin/president can delete any; reporter can delete own
        if not is_admin and (user_id is None or incident.reporter_id != user_id):
            raise ForbiddenError("No tienes permisos")
        # Reporter cannot delete incidents that are already being managed
        if not is_admin:
            inc_status = incident.status.value if hasattr(incident.status, 'value') else str(incident.status)
            if inc_status in ('in_progress', 'resolved'):
                raise ForbiddenError(
                    "No puedes eliminar una incidencia que ya está siendo gestionada. Contacta con el administrador.",
                )
        self.db.delete(incident)
        self.db.commit()

    # ---- Comentarios ----

    def add_comment(self, incident_id: UUID, data: IncidentCommentCreate, user_id: UUID, org_ids: List[UUID]) -> IncidentComment:
        incident = self.get(incident_id, org_ids)
        inc_status = incident.status.value if hasattr(incident.status, 'value') else str(incident.status)
        if inc_status == 'resolved':
            raise ServiceError("No se pueden añadir comentarios a una incidencia resuelta")
        comment = IncidentComment(
            incident_id=incident.id, author_id=user_id,
            content=data.content, image_url=data.image_url,
        )
        self.db.add(comment)
        self.db.commit()
        self.db.refresh(comment)
        return comment

    def get_comments(self, incident_id: UUID, org_ids: List[UUID]) -> List[IncidentComment]:
        incident = self.get(incident_id, org_ids)
        return incident.comments
