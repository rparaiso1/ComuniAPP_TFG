import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/bookings/data/models/booking_model.dart';
import 'package:comuniapp/features/bookings/domain/entities/booking_entity.dart';

void main() {
  final validJson = {
    'id': 'booking-1',
    'zone_id': 'zone-1',
    'zone_name': 'Piscina comunitaria',
    'zone_type': 'pool',
    'user_id': 'user-1',
    'user_name': 'Juan García',
    'organization_id': 'org-1',
    'start_time': '2026-03-10T09:00:00.000',
    'end_time': '2026-03-10T11:00:00.000',
    'status': 'pending',
    'notes': 'Fiesta de cumpleaños',
    'cancellation_reason': null,
    'cancelled_at': null,
    'created_at': '2026-03-01T08:00:00.000',
    'updated_at': '2026-03-01T08:00:00.000',
  };

  group('BookingModel', () {
    test('is a subclass of BookingEntity', () {
      final model = BookingModel.fromJson(validJson);
      expect(model, isA<BookingEntity>());
    });
  });

  group('BookingModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = BookingModel.fromJson(validJson);
      expect(model.id, 'booking-1');
      expect(model.zoneId, 'zone-1');
      expect(model.zoneName, 'Piscina comunitaria');
      expect(model.zoneType, 'pool');
      expect(model.userId, 'user-1');
      expect(model.userName, 'Juan García');
      expect(model.organizationId, 'org-1');
      expect(model.startTime, DateTime(2026, 3, 10, 9, 0));
      expect(model.endTime, DateTime(2026, 3, 10, 11, 0));
      expect(model.status, 'pending');
      expect(model.notes, 'Fiesta de cumpleaños');
      expect(model.createdAt, DateTime(2026, 3, 1, 8, 0));
      expect(model.updatedAt, DateTime(2026, 3, 1, 8, 0));
    });

    test('handles missing optional fields', () {
      final minimalJson = {
        'id': 'booking-2',
        'zone_id': 'zone-2',
        'user_id': 'user-2',
        'organization_id': 'org-2',
        'start_time': '2026-04-01T10:00:00.000',
        'end_time': '2026-04-01T12:00:00.000',
        'status': 'confirmed',
        'created_at': '2026-03-15T09:00:00.000',
        'updated_at': '2026-03-15T09:00:00.000',
      };
      final model = BookingModel.fromJson(minimalJson);
      expect(model.zoneName, isNull);
      expect(model.zoneType, isNull);
      expect(model.userName, isNull);
      expect(model.notes, isNull);
      expect(model.cancellationReason, isNull);
      expect(model.cancelledAt, isNull);
    });

    test('defaults id, zoneId, userId, organizationId to empty string when null', () {
      final json = {
        'start_time': '2026-01-01T00:00:00.000',
        'end_time': '2026-01-01T02:00:00.000',
        'created_at': '2026-01-01T00:00:00.000',
        'updated_at': '2026-01-01T00:00:00.000',
      };
      final model = BookingModel.fromJson(json);
      expect(model.id, '');
      expect(model.zoneId, '');
      expect(model.userId, '');
      expect(model.organizationId, '');
    });

    test('defaults status to confirmed when null', () {
      final json = {
        'start_time': '2026-01-01T00:00:00.000',
        'end_time': '2026-01-01T02:00:00.000',
        'created_at': '2026-01-01T00:00:00.000',
        'updated_at': '2026-01-01T00:00:00.000',
      };
      final model = BookingModel.fromJson(json);
      expect(model.status, 'confirmed');
    });

    test('parses cancelled_at when provided', () {
      final json = {
        ...validJson,
        'status': 'cancelled',
        'cancellation_reason': 'Cambio de planes',
        'cancelled_at': '2026-03-05T14:30:00.000',
      };
      final model = BookingModel.fromJson(json);
      expect(model.isCancelled, isTrue);
      expect(model.cancellationReason, 'Cambio de planes');
      expect(model.cancelledAt, DateTime(2026, 3, 5, 14, 30));
    });
  });

  group('BookingModel.toJson', () {
    test('produces correct JSON map', () {
      final model = BookingModel.fromJson(validJson);
      final json = model.toJson();
      expect(json['zone_id'], 'zone-1');
      expect(json['start_time'], '2026-03-10T09:00:00.000');
      expect(json['end_time'], '2026-03-10T11:00:00.000');
      expect(json['notes'], 'Fiesta de cumpleaños');
    });

    test('does not include id, userId, organizationId, or timestamps', () {
      final model = BookingModel.fromJson(validJson);
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('user_id'), isFalse);
      expect(json.containsKey('organization_id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
      expect(json.containsKey('status'), isFalse);
    });

    test('excludes notes when null', () {
      final json = {...validJson};
      json.remove('notes');
      final model = BookingModel.fromJson(json);
      final output = model.toJson();
      expect(output.containsKey('notes'), isFalse);
    });

    test('includes notes when present', () {
      final model = BookingModel.fromJson(validJson);
      final output = model.toJson();
      expect(output.containsKey('notes'), isTrue);
      expect(output['notes'], 'Fiesta de cumpleaños');
    });
  });
}
