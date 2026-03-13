"""
Modelo IncidentComment - Comentarios/seguimiento de incidencias.

Permite a vecinos, presidentes y admins añadir comentarios a una incidencia,
creando un historial de seguimiento completo.
"""
from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid

from app.core.database import Base


class IncidentComment(Base):
    __tablename__ = "incident_comments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    incident_id = Column(UUID(as_uuid=True), ForeignKey("incidents.id", ondelete="CASCADE"), nullable=False, index=True)
    author_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    image_url = Column(String, nullable=True)  # Foto opcional en el comentario
    
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # Relationships
    incident = relationship("Incident", back_populates="comments")
    author = relationship("User", backref="incident_comments")

    def __repr__(self):
        return f"<IncidentComment {self.id} on incident {self.incident_id}>"
