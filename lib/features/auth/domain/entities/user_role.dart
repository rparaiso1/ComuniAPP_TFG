/// Roles del sistema: admin, presidente, vecino
enum UserRole {
  admin,
  president, // Presidente de la comunidad
  neighbor;  // Vecino (propietario o inquilino)

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.president:
        return 'president';
      case UserRole.neighbor:
        return 'neighbor';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.president:
        return 'Presidente';
      case UserRole.neighbor:
        return 'Vecino';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'president':
        return UserRole.president;
      case 'neighbor':
        return UserRole.neighbor;
      // Compatibilidad con roles antiguos
      case 'owner':
      case 'tenant':
      case 'family':
      case 'student':
        return UserRole.neighbor;
      case 'teacher':
        return UserRole.president;
      default:
        return UserRole.neighbor;
    }
  }

  // Permisos basados en rol
  bool get isAdmin => this == UserRole.admin;
  bool get isPresident => this == UserRole.president;
  bool get isNeighbor => this == UserRole.neighbor;

  /// Admin o presidente (gestión)
  bool get isAdminOrPresident => isAdmin || isPresident;

  bool get canManageUsers => isAdmin;
  bool get canManageInvitations => isAdminOrPresident;
  bool get canDeleteAnyPost => isAdminOrPresident;
  bool get canDeleteAnyIncident => isAdminOrPresident;
  bool get canManageDocuments => isAdminOrPresident;
  bool get canApproveDocuments => isAdminOrPresident;
  bool get canManageZones => isAdminOrPresident;
  bool get canApproveBookings => isAdminOrPresident;
  bool get canCreateBookings => true; // Todos
  bool get canCreateIncidents => true; // Todos
  bool get canViewDocuments => true; // Todos
}

