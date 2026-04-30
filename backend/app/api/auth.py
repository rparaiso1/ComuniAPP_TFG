"""
Router de autenticación — delega toda la lógica a AuthService.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from uuid import UUID
from pydantic import BaseModel
import logging

from app.core.database import get_db
from app.core.deps import get_current_user
from app.core.security import decode_access_token
from app.core.security_utils import check_auth_rate_limit, InputSanitizer
from app.models.user import User
from app.schemas.user import (
    UserCreate, UserResponse, UserWithOrganizationsResponse,
    Token, LoginRequest, UserUpdate, ChangePasswordRequest,
)
from app.services.auth_service import AuthService

router = APIRouter()
logger = logging.getLogger(__name__)


class RefreshTokenRequest(BaseModel):
    refresh_token: str


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, request: Request, db: Session = Depends(get_db)):
    """Registrar un nuevo usuario (solo rol NEIGHBOR)."""
    await check_auth_rate_limit(request)
    user = AuthService(db).register(user_data)
    logger.info(f"User registered: {user.email}")
    return user


@router.post("/login", response_model=Token)
async def login(login_data: LoginRequest, request: Request, db: Session = Depends(get_db)):
    """Login — devuelve access_token + refresh_token."""
    await check_auth_rate_limit(request)
    if not InputSanitizer.validate_email(login_data.email):
        raise HTTPException(status_code=400, detail="Invalid email format")
    svc = AuthService(db)
    user = svc.authenticate(login_data.email, login_data.password)
    tokens = svc.create_tokens(user.id)
    logger.info(f"User logged in: {user.email}")
    return tokens


@router.post("/refresh", response_model=Token)
async def refresh_token(body: RefreshTokenRequest, request: Request, db: Session = Depends(get_db)):
    """Obtener nuevos tokens usando un refresh_token válido."""
    await check_auth_rate_limit(request)
    payload = decode_access_token(body.refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    user = db.query(User).filter(User.id == UUID(payload["sub"])).first()
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="User not found or inactive")
    return AuthService(db).create_tokens(user.id)


@router.get("/me", response_model=UserWithOrganizationsResponse)
def get_current_user_info(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Obtener usuario actual con sus organizaciones."""
    return AuthService(db).get_user_with_organizations(current_user)


@router.put("/me", response_model=UserResponse)
def update_profile(
    user_data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Actualizar perfil del usuario actual."""
    return AuthService(db).update_profile(current_user, user_data)


@router.post("/change-password")
async def change_password(
    data: ChangePasswordRequest,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Cambiar contraseña del usuario actual."""
    await check_auth_rate_limit(request)
    AuthService(db).change_password(current_user, data.current_password, data.new_password)
    return {"message": "Contraseña actualizada correctamente"}


@router.post("/logout")
def logout():
    """Logout (el cliente descarta el token)."""
    return {"message": "Successfully logged out"}
