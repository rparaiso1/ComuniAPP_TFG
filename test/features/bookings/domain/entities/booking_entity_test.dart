import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/bookings/domain/entities/booking_entity.dart';

void main() {
  final baseDate = DateTime(2026, 3, 10, 9, 0);
  final endDate = DateTime(2026, 3, 10, 11, 0);

  BookingEntity createBooking({
    String id = 'booking-1',
    String zoneId = 'zone-1',
    String? zoneName = 'Piscina',
    String? zoneType = 'pool',
    String userId = 'user-1',
    String? userName = 'Juan García',
    String organizationId = 'org-1',
    DateTime? startTime,
    DateTime? endTime,
    String status = 'pending',
    String? notes,
    String? cancellationReason,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingEntity(
      id: id,
      zoneId: zoneId,
      zoneName: zoneName,
      zoneType: zoneType,
      userId: userId,
      userName: userName,
      organizationId: organizationId,
      startTime: startTime ?? baseDate,
      endTime: endTime ?? endDate,
      status: status,
      notes: notes,
      cancellationReason: cancellationReason,
      cancelledAt: cancelledAt,
      createdAt: createdAt ?? baseDate,
      updatedAt: updatedAt ?? baseDate,
    );
  }

  group('BookingEntity constructor', () {
    test('creates instance with all required fields', () {
      final booking = createBooking();
      expect(booking.id, 'booking-1');
      expect(booking.zoneId, 'zone-1');
      expect(booking.userId, 'user-1');
      expect(booking.organizationId, 'org-1');
      expect(booking.startTime, baseDate);
      expect(booking.endTime, endDate);
      expect(booking.status, 'pending');
    });

    test('stores optional fields when provided', () {
      final booking = createBooking(
        zoneName: 'Pista de pádel',
        zoneType: 'padel',
        userName: 'María López',
        notes: 'Evento privado',
      );
      expect(booking.zoneName, 'Pista de pádel');
      expect(booking.zoneType, 'padel');
      expect(booking.userName, 'María López');
      expect(booking.notes, 'Evento privado');
    });

    test('optional fields can be null', () {
      final booking = createBooking(
        zoneName: null,
        zoneType: null,
        userName: null,
        notes: null,
        cancellationReason: null,
        cancelledAt: null,
      );
      expect(booking.zoneName, isNull);
      expect(booking.zoneType, isNull);
      expect(booking.userName, isNull);
      expect(booking.notes, isNull);
      expect(booking.cancellationReason, isNull);
      expect(booking.cancelledAt, isNull);
    });

    test('stores cancellation data', () {
      final cancelDate = DateTime(2026, 3, 9);
      final booking = createBooking(
        status: 'cancelled',
        cancellationReason: 'Mal tiempo',
        cancelledAt: cancelDate,
      );
      expect(booking.cancellationReason, 'Mal tiempo');
      expect(booking.cancelledAt, cancelDate);
    });
  });

  group('BookingEntity computed getters', () {
    test('isPending returns true for pending status', () {
      expect(createBooking(status: 'pending').isPending, isTrue);
      expect(createBooking(status: 'confirmed').isPending, isFalse);
      expect(createBooking(status: 'cancelled').isPending, isFalse);
    });

    test('isConfirmed returns true for confirmed status', () {
      expect(createBooking(status: 'confirmed').isConfirmed, isTrue);
      expect(createBooking(status: 'pending').isConfirmed, isFalse);
      expect(createBooking(status: 'cancelled').isConfirmed, isFalse);
    });

    test('isCancelled returns true for cancelled status', () {
      expect(createBooking(status: 'cancelled').isCancelled, isTrue);
      expect(createBooking(status: 'pending').isCancelled, isFalse);
      expect(createBooking(status: 'confirmed').isCancelled, isFalse);
    });

    test('unknown status returns false for all getters', () {
      final booking = createBooking(status: 'unknown');
      expect(booking.isPending, isFalse);
      expect(booking.isConfirmed, isFalse);
      expect(booking.isCancelled, isFalse);
    });
  });

  group('BookingEntity Equatable', () {
    test('two entities with same props are equal', () {
      final b1 = createBooking();
      final b2 = createBooking();
      expect(b1, equals(b2));
    });

    test('two entities with different id are not equal', () {
      final b1 = createBooking(id: 'booking-1');
      final b2 = createBooking(id: 'booking-2');
      expect(b1, isNot(equals(b2)));
    });

    test('two entities with different status are not equal', () {
      final b1 = createBooking(status: 'pending');
      final b2 = createBooking(status: 'confirmed');
      expect(b1, isNot(equals(b2)));
    });

    test('two entities with different times are not equal', () {
      final b1 = createBooking(startTime: DateTime(2026, 3, 10, 9, 0));
      final b2 = createBooking(startTime: DateTime(2026, 3, 10, 10, 0));
      expect(b1, isNot(equals(b2)));
    });
  });
}
