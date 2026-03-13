enum IncidentStatus {
  open,
  inProgress,
  resolved,
  closed,
}

extension IncidentStatusExtension on IncidentStatus {
  String get value {
    switch (this) {
      case IncidentStatus.open:
        return 'open';
      case IncidentStatus.inProgress:
        return 'in_progress';
      case IncidentStatus.resolved:
        return 'resolved';
      case IncidentStatus.closed:
        return 'closed';
    }
  }

  String get displayName {
    switch (this) {
      case IncidentStatus.open:
        return 'Abierta';
      case IncidentStatus.inProgress:
        return 'En Progreso';
      case IncidentStatus.resolved:
        return 'Resuelta';
      case IncidentStatus.closed:
        return 'Cerrada';
    }
  }

  static IncidentStatus fromString(String value) {
    switch (value) {
      case 'open':
        return IncidentStatus.open;
      case 'in_progress':
        return IncidentStatus.inProgress;
      case 'resolved':
        return IncidentStatus.resolved;
      case 'closed':
        return IncidentStatus.closed;
      default:
        return IncidentStatus.open;
    }
  }
}
