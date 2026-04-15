"""
Servicio de autenticación — registro, login, perfil, tokens.
"""
from sqlalchemy.orm import Session
from datetime import timedelta
from uuid import UUID
from typing import Optional

from app.core.security import verify_password, get_password_hash, create_access_token
from app.core.config import settings
from app.core.exceptions import ServiceError, ConflictError, UnauthorizedError
from app.models.user import User
from app.models.user_organization import UserOrganization
from app.models.organization import Organization
from app.schemas.user import UserCreate, UserUpdate


class AuthService:
    """Servicio de autenticación sin dependencias HTTP."""

    def __init__(self, db: Session):
        self.db = db

    # ---- Registro ----

    def register(self, data: UserCreate) -> User:
        existing = self.db.query(User).filter(User.email == data.email).first()
        if existing:
            raise ConflictError("Email already registered", "duplicate_email")

        user = User(
            email=data.email,
            full_name=data.full_name,
            role=data.role,
            hashed_password=get_password_hash(data.password),
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user

    # ---- Login ----

    def authenticate(self, email: str, password: str) -> User:
        user = self.db.query(User).filter(User.email == email).first()
        if not user or not verify_password(password, user.hashed_password):
            raise UnauthorizedError("Incorrect email or password", "invalid_credentials")
        if not user.is_active:
            raise UnauthorizedError("Inactive user", "inactive_user")
        return user

    def create_tokens(self, user_id: UUID) -> dict:
        """Genera access_token y refresh_token."""
        access_token = create_access_token(
            data={"sub": str(user_id), "type": "access"},
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
        )
        refresh_token = create_access_token(
            data={"sub": str(user_id), "type": "refresh"},
            expires_delta=timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
        )
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
        }

    # ---- Perfil ----

    def get_user_with_organizations(self, user: User) -> dict:
        user_orgs = (
            self.db.query(UserOrganization, Organization)
            .join(Organization, UserOrganization.organization_id == Organization.id)
            .filter(
                UserOrganization.user_id == user.id,
                UserOrganization.is_active == True,
                Organization.is_active == True,
            )
            .all()
        )
        organizations = [
            {
                "organization_id": str(uo.organization_id),
                "organization_name": org.name,
                "organization_code": org.code,
                "role": uo.role,
                "dwelling": uo.dwelling,
            }
            for uo, org in user_orgs
        ]
        return {
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name,
            "name": user.full_name,
            "role": user.role,
            "phone": user.phone,
            "dwelling": user.dwelling,
            "is_active": user.is_active,
            "created_at": user.created_at,
            "updated_at": user.updated_at,
            "organizations": organizations,
        }

    def update_profile(self, user: User, data: UserUpdate) -> User:
        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(user, field, value)
        self.db.commit()
        self.db.refresh(user)
        return user

    def change_password(self, user: User, current_password: str, new_password: str) -> None:
        if not verify_password(current_password, user.hashed_password):
            raise ServiceError("Contraseña actual incorrecta", "wrong_password")
        user.hashed_password = get_password_hash(new_password)
        self.db.commit()
