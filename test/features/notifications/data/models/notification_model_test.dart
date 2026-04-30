import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/notifications/data/models/notification_model.dart';
import 'package:comuniapp/features/notifications/domain/entities/notification_entity.dart';

void main() {
  final validJson = {
    'id': 'notif-1',
    'notification_type': 'incident',
    'title': 'Nueva incidencia reportada',
    'message': 'Se ha reportado una avería en el ascensor',
    'is_read': false,
    'created_at': '2026-05-01T10:00:00.000',
    'link': '/incidents/inc-1',
    'data': {'incident_id': 'inc-1'},
  };

  group('NotificationModel', () {
    test('is a subclass of NotificationEntity', () {
      final model = NotificationModel.fromJson(validJson);
      expect(model, isA<NotificationEntity>());
    });
  });

  group('NotificationModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = NotificationModel.fromJson(validJson);
      expect(model.id, 'notif-1');
      expect(model.type, 'incident');
      expect(model.title, 'Nueva incidencia reportada');
      expect(model.message, 'Se ha reportado una avería en el ascensor');
      expect(model.isRead, isFalse);
      expect(model.createdAt, DateTime(2026, 5, 1, 10, 0));
      expect(model.link, '/incidents/inc-1');
      expect(model.data, {'incident_id': 'inc-1'});
    });

    test('reads type from notification_type field', () {
      final json = {
        ...validJson,
        'notification_type': 'booking',
      };
      final model = NotificationModel.fromJson(json);
      expect(model.type, 'booking');
    });

    test('falls back to type field when notification_type is absent', () {
      final json = {
        ...validJson,
        'type': 'document',
      };
      json.remove('notification_type');
      final model = NotificationModel.fromJson(json);
      expect(model.type, 'document');
    });

    test('defaults type to info when both type fields are absent', () {
      final json = {...validJson};
      json.remove('notification_type');
      // No 'type' key either
      final model = NotificationModel.fromJson(json);
      expect(model.type, 'info');
    });

    test('defaults isRead to false when null', () {
      final json = {...validJson};
      json.remove('is_read');
      final model = NotificationModel.fromJson(json);
      expect(model.isRead, isFalse);
    });

    test('parses isRead as true', () {
      final json = {...validJson, 'is_read': true};
      final model = NotificationModel.fromJson(json);
      expect(model.isRead, isTrue);
    });

    test('handles missing optional fields', () {
      final minimalJson = {
        'id': 'notif-2',
        'notification_type': 'announcement',
        'title': 'Aviso',
        'message': 'Mensaje',
        'created_at': '2026-06-01T08:00:00.000',
      };
      final model = NotificationModel.fromJson(minimalJson);
      expect(model.link, isNull);
      expect(model.data, isNull);
      expect(model.isRead, isFalse);
    });

    test('handles data field with complex map', () {
      final json = {
        ...validJson,
        'data': {
          'incident_id': 'inc-1',
          'priority': 'alta',
          'count': 5,
        },
      };
      final model = NotificationModel.fromJson(json);
      expect(model.data, isA<Map<String, dynamic>>());
      expect(model.data!['priority'], 'alta');
      expect(model.data!['count'], 5);
    });
  });
}
