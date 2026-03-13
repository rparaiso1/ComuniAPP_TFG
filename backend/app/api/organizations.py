"""
Router de organizaciones — delega la lógica a OrganizationService.
"""
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.core.database import get_db
from app.core.deps import get_current_user, get_current_active_admin
from app.models.user import User, UserRole
from app.schemas.organization import (
    OrganizationCreate, OrganizationResponse, OrganizationUpdate,
    UserOrganizationResponse,
)
from app.services.organization_service import OrganizationService

router = APIRouter()


@router.post("", response_model=OrganizationResponse, status_code=status.HTTP_201_CREATED)
async def create_organization(
    organization: OrganizationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    """Crear organización (solo Admin)."""
    return OrganizationService(db).create(organization.model_dump())


@router.get("", response_model=List[OrganizationResponse])
async def list_organizations(
    skip: int = 0, limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    """Listar todas las organizaciones (solo Admin)."""
    return OrganizationService(db).list(skip, limit)


@router.get("/my", response_model=List[UserOrganizationResponse])
async def get_my_organizations(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener organizaciones del usuario actual."""
    rows = OrganizationService(db).get_user_organizations(current_user.id)
    return [
        UserOrganizationResponse(
            organization_id=r["user_org"].organization_id,
            organization_name=r["organization"].name,
            organization_code=r["organization"].code,
            role=r["user_org"].role,
            dwelling=r["user_org"].dwelling,
            is_active=r["user_org"].is_active,
            joined_at=r["user_org"].joined_at,
        )
        for r in rows
    ]


@router.get("/{organization_id}", response_model=OrganizationResponse)
async def get_organization(
    organization_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener detalle de una organización."""
    return OrganizationService(db).get_for_user(
        organization_id, current_user.id,
        current_user.role == UserRole.ADMIN,
    )


@router.patch("/{organization_id}", response_model=OrganizationResponse)
async def update_organization(
    organization_id: UUID,
    organization_update: OrganizationUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    """Actualizar organización (solo Admin)."""
    return OrganizationService(db).update(
        organization_id, organization_update.model_dump(exclude_unset=True),
    )


@router.delete("/{organization_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_organization(
    organization_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    """Desactivar organización (solo Admin)."""
    OrganizationService(db).deactivate(organization_id)


@router.post("/{organization_id}/users/{user_id}", status_code=status.HTTP_201_CREATED)
async def add_user_to_organization(
    organization_id: UUID, user_id: UUID,
    role: str, dwelling: str = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    """Añadir usuario a organización (solo Admin)."""
    msg = OrganizationService(db).add_user(organization_id, user_id, role, dwelling)
    return {"message": msg}


@router.delete("/{organization_id}/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_user_from_organization(
    organization_id: UUID, user_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    """Eliminar usuario de organización (solo Admin)."""
    OrganizationService(db).remove_user(organization_id, user_id)
