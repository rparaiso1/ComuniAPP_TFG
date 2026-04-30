from sqlalchemy import Column, String, DateTime, Text, Boolean
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime, timezone
import uuid

from app.core.database import Base


class Organization(Base):
    """
    Tabla de organizaciones/urbanizaciones.
    Permite multi-tenancy donde cada urbanización tiene sus propios datos.
    """
    __tablename__ = "organizations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)  # "Urbanización Los Pinos"
    code = Column(String, unique=True, nullable=False, index=True)  # "URB001"
    address = Column(Text, nullable=True)
    logo_url = Column(String, nullable=True)
    primary_color = Column(String, nullable=True, default="#6366F1")  # Color hex
    
    # Contact info
    phone = Column(String, nullable=True)
    email = Column(String, nullable=True)
    
    # Status
    is_active = Column(Boolean, default=True)
    
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f"<Organization {self.name} ({self.code})>"
