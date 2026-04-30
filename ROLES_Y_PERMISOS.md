# 🔐 Sistema de Roles y Permisos

## Roles Disponibles

El sistema define **3 roles** jerárquicos dentro de cada urbanización:

| Rol | Descripción | Nivel |
|-----|-------------|-------|
| **ADMIN** | Administrador global de la plataforma | Máximo |
| **PRESIDENT** | Presidente de la urbanización | Medio |
| **NEIGHBOR** | Vecino / residente | Básico |

### 👨‍💼 ADMIN (Administrador)
- Permisos totales sobre toda la plataforma
- Gestionar usuarios y organizaciones
- Gestionar invitaciones
- Crear/gestionar zonas comunes
- Aprobar/cancelar cualquier reserva
- Resolver/eliminar cualquier incidencia
- Publicar/eliminar posts y documentos
- Ver estadísticas globales

### 🏛️ PRESIDENT (Presidente)
- Permisos elevados dentro de su urbanización
- Gestionar invitaciones de su urbanización
- Crear/gestionar zonas comunes
- Aprobar/cancelar reservas
- Cambiar estado de incidencias
- Publicar/eliminar posts y documentos
- Ver estadísticas de su urbanización

### 🏠 NEIGHBOR (Vecino)
- Permisos básicos de uso
- Crear y cancelar sus propias reservas
- Crear incidencias y comentar
- Publicar y eliminar sus propios posts
- Ver documentos (solo lectura)
- Consultar calendario y notificaciones

---

## Matriz de Permisos

| Funcionalidad | ADMIN | PRESIDENT | NEIGHBOR |
|--------------|:-----:|:---------:|:--------:|
| **Usuarios & Invitaciones** | | | |
| Enviar invitaciones | ✅ | ✅ | ❌ |
| Revocar invitaciones | ✅ | ✅ | ❌ |
| Ver lista de usuarios | ✅ | ✅ | ❌ |
| Eliminar usuarios | ✅ | ❌ | ❌ |
| **Zonas & Reservas** | | | |
| Crear/editar zonas | ✅ | ✅ | ❌ |
| Crear reserva propia | ✅ | ✅ | ✅ |
| Cancelar reserva propia | ✅ | ✅ | ✅ |
| Cancelar cualquier reserva | ✅ | ✅ | ❌ |
| Aprobar reservas | ✅ | ✅ | ❌ |
| **Incidencias** | | | |
| Crear incidencia | ✅ | ✅ | ✅ |
| Cambiar estado | ✅ | ✅ | ❌ |
| Eliminar cualquier incidencia | ✅ | ❌ | ❌ |
| Eliminar incidencia propia | ✅ | ✅ | ✅ |
| **Tablón de Anuncios** | | | |
| Crear post | ✅ | ✅ | ✅ |
| Eliminar cualquier post | ✅ | ✅ | ❌ |
| Eliminar post propio | ✅ | ✅ | ✅ |
| **Documentos** | | | |
| Subir documentos | ✅ | ✅ | ❌ |
| Eliminar documentos | ✅ | ✅ | ❌ |
| Ver/descargar documentos | ✅ | ✅ | ✅ |
| **Notificaciones** | | | |
| Recibir notificaciones | ✅ | ✅ | ✅ |
| **Calendario** | | | |
| Ver calendario | ✅ | ✅ | ✅ |

---

## Control en Frontend

### UserRole Enum (`lib/core/data/models/user_role.dart`)

```dart
enum UserRole {
  admin, president, neighbor;

  bool get isAdmin => this == UserRole.admin;
  bool get isPresident => this == UserRole.president;
  bool get isNeighbor => this == UserRole.neighbor;
  bool get isAdminOrPresident => isAdmin || isPresident;
}
```

### Uso en UI

```dart
// Verificar permisos
final role = currentUser.role;

// Solo admin o presidente pueden subir documentos
if (role.isAdminOrPresident) {
  // Mostrar botón de subir documento
}

// Cancelar reserva: propia o admin/presidente
canCancel: booking.userId == currentUser.id || role.isAdminOrPresident

// Eliminar post: propio o admin/presidente
canDelete: post.authorId == currentUser.id || role.isAdminOrPresident
```

---

## Control en Backend

### Roles definidos (`backend/app/models/user.py`)

```python
class UserRole(str, enum.Enum):
    ADMIN = "admin"
    PRESIDENT = "president"
    NEIGHBOR = "neighbor"
```

### Dependencies de seguridad (`backend/app/core/security.py`)

```python
# Cualquier usuario autenticado
current_user = Depends(get_current_active_user)

# Solo admin
current_admin = Depends(get_current_active_admin)

# Admin o presidente
current_admin_or_president = Depends(get_current_admin_or_president)
```

### Ejemplo en endpoints

```python
# Solo admin o presidente pueden aprobar reservas
@router.post("/{booking_id}/approve")
def approve_booking(
    booking_id: UUID,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db)
):
    ...

# Cualquier usuario puede crear, pero verificación de propiedad para cancelar
@router.post("/{booking_id}/cancel")
def cancel_booking(
    booking_id: UUID,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    booking = db.query(Booking).get(booking_id)
    if booking.user_id != current_user.id:
        if current_user.role not in [UserRole.ADMIN, UserRole.PRESIDENT]:
            raise HTTPException(403, "No tienes permiso")
    ...
```

---

## Usuario de Prueba

| Email | Password | Rol |
|-------|----------|-----|
| admin@tfg.com | admin123 | ADMIN |

Este usuario tiene todos los permisos y puede probar todas las funcionalidades.
