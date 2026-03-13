"""
Modelo Invitation - Invitaciones simplificadas para registro.

Flujo: Admin crea invitación → genera token único → vecino accede con token → se registra.
Sin SMS ni verificación compleja. El token es suficiente para seguridad básica.
"""
from sqlalchemy import Column, String, DateTime, Enum as SQLEnum, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime, timedelta, timezone
import uuid
import enum
import secrets
from app.core.database import Base


class InvitationStatus(str, enum.Enum):
    PENDING = "pending"
    USED = "used"
    EXPIRED = "expired"


class Invitation(Base):
    __tablename__ = "invitations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, nullable=False, index=True)
    full_name = Column(String, nullable=False)
    phone = Column(String, nullable=True)  # Opcional
    dwelling = Column(String, nullable=False)  # Ej: "Bloque A - 3º B"
    role = Column(String, nullable=False)  # PRESIDENT, NEIGHBOR
    organization_id = Column(UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True)
    
    # Token único de invitación (reemplaza SMS + DNI)
    token = Column(String, unique=True, nullable=False, index=True)
    
    # Estado
    status = Column(SQLEnum(InvitationStatus), default=InvitationStatus.PENDING)
    
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    expires_at = Column(DateTime, default=lambda: datetime.now(timezone.utc) + timedelta(days=30))
    used_at = Column(DateTime, nullable=True)

    @staticmethod
    def generate_token():
        """Generate secure unique token"""
        return secrets.token_urlsafe(32)

    def is_valid(self):
        """Check if invitation is still valid"""
        now = datetime.now(timezone.utc)
        expires = self.expires_at
        # Normalize timezone awareness for comparison
        if expires.tzinfo is None:
            expires = expires.replace(tzinfo=timezone.utc)
        return (
            self.status == InvitationStatus.PENDING
            and now < expires
        )

    def mark_as_used(self):
        """Mark invitation as used"""
        self.status = InvitationStatus.USED
        self.used_at = datetime.now(timezone.utc)

    def __repr__(self):
        return f"<Invitation {self.email} - {self.dwelling} ({self.status})>"
