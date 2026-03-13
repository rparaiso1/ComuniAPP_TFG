"""
Router de invitaciones — delega la lógica a InvitationService.
"""
from fastapi import APIRouter, Depends, Request, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.core.database import get_db
from app.core.deps import get_current_admin_or_president, get_active_org_id, get_filtered_org_ids
from app.models.user import User
from app.schemas.invitation import (
    InvitationCreate, InvitationResponse,
    RegisterWithInvitationRequest, InvitationVerifyResponse,
)
from app.services.invitation_service import InvitationService

router = APIRouter()


@router.post("", response_model=InvitationResponse, status_code=status.HTTP_201_CREATED)
def create_invitation(
    request: Request,
    invitation_data: InvitationCreate,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Crear una invitación (admin/presidente)."""
    org_id = get_active_org_id(request, db, current_user)
    inv = InvitationService(db).create(invitation_data, org_id)
    return InvitationService.to_response(inv, include_token=True)


@router.get("/verify/{token}", response_model=InvitationVerifyResponse)
def verify_invitation(token: str, db: Session = Depends(get_db)):
    """Verificar si una invitación es válida (público)."""
    result = InvitationService(db).verify(token)
    return InvitationVerifyResponse(**result)


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_with_invitation(
    request: RegisterWithInvitationRequest,
    db: Session = Depends(get_db),
):
    """Registrarse usando una invitación válida."""
    user = InvitationService(db).register_with_token(request)
    return {
        "success": True,
        "message": "Registro completado correctamente",
        "user": {
            "id": str(user.id),
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role.value if hasattr(user.role, "value") else user.role,
            "dwelling": user.dwelling,
        },
    }


@router.get("", response_model=List[InvitationResponse])
def list_invitations(
    request: Request,
    status_filter: Optional[str] = None,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Listar invitaciones (admin/presidente)."""
    org_id = get_active_org_id(request, db, current_user)
    invitations = InvitationService(db).list(org_id, status_filter)
    return [InvitationService.to_response(inv, include_token=True) for inv in invitations]


@router.delete("/{invitation_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_invitation(
    request: Request,
    invitation_id: UUID,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Eliminar/revocar una invitación."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    InvitationService(db).delete(invitation_id, org_ids)
