"""
Router de incidencias — delega la lógica a IncidentService.
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.core.database import get_db
from app.core.deps import get_current_user, get_active_org_id, get_filtered_org_ids, is_admin_or_president_in_org
from app.models.user import User
from app.models.notification import NotificationType
from app.schemas.incident import (
    IncidentCreate, IncidentUpdate, IncidentResponse,
    IncidentCommentCreate, IncidentCommentResponse,
)
from app.services.incident_service import IncidentService
from app.services.notification_service import NotificationService

router = APIRouter()


@router.post("", response_model=IncidentResponse, status_code=status.HTTP_201_CREATED)
def create_incident(
    request: Request,
    incident_data: IncidentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Crear una nueva incidencia."""
    org_id = get_active_org_id(request, db, current_user)
    incident = IncidentService(db).create(incident_data, current_user.id, org_id)
    NotificationService(db).broadcast(
        organization_id=org_id, title="Nueva incidencia",
        message=f"{current_user.full_name} reportó: {incident.title}",
        notification_type=NotificationType.INCIDENT, link=f"/incidents/{incident.id}",
    )
    return IncidentService.to_response(incident)


@router.get("", response_model=List[IncidentResponse])
def get_incidents(
    request: Request,
    skip: int = 0, limit: int = Query(default=100, le=500),
    status_filter: Optional[str] = None, priority_filter: Optional[str] = None,
    my_only: bool = False,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener incidencias con filtros."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    incidents = IncidentService(db).list(
        org_ids, status_filter=status_filter,
        priority_filter=priority_filter,
        user_id=current_user.id if my_only else None,
        my_only=my_only,
        skip=skip, limit=limit,
    )
    return [IncidentService.to_response(i) for i in incidents]


@router.get("/{incident_id}", response_model=IncidentResponse)
def get_incident(
    request: Request,
    incident_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener detalle de una incidencia con comentarios."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    incident = IncidentService(db).get(incident_id, org_ids)
    return IncidentService.to_response(incident)


@router.put("/{incident_id}", response_model=IncidentResponse)
def update_incident(
    request: Request,
    incident_id: UUID,
    incident_data: IncidentUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Actualizar una incidencia."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    is_elevated = is_admin_or_president_in_org(db, current_user, org_ids)
    # Solo admin/presidente puede cambiar estado
    update_fields = incident_data.model_dump(exclude_unset=True)
    if "status" in update_fields and not is_elevated:
        raise HTTPException(status_code=403, detail="No tienes permisos para cambiar el estado")
    incident, old_status = IncidentService(db).update(
        incident_id, incident_data, current_user.id,
        org_ids, is_elevated,
    )
    new_status = incident_data.model_dump(exclude_unset=True).get("status")
    if new_status and str(new_status) != str(old_status):
        NotificationService(db).create(
            user_id=incident.reporter_id, title="Incidencia actualizada",
            message=f"Tu incidencia '{incident.title}' cambió a: {new_status}",
            notification_type=NotificationType.INCIDENT, link=f"/incidents/{incident.id}",
        )
    return IncidentService.to_response(incident)


@router.delete("/{incident_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_incident(
    request: Request,
    incident_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Eliminar una incidencia (propia, o cualquier si admin)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    is_elevated = is_admin_or_president_in_org(db, current_user, org_ids)
    IncidentService(db).delete(
        incident_id, org_ids,
        is_admin=is_elevated,
        user_id=current_user.id,
    )


@router.post("/{incident_id}/comments", response_model=IncidentCommentResponse, status_code=status.HTTP_201_CREATED)
def add_comment(
    request: Request,
    incident_id: UUID,
    comment_data: IncidentCommentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Añadir un comentario a una incidencia."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    svc = IncidentService(db)
    incident = svc.get(incident_id, org_ids)
    comment = svc.add_comment(incident_id, comment_data, current_user.id, org_ids)
    if incident.reporter_id != current_user.id:
        NotificationService(db).create(
            user_id=incident.reporter_id, title="Nuevo comentario",
            message=f"{current_user.full_name} comentó en tu incidencia '{incident.title}'",
            notification_type=NotificationType.INCIDENT, link=f"/incidents/{incident.id}",
        )
    return IncidentCommentResponse(
        id=comment.id, incident_id=comment.incident_id,
        author_id=comment.author_id, author_name=current_user.full_name,
        content=comment.content, image_url=comment.image_url,
        created_at=comment.created_at,
    )


@router.get("/{incident_id}/comments", response_model=List[IncidentCommentResponse])
def get_comments(
    request: Request,
    incident_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener comentarios de una incidencia."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    return IncidentService(db).get_comments(incident_id, org_ids)
