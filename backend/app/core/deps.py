from datetime import datetime, timezone
from fastapi import Depends, HTTPException, Request, status, Header
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import decode_access_token
from app.models.user import User, UserRole
from app.models.organization import Organization
from app.models.user_organization import UserOrganization
from uuid import UUID
from typing import Optional, List

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


def get_user_organization_ids(db: Session, user_id: UUID) -> List[UUID]:
    """Get all organization IDs that a user belongs to"""
    user_orgs = db.query(UserOrganization).filter(
        UserOrganization.user_id == user_id,
        UserOrganization.is_active == True
    ).all()
    return [uo.organization_id for uo in user_orgs]


def get_user_first_organization_id(db: Session, user_id: UUID) -> Optional[UUID]:
    """Get the first organization ID for a user (for simple queries)"""
    user_org = db.query(UserOrganization).filter(
        UserOrganization.user_id == user_id,
        UserOrganization.is_active == True
    ).first()
    return user_org.organization_id if user_org else None


def get_active_org_id(
    request: Request,
    db: Session,
    user: User,
) -> UUID:
    """
    Get the active organization ID from the X-Organization-ID header.
    Falls back to the user's first organization if header is not provided.
    Validates user membership in the specified org.
    """
    header_val = request.headers.get("x-organization-id")
    if header_val:
        try:
            org_id = UUID(header_val)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid X-Organization-ID format",
            )
        # Validate membership
        user_org = db.query(UserOrganization).filter(
            UserOrganization.user_id == user.id,
            UserOrganization.organization_id == org_id,
            UserOrganization.is_active == True,
        ).first()
        if not user_org:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No tienes acceso a esta organización",
            )
        return org_id
    # Fallback: first org
    org_id = get_user_first_organization_id(db, user.id)
    if not org_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Usuario sin organización asignada",
        )
    return org_id


def get_filtered_org_ids(
    request: Request,
    db: Session,
    user: User,
) -> List[UUID]:
    """
    If X-Organization-ID header is present, return only that org_id (validated).
    Otherwise return all user org_ids (backward compatible).
    """
    header_val = request.headers.get("x-organization-id")
    if header_val:
        return [get_active_org_id(request, db, user)]
    return get_user_organization_ids(db, user.id)


async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    """Get current authenticated user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception

    # Rechazar refresh tokens usados como access tokens
    if payload.get("type") == "refresh":
        raise credentials_exception

    user_id: str = payload.get("sub")
    if user_id is None:
        raise credentials_exception
    
    user = db.query(User).filter(User.id == UUID(user_id)).first()
    if user is None:
        raise credentials_exception
    
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Inactive user")
    
    # Check tenant contract expiration
    if user.contract_end:
        contract_end = user.contract_end
        if contract_end.tzinfo is None:
            contract_end = contract_end.replace(tzinfo=timezone.utc)
        if contract_end < datetime.now(timezone.utc):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Tu contrato ha expirado. Contacta con el administrador.",
            )
    
    return user


async def get_current_active_admin(
    current_user: User = Depends(get_current_user)
) -> User:
    """Verify that current user is an admin"""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions. Admin role required."
        )
    return current_user


def is_admin_or_president_in_org(db: Session, user: User, org_ids: List[UUID] = None) -> bool:
    """
    Check if user is admin/president in the SPECIFIC organizations being accessed.
    If org_ids is provided, checks role in those specific orgs.
    Falls back to checking any org membership if org_ids is not provided.
    """
    if org_ids:
        org_role = db.query(UserOrganization).filter(
            UserOrganization.user_id == user.id,
            UserOrganization.organization_id.in_(org_ids),
            UserOrganization.role.in_([UserRole.ADMIN, UserRole.PRESIDENT]),
            UserOrganization.is_active == True
        ).first()
        return org_role is not None
    # Fallback: check global role then any org (backward compat)
    if user.role in (UserRole.ADMIN, UserRole.PRESIDENT):
        return True
    org_role = db.query(UserOrganization).filter(
        UserOrganization.user_id == user.id,
        UserOrganization.role.in_([UserRole.ADMIN, UserRole.PRESIDENT]),
        UserOrganization.is_active == True
    ).first()
    return org_role is not None


async def get_current_admin_or_president(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> User:
    """Verify that current user is admin or president (globally or in org)"""
    if not is_admin_or_president_in_org(db, current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions. Admin or President role required."
        )
    return current_user


async def get_current_organization(
    x_organization_id: Optional[str] = Header(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
) -> Organization:
    """
    Get current organization from header X-Organization-ID.
    Validates that user has access to this organization.
    """
    if not x_organization_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Organization ID is required in X-Organization-ID header"
        )
    
    try:
        org_id = UUID(x_organization_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid organization ID format"
        )
    
    # Check if organization exists
    organization = db.query(Organization).filter(Organization.id == org_id).first()
    if not organization:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Organization not found"
        )
    
    if not organization.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Organization is not active"
        )
    
    # Check if user belongs to this organization
    user_org = db.query(UserOrganization).filter(
        UserOrganization.user_id == current_user.id,
        UserOrganization.organization_id == org_id,
        UserOrganization.is_active == True
    ).first()
    
    if not user_org:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User does not have access to this organization"
        )
    
    return organization
