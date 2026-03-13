enum IncidentPriority {
  low,
  medium,
  high,
  critical,
}

extension IncidentPriorityExtension on IncidentPriority {
  String get value {
    switch (this) {
      case IncidentPriority.low:
        return 'low';
      case IncidentPriority.medium:
        return 'medium';
      case IncidentPriority.high:
        return 'high';
      case IncidentPriority.critical:
        return 'critical';
    }
  }

  String get displayName {
    switch (this) {
      case IncidentPriority.low:
        return 'Baja';
      case IncidentPriority.medium:
        return 'Media';
      case IncidentPriority.high:
        return 'Alta';
      case IncidentPriority.critical:
        return 'Urgente';
    }
  }

  static IncidentPriority fromString(String value) {
    switch (value) {
      case 'low':
        return IncidentPriority.low;
      case 'medium':
        return IncidentPriority.medium;
      case 'high':
        return IncidentPriority.high;
      case 'critical':
        return IncidentPriority.critical;
      default:
        return IncidentPriority.medium;
    }
  }
}
