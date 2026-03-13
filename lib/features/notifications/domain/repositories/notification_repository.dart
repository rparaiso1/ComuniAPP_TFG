import '../entities/notification_entity.dart';

/// Resultado de la carga de notificaciones (lista + contador de no leídas).
class NotificationsResult {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationsResult({
    required this.notifications,
    required this.unreadCount,
  });
}

abstract class NotificationRepository {
  Future<NotificationsResult> getNotifications({int skip = 0, int limit = 20});
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> clearAll();
}
