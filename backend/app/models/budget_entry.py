"""
Modelo BudgetEntry - Partidas presupuestarias de una comunidad.

Permite gestionar ingresos y gastos de la comunidad,
visualizando distribución por categoría y evolución mensual.
"""
from sqlalchemy import Column, String, Date, DateTime, ForeignKey, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from app.core.database import Base


class BudgetEntry(Base):
    __tablename__ = "budget_entries"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    organization_id = Column(
        UUID(as_uuid=True), ForeignKey("organizations.id", ondelete="CASCADE"),
        nullable=False, index=True,
    )
    entry_date = Column(Date, nullable=False)
    category = Column(String(100), nullable=False)         # "Mantenimiento", "Electricidad", etc.
    concept = Column(String(300), nullable=False)           # Descripción de la partida
    amount = Column(Numeric(12, 2), nullable=False)         # Importe en euros
    entry_type = Column(String(10), nullable=False)         # "income" | "expense"
    provider = Column(String(200), nullable=True)           # Proveedor/Pagador
    detail = Column(String(500), nullable=True)             # Detalle adicional de la partida
    uploaded_by_id = Column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relaciones
    organization = relationship("Organization")
    uploaded_by = relationship("User")
