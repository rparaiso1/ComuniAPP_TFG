import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/incidents/data/models/incident_model.dart';
import 'package:comuniapp/features/incidents/domain/entities/incident_entity.dart';

void main() {
  // JSON matching real backend IncidentResponse schema
  final validJson = {
    'id': 'inc-1',
    'title': 'Avería ascensor',
    'description': 'El ascensor no funciona desde ayer',
    'priority': 'high',
    'status': 'open',
    'location': 'Portal 2',
    'reporter_id': 'user-1',
    'reporter_name': 'Pedro Ruiz',
    'assigned_to_id': 'user-2',
    'assigned_to_name': 'Técnico Mantenimiento',
    'created_at': '2026-02-20T14:30:00.000',
    'updated_at': '2026-02-21T10:00:00.000',
  };

  group('IncidentModel', () {
    test('is a subclass of IncidentEntity', () {
      final model = IncidentModel.fromJson(validJson);
      expect(model, isA<IncidentEntity>());
    });
  });

  group('IncidentModel.fromJson', () {
    test('parses all fields correctly from backend format', () {
      final model = IncidentModel.fromJson(validJson);
      expect(model.id, 'inc-1');
      expect(model.title, 'Avería ascensor');
      expect(model.description, 'El ascensor no funciona desde ayer');
      expect(model.priority, 'high');
      expect(model.status, 'open');
      expect(model.location, 'Portal 2');
      expect(model.userId, 'user-1');
      expect(model.userName, 'Pedro Ruiz');
      expect(model.assignedToId, 'user-2');
      expect(model.assignedToName, 'Técnico Mantenimiento');
      expect(model.createdAt, DateTime(2026, 2, 20, 14, 30));
      expect(model.updatedAt, DateTime(2026, 2, 21, 10, 0));
    });

    test('falls back to legacy user_id / user.full_name fields', () {
      final legacyJson = {
        'id': 'inc-legacy',
        'title': 'Legacy format',
        'description': 'Uses old field names',
        'user_id': 'user-old',
        'user': {'full_name': 'Legacy User'},
        'assigned_to': {'full_name': 'Old Assignee'},
        'assigned_to_id': 'user-old-2',
        'created_at': '2026-01-15T08:00:00.000',
      };
      final model = IncidentModel.fromJson(legacyJson);
      expect(model.userId, 'user-old');
      expect(model.userName, 'Legacy User');
      expect(model.assignedToName, 'Old Assignee');
    });

    test('handles missing optional fields', () {
      final minimalJson = {
        'id': 'inc-2',
        'title': 'Fuga de agua',
        'description': 'Hay una fuga en el sótano',
        'reporter_id': 'user-3',
        'reporter_name': 'Ana López',
        'created_at': '2026-03-01T09:00:00.000',
      };
      final model = IncidentModel.fromJson(minimalJson);
      expect(model.location, isNull);
      expect(model.assignedToId, isNull);
      expect(model.assignedToName, isNull);
      expect(model.updatedAt, isNull);
    });

    test('defaults priority to low when null', () {
      final json = {...validJson};
      json.remove('priority');
      final model = IncidentModel.fromJson(json);
      expect(model.priority, 'low');
    });

    test('defaults status to open when null', () {
      final json = {...validJson};
      json.remove('status');
      final model = IncidentModel.fromJson(json);
      expect(model.status, 'open');
    });

    test('defaults userName to "Usuario" when reporter_name is null', () {
      final json = {...validJson};
      json.remove('reporter_name');
      final model = IncidentModel.fromJson(json);
      expect(model.userName, 'Usuario');
    });

    test('defaults id, title, description, userId to empty string when null', () {
      final json = <String, dynamic>{
        'created_at': '2026-01-01T00:00:00.000',
      };
      final model = IncidentModel.fromJson(json);
      expect(model.id, '');
      expect(model.title, '');
      expect(model.description, '');
      expect(model.userId, '');
    });

    test('assignedToName is null when assigned_to_name is null', () {
      final json = {...validJson};
      json.remove('assigned_to_name');
      json.remove('assigned_to_id');
      final model = IncidentModel.fromJson(json);
      expect(model.assignedToId, isNull);
      expect(model.assignedToName, isNull);
    });
  });

  group('IncidentModel.toJson', () {
    test('produces correct JSON map', () {
      final model = IncidentModel.fromJson(validJson);
      final json = model.toJson();
      expect(json['title'], 'Avería ascensor');
      expect(json['description'], 'El ascensor no funciona desde ayer');
      expect(json['priority'], 'high');
      expect(json['status'], 'open');
      expect(json['location'], 'Portal 2');
      expect(json['assigned_to_id'], 'user-2');
    });

    test('does not include id, userId, userName, or timestamps', () {
      final model = IncidentModel.fromJson(validJson);
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('reporter_id'), isFalse);
      expect(json.containsKey('reporter_name'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
    });

    test('includes null location and assigned_to_id when not set', () {
      final minimalJson = {
        'id': 'inc-3',
        'title': 'Test',
        'description': 'Test desc',
        'reporter_id': 'user-1',
        'reporter_name': 'Test User',
        'created_at': '2026-01-01T00:00:00.000',
      };
      final model = IncidentModel.fromJson(minimalJson);
      final json = model.toJson();
      expect(json['location'], isNull);
      expect(json['assigned_to_id'], isNull);
    });
  });
}
