import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NotificationsResult> getNotifications({int skip = 0, int limit = 20}) async {
    final result = await remoteDataSource.getNotifications(skip: skip, limit: limit);
    return NotificationsResult(
      notifications: result.notifications.cast<NotificationEntity>(),
      unreadCount: result.unreadCount,
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<void> clearAll() async {
    await remoteDataSource.clearAll();
  }
}
