"""
Servicio de notificaciones — crear, broadcast, lectura + push FCM.
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

    def _send_push(self, user_id: UUID, title: str, message: str, link: Optional[str] = None):
        """Send FCM push notification (best-effort, non-blocking)."""
        try:
            from app.services.fcm_service import FCMService
            data = {"link": link} if link else {}
            FCMService(self.db).send_to_user(user_id, title, message, data)
        except Exception as e:
            logger.warning(f"FCM push failed for user {user_id}: {e}")

    def _send_push_to_users(self, user_ids: list, title: str, message: str, link: Optional[str] = None):
        """Send FCM push notification to multiple users (best-effort)."""
        try:
            from app.services.fcm_service import FCMService
            data = {"link": link} if link else {}
            FCMService(self.db).send_to_users(user_ids, title, message, data)
        except Exception as e:
            logger.warning(f"FCM push failed for {len(user_ids)} users: {e}")

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
        # Send FCM push notification
        self._send_push(user_id, title, message, link)
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
        # Send FCM push to all org members
        user_ids = [uo.user_id for uo in user_orgs]
        self._send_push_to_users(user_ids, title, message, link)

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
            # Send FCM push to leaders
            leader_ids = [n.user_id for n in notifications]
            self._send_push_to_users(leader_ids, title, message, link)

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
