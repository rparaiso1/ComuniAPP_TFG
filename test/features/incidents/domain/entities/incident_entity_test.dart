import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/incidents/domain/entities/incident_entity.dart';

void main() {
  final baseDate = DateTime(2026, 2, 20, 14, 30);

  IncidentEntity createIncident({
    String id = 'inc-1',
    String title = 'Avería ascensor',
    String description = 'El ascensor no funciona desde ayer',
    String priority = 'alta',
    String status = 'open',
    String? location = 'Portal 2',
    String userId = 'user-1',
    String userName = 'Pedro Ruiz',
    String? assignedToId,
    String? assignedToName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncidentEntity(
      id: id,
      title: title,
      description: description,
      priority: priority,
      status: status,
      location: location,
      userId: userId,
      userName: userName,
      assignedToId: assignedToId,
      assignedToName: assignedToName,
      createdAt: createdAt ?? baseDate,
      updatedAt: updatedAt,
    );
  }

  group('IncidentEntity constructor', () {
    test('creates instance with all required fields', () {
      final incident = createIncident();
      expect(incident.id, 'inc-1');
      expect(incident.title, 'Avería ascensor');
      expect(incident.description, 'El ascensor no funciona desde ayer');
      expect(incident.priority, 'alta');
      expect(incident.status, 'open');
      expect(incident.userId, 'user-1');
      expect(incident.userName, 'Pedro Ruiz');
      expect(incident.createdAt, baseDate);
    });

    test('stores optional fields when provided', () {
      final incident = createIncident(
        location: 'Garaje B2',
        assignedToId: 'user-2',
        assignedToName: 'Técnico Mantenimiento',
        updatedAt: DateTime(2026, 2, 21),
      );
      expect(incident.location, 'Garaje B2');
      expect(incident.assignedToId, 'user-2');
      expect(incident.assignedToName, 'Técnico Mantenimiento');
      expect(incident.updatedAt, DateTime(2026, 2, 21));
    });

    test('optional fields default to null', () {
      final incident = createIncident(
        location: null,
        assignedToId: null,
        assignedToName: null,
      );
      expect(incident.location, isNull);
      expect(incident.assignedToId, isNull);
      expect(incident.assignedToName, isNull);
      expect(incident.updatedAt, isNull);
    });
  });

  group('IncidentEntity Equatable', () {
    test('two entities with same props are equal', () {
      final i1 = createIncident();
      final i2 = createIncident();
      expect(i1, equals(i2));
    });

    test('two entities with different id are not equal', () {
      final i1 = createIncident(id: 'inc-1');
      final i2 = createIncident(id: 'inc-2');
      expect(i1, isNot(equals(i2)));
    });

    test('two entities with different priority are not equal', () {
      final i1 = createIncident(priority: 'alta');
      final i2 = createIncident(priority: 'baja');
      expect(i1, isNot(equals(i2)));
    });

    test('two entities with different status are not equal', () {
      final i1 = createIncident(status: 'open');
      final i2 = createIncident(status: 'resolved');
      expect(i1, isNot(equals(i2)));
    });

    test('entities with different optional fields are not equal', () {
      final i1 = createIncident(assignedToId: 'user-2');
      final i2 = createIncident(assignedToId: null);
      expect(i1, isNot(equals(i2)));
    });
  });
}
