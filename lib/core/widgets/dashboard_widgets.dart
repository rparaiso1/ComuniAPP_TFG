import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../utils/l10n_extension.dart';

/// Widget para estados vacíos con ilustración y acción
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textTertiary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction!();
                },
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: context.colors.onGradient,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Factory constructors para casos comunes
  factory EmptyState.noBookings({required BuildContext context, VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: context.l.emptyBookings,
      subtitle: context.l.emptyBookingsDesc,
      actionLabel: onAction != null ? context.l.emptyBookingsAction : null,
      onAction: onAction,
      iconColor: AppColors.info,
    );
  }

  factory EmptyState.noIncidents({required BuildContext context, VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.check_circle_outline,
      title: context.l.emptyIncidents,
      subtitle: context.l.emptyIncidentsDesc,
      actionLabel: onAction != null ? context.l.emptyIncidentsAction : null,
      onAction: onAction,
      iconColor: AppColors.success,
    );
  }

  factory EmptyState.noDocuments({required BuildContext context}) {
    return EmptyState(
      icon: Icons.folder_open_outlined,
      title: context.l.emptyDocuments,
      subtitle: context.l.emptyDocumentsDesc,
      iconColor: AppColors.warning,
    );
  }

  factory EmptyState.noPosts({required BuildContext context, VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.article_outlined,
      title: context.l.emptyPosts,
      subtitle: context.l.emptyPostsDesc,
      actionLabel: onAction != null ? context.l.emptyPostsAction : null,
      onAction: onAction,
      iconColor: AppColors.purple,
    );
  }

  factory EmptyState.noResults({required BuildContext context}) {
    return EmptyState(
      icon: Icons.search_off,
      title: context.l.emptySearch,
      subtitle: context.l.emptySearchDesc,
      iconColor: AppColors.neutral,
    );
  }

  factory EmptyState.error({required BuildContext context, VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: context.l.errorState,
      subtitle: context.l.errorStateDesc,
      actionLabel: context.l.retry,
      onAction: onRetry,
      iconColor: AppColors.error,
    );
  }

  factory EmptyState.offline({required BuildContext context, VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: context.l.noConnection,
      subtitle: context.l.noConnectionDesc,
      actionLabel: context.l.retry,
      onAction: onRetry,
      iconColor: AppColors.neutral,
    );
  }
}

/// Card de estadística para dashboards
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? trend;
  final bool isPositive;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.trend,
    this.isPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.colors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? AppColors.success.withAlpha(25)
                          : AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: isPositive ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPositive ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador de progreso circular con porcentaje
class ProgressIndicatorCard extends StatelessWidget {
  final double progress;
  final String label;
  final Color color;
  final String? centerText;

  const ProgressIndicatorCard({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
    this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.softShadow,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: color.withAlpha(51),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    centerText ?? '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Badge de notificación
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? color;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: count > 9 ? 6 : 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color ?? AppColors.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.card, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: context.colors.onGradient,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Chip de estado con color personalizado
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusChip.pending() {
    return const StatusChip(
      label: 'Pendiente',
      color: AppColors.warning,
      icon: Icons.schedule,
    );
  }

  factory StatusChip.approved() {
    return const StatusChip(
      label: 'Aprobado',
      color: AppColors.success,
      icon: Icons.check_circle,
    );
  }

  factory StatusChip.rejected() {
    return const StatusChip(
      label: 'Rechazado',
      color: AppColors.error,
      icon: Icons.cancel,
    );
  }

  factory StatusChip.inProgress() {
    return const StatusChip(
      label: 'En progreso',
      color: AppColors.info,
      icon: Icons.autorenew,
    );
  }

  factory StatusChip.completed() {
    return const StatusChip(
      label: 'Completado',
      color: AppColors.success,
      icon: Icons.done_all,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
