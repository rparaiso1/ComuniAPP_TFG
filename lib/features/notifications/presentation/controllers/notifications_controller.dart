import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:comuniapp/core/di/providers.dart';
import 'package:comuniapp/core/services/org_selector_service.dart';
import 'package:comuniapp/core/utils/paginated_state.dart';
import 'package:comuniapp/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:comuniapp/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:comuniapp/features/notifications/domain/entities/notification_entity.dart';
import 'package:comuniapp/features/notifications/domain/repositories/notification_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authDataSource = ref.watch(authRemoteDataSourceProvider);

  final activeOrgId = ref.watch(activeOrgIdProvider);
  final remoteDataSource = NotificationRemoteDataSourceImpl(
    client: httpClient,
    getToken: () => authDataSource.accessToken ?? '',
    getOrgId: () => activeOrgId,
  );

  return NotificationRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class NotificationsState with PaginatedState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  @override
  final bool isLoadingMore;
  @override
  final bool hasMore;
  @override
  final int currentSkip;

  NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentSkip = 0,
  });

  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentSkip,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
    );
  }
}

// ---------------------------------------------------------------------------
// Controller (Notifier pattern)
// ---------------------------------------------------------------------------

class NotificationsController extends Notifier<NotificationsState> {
  late NotificationRepository repository;

  @override
  NotificationsState build() {
    repository = ref.watch(notificationRepositoryProvider);
    return NotificationsState();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null, currentSkip: 0, hasMore: true);

    try {
      final result = await repository.getNotifications(skip: 0, limit: kDefaultPageSize);
      state = state.copyWith(
        notifications: result.notifications,
        unreadCount: result.unreadCount,
        isLoading: false,
        currentSkip: result.notifications.length,
        hasMore: result.notifications.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await repository.getNotifications(
        skip: state.currentSkip,
        limit: kDefaultPageSize,
      );
      state = state.copyWith(
        notifications: [...state.notifications, ...result.notifications],
        unreadCount: result.unreadCount,
        isLoadingMore: false,
        currentSkip: state.currentSkip + result.notifications.length,
        hasMore: result.notifications.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await repository.markAsRead(notificationId);
      await loadNotifications();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await repository.markAllAsRead();
      await loadNotifications();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      await repository.deleteNotification(notificationId);
      await loadNotifications();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      await repository.clearAll();
      await loadNotifications();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
  () => NotificationsController(),
);

/// Provider simple para el contador de no leídas (para el badge)
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsControllerProvider).unreadCount;
});
