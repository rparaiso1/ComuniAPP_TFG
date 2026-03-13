import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:comuniapp/core/routing/route_names.dart';
import 'package:comuniapp/core/theme/app_colors.dart';
import 'package:comuniapp/core/utils/l10n_extension.dart';
import 'package:comuniapp/core/utils/responsive.dart';
import 'package:comuniapp/features/notifications/domain/entities/notification_entity.dart';
import 'package:comuniapp/features/notifications/presentation/controllers/notifications_controller.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsControllerProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.colors.backgroundGradient,
        ),
        child: SafeArea(
          child: ContentConstraint(
            child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: context.colors.onGradient),
                    tooltip: context.l.goBack,
                    onPressed: () => context.canPop() ? context.pop() : context.goNamed('home'),
                  ),
                ),
                actions: [
                  if (state.unreadCount > 0)
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.done_all, color: context.colors.onGradient),
                        tooltip: context.l.markAllRead,
                        onPressed: () async {
                          final success = await ref
                              .read(notificationsControllerProvider.notifier)
                              .markAllAsRead();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? context.l.allMarkedRead
                                      : context.l.markReadError,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: context.colors.onGradient),
                    onSelected: (value) async {
                      if (value == 'clear') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(ctx.l.deleteNotifications),
                            content: Text(ctx.l.deleteAllNotificationsConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(ctx.l.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(ctx.l.delete),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(notificationsControllerProvider.notifier).clearAll();
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_sweep),
                            const SizedBox(width: 8),
                            Text(ctx.l.deleteAll),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                flexibleSpace: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.l.notifications,
                            style: TextStyle(
                              color: context.colors.onGradient,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          if (state.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.colors.onGradientMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${state.unreadCount}',
                                style: TextStyle(
                                  color: context.colors.onGradient,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Lista de notificaciones
              if (state.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: context.colors.textTertiary),
                        const SizedBox(height: 16),
                        Text(state.error!, style: TextStyle(color: context.colors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(notificationsControllerProvider.notifier)
                              .loadNotifications(),
                          child: Text(context.l.retry),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state.notifications.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 80, color: context.colors.textTertiary),
                        const SizedBox(height: 16),
                        Text(context.l.noNotifications, style: TextStyle(fontSize: 18, color: context.colors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notification = state.notifications[index];
                        return _NotificationCard(
                          notification: notification,
                          onTap: () async {
                            if (!notification.isRead) {
                              await ref.read(notificationsControllerProvider.notifier).markAsRead(notification.id);
                            }
                            if (context.mounted) {
                              _navigateToRelatedEntity(context, notification);
                            }
                          },
                          onDismiss: () async {
                            await ref.read(notificationsControllerProvider.notifier).deleteNotification(notification.id);
                          },
                        );
                      },
                      childCount: state.notifications.length,
                    ),
                  ),
                ),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ],
          ),
          ),
        ),
      ),
    );
  }

  /// Navigate to the entity related to the notification.
  ///
  /// Uses [NotificationEntity.link] to extract the entity ID and navigates
  /// based on the [NotificationEntity.type].
  void _navigateToRelatedEntity(
    BuildContext context,
    NotificationEntity notification,
  ) {
    final link = notification.link;
    final entityId = link != null ? _extractIdFromLink(link) : null;

    switch (notification.type) {
      case 'booking':
        context.go(RouteNames.bookings);
      case 'incident':
        if (entityId != null) {
          context.go(
            RouteNames.incidentDetail
                .replaceFirst(':incidentId', entityId),
          );
        } else {
          context.go(RouteNames.incidents);
        }
      case 'document':
        context.go(RouteNames.documents);
      case 'announcement':
        if (entityId != null) {
          context.go(
            RouteNames.postDetail.replaceFirst(':postId', entityId),
          );
        } else {
          context.go(RouteNames.board);
        }
      default:
        // system / info / unknown → go home
        context.go(RouteNames.home);
    }
  }

  /// Extracts the UUID from a backend link like `/incidents/{uuid}`.
  String? _extractIdFromLink(String link) {
    final segments = link.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length >= 2) {
      return segments.last;
    }
    return null;
  }
}

Color _getNotificationColor(String type) {
  switch (type) {
    case 'booking':
      return AppColors.success;
    case 'incident':
      return AppColors.warning;
    case 'poll':
      return AppColors.purple;
    case 'document':
      return AppColors.info;
    case 'payment':
      return AppColors.teal;
    case 'announcement':
      return AppColors.error;
    default:
      return AppColors.primary;
  }
}

String _formatTimeAgo(BuildContext context, DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) {
    return context.l.timeNow;
  } else if (diff.inMinutes < 60) {
    return context.l.timeMinAgo(diff.inMinutes);
  } else if (diff.inHours < 24) {
    return context.l.timeHourAgo(diff.inHours);
  } else if (diff.inDays == 1) {
    return context.l.timeYesterday;
  } else if (diff.inDays < 7) {
    return context.l.timeDaysAgo(diff.inDays);
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getNotificationColor(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: context.colors.onGradient),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead ? context.colors.card : context.colors.chipBackground,
            borderRadius: BorderRadius.circular(16),
            border: notification.isRead
                ? null
                : Border.all(color: AppColors.primary.withAlpha(51), width: 1),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimeAgo(context, notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

