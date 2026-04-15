"""
Servicio de zonas comunes — CRUD con filtrado por organización.
"""
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List, Optional

from app.models.zone import Zone
from app.schemas.zone import ZoneCreate, ZoneUpdate
from app.core.exceptions import ServiceError, NotFoundError, ConflictError


class ZoneService:

    def __init__(self, db: Session):
        self.db = db

    def list(
        self, org_ids: List[UUID],
        zone_type: Optional[str] = None,
        active_only: bool = True,
        skip: int = 0,
        limit: int = 50,
    ) -> List[Zone]:
        query = self.db.query(Zone).filter(Zone.organization_id.in_(org_ids))
        if active_only:
            query = query.filter(Zone.is_active == True)
        if zone_type:
            query = query.filter(Zone.zone_type == zone_type.lower())
        return query.order_by(Zone.name).offset(skip).limit(limit).all()

    def get(self, zone_id: UUID, org_ids: List[UUID]) -> Zone:
        zone = self.db.query(Zone).filter(
            Zone.id == zone_id,
            Zone.organization_id.in_(org_ids),
        ).first()
        if not zone:
            raise NotFoundError("Zona no encontrada")
        return zone

    def create(self, data: ZoneCreate, org_id: UUID) -> Zone:
        # Check for duplicate name within the same organization
        existing = self.db.query(Zone).filter(
            Zone.organization_id == org_id,
            Zone.name.ilike(data.name.strip()),
        ).first()
        if existing:
            raise ConflictError("Ya existe una zona con ese nombre en esta comunidad")
        zone = Zone(**data.model_dump(), organization_id=org_id)
        self.db.add(zone)
        self.db.commit()
        self.db.refresh(zone)
        return zone

    def update(self, zone_id: UUID, data: ZoneUpdate, org_ids: List[UUID]) -> Zone:
        zone = self.get(zone_id, org_ids)
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(zone, field, value)
        self.db.commit()
        self.db.refresh(zone)
        return zone

    def deactivate(self, zone_id: UUID, org_ids: List[UUID]) -> None:
        zone = self.get(zone_id, org_ids)
        zone.is_active = False
        self.db.commit()
