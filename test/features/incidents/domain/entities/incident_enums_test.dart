import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/incidents/domain/entities/incident_status.dart';
import 'package:comuniapp/features/incidents/domain/entities/incident_priority.dart';

void main() {
  group('IncidentStatus', () {
    group('value', () {
      test('open returns "open"', () {
        expect(IncidentStatus.open.value, 'open');
      });

      test('inProgress returns "in_progress"', () {
        expect(IncidentStatus.inProgress.value, 'in_progress');
      });

      test('resolved returns "resolved"', () {
        expect(IncidentStatus.resolved.value, 'resolved');
      });

      test('closed returns "closed"', () {
        expect(IncidentStatus.closed.value, 'closed');
      });
    });

    group('displayName', () {
      test('open displays "Abierta"', () {
        expect(IncidentStatus.open.displayName, 'Abierta');
      });

      test('inProgress displays "En Progreso"', () {
        expect(IncidentStatus.inProgress.displayName, 'En Progreso');
      });

      test('resolved displays "Resuelta"', () {
        expect(IncidentStatus.resolved.displayName, 'Resuelta');
      });

      test('closed displays "Cerrada"', () {
        expect(IncidentStatus.closed.displayName, 'Cerrada');
      });
    });

    group('fromString', () {
      test('parses "open" correctly', () {
        expect(IncidentStatusExtension.fromString('open'),
            IncidentStatus.open);
      });

      test('parses "in_progress" correctly', () {
        expect(IncidentStatusExtension.fromString('in_progress'),
            IncidentStatus.inProgress);
      });

      test('parses "resolved" correctly', () {
        expect(IncidentStatusExtension.fromString('resolved'),
            IncidentStatus.resolved);
      });

      test('parses "closed" correctly', () {
        expect(IncidentStatusExtension.fromString('closed'),
            IncidentStatus.closed);
      });

      test('defaults to open for unknown value', () {
        expect(IncidentStatusExtension.fromString('unknown'),
            IncidentStatus.open);
      });

      test('defaults to open for empty string', () {
        expect(IncidentStatusExtension.fromString(''),
            IncidentStatus.open);
      });
    });

    group('roundtrip', () {
      test('fromString(value) returns original enum for all values', () {
        for (final status in IncidentStatus.values) {
          expect(IncidentStatusExtension.fromString(status.value), status);
        }
      });
    });
  });

  group('IncidentPriority', () {
    group('value', () {
      test('low returns "low"', () {
        expect(IncidentPriority.low.value, 'low');
      });

      test('medium returns "medium"', () {
        expect(IncidentPriority.medium.value, 'medium');
      });

      test('high returns "high"', () {
        expect(IncidentPriority.high.value, 'high');
      });

      test('critical returns "critical"', () {
        expect(IncidentPriority.critical.value, 'critical');
      });
    });

    group('displayName', () {
      test('low displays "Baja"', () {
        expect(IncidentPriority.low.displayName, 'Baja');
      });

      test('medium displays "Media"', () {
        expect(IncidentPriority.medium.displayName, 'Media');
      });

      test('high displays "Alta"', () {
        expect(IncidentPriority.high.displayName, 'Alta');
      });

      test('critical displays "Urgente"', () {
        expect(IncidentPriority.critical.displayName, 'Urgente');
      });
    });

    group('fromString', () {
      test('parses "low" correctly', () {
        expect(IncidentPriorityExtension.fromString('low'),
            IncidentPriority.low);
      });

      test('parses "medium" correctly', () {
        expect(IncidentPriorityExtension.fromString('medium'),
            IncidentPriority.medium);
      });

      test('parses "high" correctly', () {
        expect(IncidentPriorityExtension.fromString('high'),
            IncidentPriority.high);
      });

      test('parses "critical" correctly', () {
        expect(IncidentPriorityExtension.fromString('critical'),
            IncidentPriority.critical);
      });

      test('defaults to medium for unknown value', () {
        expect(IncidentPriorityExtension.fromString('unknown'),
            IncidentPriority.medium);
      });

      test('defaults to medium for empty string', () {
        expect(IncidentPriorityExtension.fromString(''),
            IncidentPriority.medium);
      });
    });

    group('roundtrip', () {
      test('fromString(value) returns original enum for all values', () {
        for (final priority in IncidentPriority.values) {
          expect(IncidentPriorityExtension.fromString(priority.value), priority);
        }
      });
    });
  });
}
