"""
Servicio de invitaciones — creación, verificación, registro con token.
"""
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List, Optional

from app.core.security import get_password_hash
from app.models.user import User
from app.models.user_organization import UserOrganization
from app.models.invitation import Invitation, InvitationStatus
from app.schemas.invitation import InvitationCreate, InvitationResponse, RegisterWithInvitationRequest
from app.core.exceptions import ServiceError, NotFoundError, ForbiddenError, ConflictError

# Alias mantenido por retrocompatibilidad con imports existentes
InvitationError = ServiceError


class InvitationService:

    def __init__(self, db: Session):
        self.db = db

    @staticmethod
    def to_response(inv: Invitation, include_token: bool = False) -> InvitationResponse:
        return InvitationResponse(
            id=inv.id,
            email=inv.email,
            full_name=inv.full_name,
            phone=inv.phone,
            dwelling=inv.dwelling,
            role=inv.role,
            status=inv.status.value if hasattr(inv.status, "value") else inv.status,
            token=inv.token if include_token else None,
            created_at=inv.created_at,
            expires_at=inv.expires_at,
        )

    def create(self, data: InvitationCreate, org_id: UUID) -> Invitation:
        existing = self.db.query(Invitation).filter(
            Invitation.email == data.email,
            Invitation.organization_id == org_id,
            Invitation.status == InvitationStatus.PENDING,
        ).first()
        if existing:
            raise ConflictError("Ya existe una invitación pendiente para ese email")

        invitation = Invitation(
            email=data.email,
            full_name=data.full_name,
            phone=data.phone,
            dwelling=data.dwelling,
            role=data.role,
            organization_id=org_id,
            token=Invitation.generate_token(),
        )
        self.db.add(invitation)
        self.db.commit()
        self.db.refresh(invitation)
        return invitation

    def verify(self, token: str) -> dict:
        invitation = self.db.query(Invitation).filter(Invitation.token == token).first()
        if not invitation:
            return {"valid": False, "message": "Invitación no válida", "invitation": None}
        if not invitation.is_valid():
            return {"valid": False, "message": "La invitación ha expirado o ya fue usada", "invitation": None}
        return {
            "valid": True,
            "message": "Invitación válida. Puedes registrarte.",
            "invitation": self.to_response(invitation),
        }

    def register_with_token(self, request: RegisterWithInvitationRequest) -> User:
        invitation = self.db.query(Invitation).filter(Invitation.token == request.token).first()
        if not invitation or not invitation.is_valid():
            raise ServiceError("Invitación no válida o expirada")

        existing_user = self.db.query(User).filter(User.email == invitation.email).first()
        if existing_user:
            raise ConflictError("El usuario ya está registrado")

        new_user = User(
            email=invitation.email,
            hashed_password=get_password_hash(request.password),
            full_name=invitation.full_name,
            phone=invitation.phone,
            dwelling=invitation.dwelling,
            role=invitation.role,
            is_active=True,
        )
        self.db.add(new_user)
        self.db.flush()

        user_org = UserOrganization(
            user_id=new_user.id,
            organization_id=invitation.organization_id,
            role=invitation.role,
            dwelling=invitation.dwelling,
        )
        self.db.add(user_org)
        invitation.mark_as_used()
        self.db.commit()
        self.db.refresh(new_user)
        return new_user

    def list(self, org_id: UUID, status_filter: Optional[str] = None) -> List[Invitation]:
        query = self.db.query(Invitation).filter(Invitation.organization_id == org_id)
        if status_filter:
            query = query.filter(Invitation.status == status_filter)
        return query.order_by(Invitation.created_at.desc()).all()

    def delete(self, invitation_id: UUID, org_ids: List[UUID]) -> None:
        invitation = self.db.query(Invitation).filter(Invitation.id == invitation_id).first()
        if not invitation:
            raise NotFoundError("Invitación no encontrada")
        if invitation.organization_id not in org_ids:
            raise ForbiddenError("No tienes permiso para eliminar esta invitación")
        self.db.delete(invitation)
        self.db.commit()
