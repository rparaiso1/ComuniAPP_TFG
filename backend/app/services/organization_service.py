"""
Servicio de organizaciones — CRUD + membresía de usuarios.
"""
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List, Optional

from app.models.organization import Organization
from app.models.user import User
from app.models.user_organization import UserOrganization
from app.core.exceptions import ServiceError, NotFoundError, ForbiddenError, ConflictError


class OrganizationService:

    def __init__(self, db: Session):
        self.db = db

    def create(self, data: dict) -> Organization:
        existing = self.db.query(Organization).filter(Organization.code == data["code"]).first()
        if existing:
            raise ConflictError(f"Organization with code {data['code']} already exists")
        org = Organization(**data)
        self.db.add(org)
        self.db.commit()
        self.db.refresh(org)
        return org

    def list(self, skip: int = 0, limit: int = 100) -> List[Organization]:
        return self.db.query(Organization).offset(skip).limit(limit).all()

    def get(self, org_id: UUID) -> Organization:
        org = self.db.query(Organization).filter(Organization.id == org_id).first()
        if not org:
            raise NotFoundError("Organization not found")
        return org

    def get_for_user(self, org_id: UUID, user_id: UUID, is_admin: bool) -> Organization:
        org = self.get(org_id)
        if not is_admin:
            belongs = self.db.query(UserOrganization).filter(
                UserOrganization.user_id == user_id,
                UserOrganization.organization_id == org_id,
                UserOrganization.is_active == True,
            ).first()
            if not belongs:
                raise ForbiddenError("User does not have access to this organization")
        return org

    def get_user_organizations(self, user_id: UUID) -> list:
        rows = (
            self.db.query(UserOrganization, Organization)
            .join(Organization, UserOrganization.organization_id == Organization.id)
            .filter(
                UserOrganization.user_id == user_id,
                UserOrganization.is_active == True,
                Organization.is_active == True,
            )
            .all()
        )
        return [
            {
                "user_org": uo,
                "organization": org,
            }
            for uo, org in rows
        ]

    def update(self, org_id: UUID, update_data: dict) -> Organization:
        org = self.get(org_id)
        for field, value in update_data.items():
            setattr(org, field, value)
        self.db.commit()
        self.db.refresh(org)
        return org

    def deactivate(self, org_id: UUID) -> None:
        org = self.get(org_id)
        org.is_active = False
        self.db.commit()

    def add_user(self, org_id: UUID, user_id: UUID, role: str, dwelling: str = None) -> str:
        org = self.get(org_id)
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise NotFoundError("User not found")

        existing = self.db.query(UserOrganization).filter(
            UserOrganization.user_id == user_id,
            UserOrganization.organization_id == org_id,
        ).first()
        if existing:
            existing.is_active = True
            existing.role = role
            existing.dwelling = dwelling
            self.db.commit()
            return "User reactivated in organization"

        user_org = UserOrganization(
            user_id=user_id,
            organization_id=org_id,
            role=role,
            dwelling=dwelling,
        )
        self.db.add(user_org)
        self.db.commit()
        return "User added to organization successfully"

    def remove_user(self, org_id: UUID, user_id: UUID) -> None:
        user_org = self.db.query(UserOrganization).filter(
            UserOrganization.user_id == user_id,
            UserOrganization.organization_id == org_id,
        ).first()
        if not user_org:
            raise NotFoundError("User not found in organization")
        user_org.is_active = False
        self.db.commit()
