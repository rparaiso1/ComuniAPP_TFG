import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter/material.dart' show Icons;

void main() {
  final baseDate = DateTime(2026, 5, 1, 10, 0);

  NotificationEntity createNotification({
    String id = 'notif-1',
    String type = 'announcement',
    String title = 'Nueva reunión',
    String message = 'Se convoca reunión extraordinaria',
    bool isRead = false,
    DateTime? createdAt,
    String? link,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id,
      type: type,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt ?? baseDate,
      link: link,
      data: data,
    );
  }

  group('NotificationEntity constructor', () {
    test('creates instance with all required fields', () {
      final notif = createNotification();
      expect(notif.id, 'notif-1');
      expect(notif.type, 'announcement');
      expect(notif.title, 'Nueva reunión');
      expect(notif.message, 'Se convoca reunión extraordinaria');
      expect(notif.isRead, isFalse);
      expect(notif.createdAt, baseDate);
    });

    test('optional fields default to null', () {
      final notif = createNotification();
      expect(notif.link, isNull);
      expect(notif.data, isNull);
    });

    test('stores optional fields when provided', () {
      final notif = createNotification(
        link: '/incidents/inc-1',
        data: {'incident_id': 'inc-1'},
      );
      expect(notif.link, '/incidents/inc-1');
      expect(notif.data, {'incident_id': 'inc-1'});
    });

    test('stores read status', () {
      final unread = createNotification(isRead: false);
      final read = createNotification(isRead: true);
      expect(unread.isRead, isFalse);
      expect(read.isRead, isTrue);
    });
  });

  group('NotificationEntity icon getter', () {
    test('returns calendar icon for booking type', () {
      final notif = createNotification(type: 'booking');
      expect(notif.icon, Icons.calendar_today);
    });

    test('returns report icon for incident type', () {
      final notif = createNotification(type: 'incident');
      expect(notif.icon, Icons.report_problem);
    });

    test('returns poll icon for poll type', () {
      final notif = createNotification(type: 'poll');
      expect(notif.icon, Icons.poll);
    });

    test('returns description icon for document type', () {
      final notif = createNotification(type: 'document');
      expect(notif.icon, Icons.description);
    });

    test('returns payment icon for payment type', () {
      final notif = createNotification(type: 'payment');
      expect(notif.icon, Icons.payment);
    });

    test('returns campaign icon for announcement type', () {
      final notif = createNotification(type: 'announcement');
      expect(notif.icon, Icons.campaign);
    });

    test('returns default notifications icon for unknown type', () {
      final notif = createNotification(type: 'unknown');
      expect(notif.icon, Icons.notifications);
    });

    test('returns default notifications icon for empty type', () {
      final notif = createNotification(type: '');
      expect(notif.icon, Icons.notifications);
    });
  });

  group('NotificationEntity Equatable', () {
    test('two entities with same props are equal', () {
      final n1 = createNotification();
      final n2 = createNotification();
      expect(n1, equals(n2));
    });

    test('two entities with different id are not equal', () {
      final n1 = createNotification(id: 'notif-1');
      final n2 = createNotification(id: 'notif-2');
      expect(n1, isNot(equals(n2)));
    });

    test('two entities with different isRead are not equal', () {
      final n1 = createNotification(isRead: false);
      final n2 = createNotification(isRead: true);
      expect(n1, isNot(equals(n2)));
    });

    test('two entities with different type are not equal', () {
      final n1 = createNotification(type: 'booking');
      final n2 = createNotification(type: 'incident');
      expect(n1, isNot(equals(n2)));
    });
  });
}
