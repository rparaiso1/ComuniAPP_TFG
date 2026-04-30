"""
Modelo Zone - Zonas comunes de una comunidad.

Cada Zone representa un recurso reservable (piscina, pista de pádel, sala, etc.)
vinculado a una organización/comunidad.

Para añadir un nuevo tipo de zona, basta con crear una instancia con zone_type
correspondiente. No requiere cambios de código.
"""
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Boolean, Integer, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone, time
import uuid

from app.core.database import Base


class Zone(Base):
    __tablename__ = "zones"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)  # "Piscina comunitaria"
    zone_type = Column(String(100), nullable=False)  # pool, court, room, gym, etc.
    description = Column(Text, nullable=True)
    organization_id = Column(UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True)
    
    # Configuración de reservas
    max_capacity = Column(Integer, nullable=True)  # Aforo máximo
    max_booking_hours = Column(Integer, default=2)  # Duración máxima reserva en horas
    max_bookings_per_user_day = Column(Integer, default=1)  # Máx reservas por usuario/día
    advance_booking_days = Column(Integer, default=30)  # Con cuántos días de antelación se puede reservar
    requires_approval = Column(Boolean, default=False)  # ¿Requiere aprobación del admin/presidente?
    
    # Horarios de disponibilidad
    available_from = Column(Time, default=time(8, 0))   # Hora apertura
    available_until = Column(Time, default=time(22, 0))  # Hora cierre
    
    # Estado
    is_active = Column(Boolean, default=True)
    
    # Timestamps
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    organization = relationship("Organization", backref="zones")
    bookings = relationship("Booking", back_populates="zone", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Zone {self.name} ({self.zone_type})>"
