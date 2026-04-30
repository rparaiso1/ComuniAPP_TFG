"""
Router de notificaciones — delega la lógica a NotificationService.
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.services.notification_service import NotificationService

router = APIRouter()


# ============ Schemas (locales al router) ============

class NotificationResponse(BaseModel):
    id: UUID
    title: str
    message: str
    notification_type: str
    link: Optional[str] = None
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True


class NotificationListResponse(BaseModel):
    notifications: List[NotificationResponse]
    unread_count: int
    total_count: int


# ============ Endpoints ============

@router.get("", response_model=NotificationListResponse)
def get_notifications(
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=20, le=500),
    unread_only: bool = False,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Obtener notificaciones del usuario."""
    data = NotificationService(db).get_for_user(current_user.id, skip=skip, limit=limit, unread_only=unread_only)
    return NotificationListResponse(
        notifications=[NotificationResponse.model_validate(n) for n in data["notifications"]],
        unread_count=data["unread_count"],
        total_count=data["total_count"],
    )


@router.post("/{notification_id}/read")
def mark_as_read(
    notification_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Marcar notificación como leída."""
    found = NotificationService(db).mark_read(notification_id, current_user.id)
    if not found:
        raise HTTPException(status_code=404, detail="Notificación no encontrada")
    return {"message": "Notificación marcada como leída"}


@router.post("/read-all")
def mark_all_as_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Marcar todas las notificaciones como leídas."""
    NotificationService(db).mark_all_read(current_user.id)
    return {"message": "Todas las notificaciones marcadas como leídas"}


@router.delete("/{notification_id}")
def delete_notification(
    notification_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Eliminar una notificación."""
    found = NotificationService(db).delete(notification_id, current_user.id)
    if not found:
        raise HTTPException(status_code=404, detail="Notificación no encontrada")
    return {"message": "Notificación eliminada"}


@router.delete("")
def clear_all_notifications(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Eliminar todas las notificaciones."""
    NotificationService(db).clear_all(current_user.id)
    return {"message": "Todas las notificaciones eliminadas"}
