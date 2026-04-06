"""
Servicio de notificaciones — crear, broadcast, lectura.
"""
from sqlalchemy.orm import Session
from uuid import UUID
from typing import Optional
import logging

from app.models.notification import Notification, NotificationType
from app.models.user_organization import UserOrganization
from app.models.user import UserRole

logger = logging.getLogger(__name__)

class NotificationService:

    def __init__(self, db: Session):
        self.db = db

    def create(
        self, user_id: UUID, title: str, message: str,
        notification_type: NotificationType = NotificationType.SYSTEM,
        link: Optional[str] = None,
    ) -> Notification:
        notif = Notification(
            user_id=user_id, title=title, message=message,
            notification_type=notification_type.value, link=link,
        )
        self.db.add(notif)
        self.db.flush()
        self.db.commit()
        return notif

    def broadcast(
        self, organization_id: UUID, title: str, message: str,
        notification_type: NotificationType = NotificationType.ANNOUNCEMENT,
        link: Optional[str] = None,
    ) -> None:
        user_orgs = self.db.query(UserOrganization).filter(
            UserOrganization.organization_id == organization_id,
            UserOrganization.is_active == True,
        ).all()
        notifications = [
            Notification(
                user_id=uo.user_id, title=title, message=message,
                notification_type=notification_type.value, link=link,
            )
            for uo in user_orgs
        ]
        self.db.add_all(notifications)
        self.db.flush()
        self.db.commit()

    def broadcast_to_leaders(
        self, organization_id: UUID, title: str, message: str,
        notification_type: NotificationType = NotificationType.SYSTEM,
        link: Optional[str] = None,
        exclude_user_id: Optional[UUID] = None,
    ) -> None:
        """Send notification only to ADMIN and PRESIDENT users in the org."""
        user_orgs = self.db.query(UserOrganization).filter(
            UserOrganization.organization_id == organization_id,
            UserOrganization.is_active == True,
            UserOrganization.role.in_([UserRole.ADMIN, UserRole.PRESIDENT]),
        ).all()
        notifications = [
            Notification(
                user_id=uo.user_id, title=title, message=message,
                notification_type=notification_type.value, link=link,
            )
            for uo in user_orgs
            if exclude_user_id is None or uo.user_id != exclude_user_id
        ]
        if notifications:
            self.db.add_all(notifications)
            self.db.flush()
            self.db.commit()

    def get_for_user(self, user_id: UUID, skip: int = 0, limit: int = 20, unread_only: bool = False) -> dict:
        query = self.db.query(Notification).filter(Notification.user_id == user_id)
        if unread_only:
            query = query.filter(Notification.is_read == False)
        total = self.db.query(Notification).filter(Notification.user_id == user_id).count()
        unread = self.db.query(Notification).filter(
            Notification.user_id == user_id, Notification.is_read == False,
        ).count()
        notifications = query.order_by(Notification.created_at.desc()).offset(skip).limit(limit).all()
        return {"notifications": notifications, "unread_count": unread, "total_count": total}

    def mark_read(self, notification_id: UUID, user_id: UUID) -> bool:
        notif = self.db.query(Notification).filter(
            Notification.id == notification_id, Notification.user_id == user_id,
        ).first()
        if not notif:
            return False
        notif.is_read = True
        self.db.commit()
        return True

    def mark_all_read(self, user_id: UUID) -> None:
        self.db.query(Notification).filter(
            Notification.user_id == user_id, Notification.is_read == False,
        ).update({"is_read": True})
        self.db.commit()

    def delete(self, notification_id: UUID, user_id: UUID) -> bool:
        notif = self.db.query(Notification).filter(
            Notification.id == notification_id, Notification.user_id == user_id,
        ).first()
        if not notif:
            return False
        self.db.delete(notif)
        self.db.commit()
        return True

    def clear_all(self, user_id: UUID) -> None:
        self.db.query(Notification).filter(Notification.user_id == user_id).delete()
        self.db.commit()
