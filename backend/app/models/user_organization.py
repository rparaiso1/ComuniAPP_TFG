from sqlalchemy import Column, String, ForeignKey, Table, Enum as SQLEnum, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import enum

from app.core.database import Base
from app.models.user import UserRole


class UserOrganization(Base):
    """
    Tabla intermedia para relación many-to-many entre User y Organization.
    Permite que un usuario pertenezca a múltiples organizaciones con diferentes roles.
    """
    __tablename__ = "user_organizations"

    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    organization_id = Column(UUID(as_uuid=True), ForeignKey("organizations.id", ondelete="CASCADE"), primary_key=True)
    role = Column(SQLEnum(UserRole), nullable=False, default=UserRole.NEIGHBOR)
    
    # Campos específicos de la relación
    dwelling = Column(String, nullable=True)  # Vivienda en esta organización
    is_active = Column(Boolean, default=True)
    joined_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f"<UserOrganization user={self.user_id} org={self.organization_id} role={self.role}>"
