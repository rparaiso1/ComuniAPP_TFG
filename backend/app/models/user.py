from sqlalchemy import Column, String, Boolean, DateTime, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime, timezone
import uuid
import enum
from app.core.database import Base


class UserRole(str, enum.Enum):
    """
    User roles - stored as UPPERCASE in database.
    
    Escalabilidad: para añadir un nuevo rol, basta con añadir una nueva entrada aquí
    y definir sus permisos en RolePermissions.
    """
    ADMIN = "ADMIN"          # Administrador global - gestiona varias comunidades
    PRESIDENT = "PRESIDENT"  # Presidente de comunidad - gestiona una comunidad
    NEIGHBOR = "NEIGHBOR"    # Vecino (propietario o inquilino)
    
    @classmethod
    def _missing_(cls, value):
        """Handle case-insensitive lookup and legacy role mapping"""
        if isinstance(value, str):
            upper_value = value.upper()
            # Mapeo de roles legacy para compatibilidad
            legacy_map = {
                "OWNER": "PRESIDENT",
                "TENANT": "NEIGHBOR",
                "TEACHER": "NEIGHBOR",
                "STUDENT": "NEIGHBOR",
                "FAMILY": "NEIGHBOR",
            }
            mapped = legacy_map.get(upper_value, upper_value)
            for member in cls:
                if member.value == mapped:
                    return member
        return None

    @property
    def display_name(self) -> str:
        """Nombre legible del rol para UI"""
        names = {
            "ADMIN": "Administrador",
            "PRESIDENT": "Presidente",
            "NEIGHBOR": "Vecino",
        }
        return names.get(self.value, self.value)

    @property
    def is_admin_or_president(self) -> bool:
        """Shortcut para verificar roles con permisos elevados"""
        return self in (UserRole.ADMIN, UserRole.PRESIDENT)


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    phone = Column(String, nullable=True)
    dwelling = Column(String, nullable=True)  # Vivienda asignada
    role = Column(SQLEnum(UserRole), nullable=False, default=UserRole.NEIGHBOR)
    is_active = Column(Boolean, default=True)
    
    # Tenant specific fields
    contract_end = Column(DateTime, nullable=True)  # For tenants, when access expires
    
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    @property
    def name(self):
        """Alias para full_name para compatibilidad con el frontend"""
        return self.full_name

    def __repr__(self):
        return f"<User {self.email} ({self.role})>"
