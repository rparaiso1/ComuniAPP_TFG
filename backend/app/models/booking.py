"""
Modelo Booking - Reservas de zonas comunes.

Vinculada a Zone (zona reservable) y Organization (multi-tenancy).
Incluye estado de la reserva y lógica de cancelación.
"""
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Integer, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid
import enum
from app.core.database import Base


class BookingStatus(str, enum.Enum):
    """Estados posibles de una reserva."""
    PENDING = "pending"
    CONFIRMED = "confirmed"
    CANCELLED = "cancelled"


class Booking(Base):
    __tablename__ = "bookings"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    zone_id = Column(UUID(as_uuid=True), ForeignKey("zones.id"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    organization_id = Column(UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True)
    
    start_time = Column(DateTime(timezone=True), nullable=False)
    end_time = Column(DateTime(timezone=True), nullable=False)
    
    # pending → confirmed (auto o por aprobación) → cancelled
    status = Column(
        SQLEnum(BookingStatus, native_enum=False, length=50),
        default=BookingStatus.CONFIRMED,
        index=True,
    )
    notes = Column(Text, nullable=True)  # Notas opcionales del usuario
    cancellation_reason = Column(Text, nullable=True)  # Motivo de cancelación
    cancelled_at = Column(DateTime, nullable=True)
    
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    user = relationship("User", backref="bookings")
    zone = relationship("Zone", back_populates="bookings")

    def cancel(self, reason: str = None):
        """Cancelar esta reserva"""
        self.status = BookingStatus.CANCELLED
        self.cancellation_reason = reason
        self.cancelled_at = datetime.now(timezone.utc)

    def __repr__(self):
        return f"<Booking zone={self.zone_id} user={self.user_id} {self.start_time}>"
