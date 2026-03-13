"""
Router de zonas comunes — delega la lógica a ZoneService.
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.core.database import get_db
from app.core.deps import (
    get_current_user,
    get_current_admin_or_president,
    get_active_org_id,
    get_filtered_org_ids,
)
from app.models.user import User
from app.schemas.zone import ZoneCreate, ZoneUpdate, ZoneResponse
from app.services.zone_service import ZoneService

router = APIRouter()


@router.get("", response_model=List[ZoneResponse])
def get_zones(
    request: Request,
    zone_type: Optional[str] = None,
    active_only: bool = True,
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=50, le=500),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener zonas comunes de las organizaciones del usuario."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    if not org_ids:
        return []
    return ZoneService(db).list(org_ids, zone_type, active_only, skip=skip, limit=limit)


@router.get("/{zone_id}", response_model=ZoneResponse)
def get_zone(
    request: Request,
    zone_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener detalle de una zona."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    return ZoneService(db).get(zone_id, org_ids)


@router.post("", response_model=ZoneResponse, status_code=status.HTTP_201_CREATED)
def create_zone(
    request: Request,
    zone_data: ZoneCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_or_president),
):
    """Crear una nueva zona (admin/presidente)."""
    org_id = get_active_org_id(request, db, current_user)
    return ZoneService(db).create(zone_data, org_id)


@router.put("/{zone_id}", response_model=ZoneResponse)
def update_zone(
    request: Request,
    zone_id: UUID,
    zone_data: ZoneUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_or_president),
):
    """Actualizar una zona (admin/presidente)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    return ZoneService(db).update(zone_id, zone_data, org_ids)


@router.delete("/{zone_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_zone(
    request: Request,
    zone_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_or_president),
):
    """Desactivar una zona (soft delete)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    ZoneService(db).deactivate(zone_id, org_ids)
