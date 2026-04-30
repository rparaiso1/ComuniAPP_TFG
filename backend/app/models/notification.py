"""
Modelo Notification - Notificaciones persistentes en DB.
"""
from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid
import enum

from app.core.database import Base


class NotificationType(str, enum.Enum):
    BOOKING = "booking"
    INCIDENT = "incident"
    DOCUMENT = "document"
    ANNOUNCEMENT = "announcement"
    SYSTEM = "system"


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    notification_type = Column(String, default=NotificationType.SYSTEM.value)
    link = Column(String, nullable=True)  # Deep link dentro de la app
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # Relaciones
    user = relationship("User", backref="notifications")

    def __repr__(self):
        return f"<Notification {self.title} -> {self.user_id}>"
