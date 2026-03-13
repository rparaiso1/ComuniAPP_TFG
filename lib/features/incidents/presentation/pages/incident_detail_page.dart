import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/incident_entity.dart';
import '../controllers/incident_controller.dart';

/// Provider para cargar detalle de una incidencia por ID
final incidentDetailProvider =
    FutureProvider.family<IncidentEntity, String>((ref, incidentId) async {
  final repository = ref.watch(incidentRepositoryProvider);
  return repository.getIncident(incidentId);
});

class IncidentDetailPage extends ConsumerStatefulWidget {
  final String incidentId;

  const IncidentDetailPage({required this.incidentId, super.key});

  @override
  ConsumerState<IncidentDetailPage> createState() => _IncidentDetailPageState();
}

class _IncidentDetailPageState extends ConsumerState<IncidentDetailPage> {
  final _commentController = TextEditingController();
  bool _isSendingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(incidentDetailProvider(widget.incidentId));
    final authState = ref.watch(authControllerProvider);
    final isAdminOrPres = authState.user?.role.isAdminOrPresident ?? false;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.colors.backgroundGradient,
        ),
        child: SafeArea(
          child: ContentConstraint(
            child: CustomScrollView(
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
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.goNamed('incidents'),
                  ),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        context.l.incidentDetail,
                        style: TextStyle(
                          color: context.colors.onGradient,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverFillRemaining(
                child: detailAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: AppColors.error.withValues(alpha: 0.7)),
                          const SizedBox(height: 16),
                          Text(
                            context.l.loadIncidentError,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13, color: context.colors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(
                                incidentDetailProvider(widget.incidentId)),
                            icon: const Icon(Icons.refresh),
                            label: Text(context.l.retry),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: context.colors.onGradient,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (incident) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Status + Priority header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: context.colors.softShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      incident.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _StatusBadge(status: incident.status),
                                  const SizedBox(width: 8),
                                  _PriorityBadge(priority: incident.priority),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Descripción
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: context.colors.softShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.description_outlined,
                                      size: 20, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l.description,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                incident.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.colors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: context.colors.softShadow,
                          ),
                          child: Column(
                            children: [
                              _InfoRow(
                                icon: Icons.person_outline,
                                label: context.l.reportedBy,
                                value: incident.userName,
                              ),
                              if (incident.location != null &&
                                  incident.location!.isNotEmpty) ...[
                                const Divider(height: 20),
                                _InfoRow(
                                  icon: Icons.location_on_outlined,
                                  label: context.l.location,
                                  value: incident.location!,
                                ),
                              ],
                              if (incident.assignedToName != null) ...[
                                const Divider(height: 20),
                                _InfoRow(
                                  icon: Icons.engineering_outlined,
                                  label: context.l.assignedTo,
                                  value: incident.assignedToName!,
                                ),
                              ],
                              const Divider(height: 20),
                              _InfoRow(
                                icon: Icons.access_time,
                                label: context.l.created,
                                value: timeago.format(incident.createdAt,
                                    locale: 'es'),
                              ),
                              if (incident.updatedAt != null) ...[
                                const Divider(height: 20),
                                _InfoRow(
                                  icon: Icons.update,
                                  label: context.l.updated,
                                  value: timeago.format(incident.updatedAt!,
                                      locale: 'es'),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Acciones de admin
                        if (isAdminOrPres) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: context.colors.card,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: context.colors.softShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.admin_panel_settings_outlined,
                                        size: 20, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.l.actions,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (incident.status != 'in_progress')
                                      _ActionButton(
                                        label: context.l.inProgress,
                                        icon: Icons.play_arrow,
                                        color: AppColors.warning,
                                        onTap: () => _updateStatus(
                                            ref, context, 'in_progress'),
                                      ),
                                    if (incident.status != 'resolved')
                                      _ActionButton(
                                        label: context.l.resolve,
                                        icon: Icons.check_circle_outline,
                                        color: AppColors.success,
                                        onTap: () => _updateStatus(
                                            ref, context, 'resolved'),
                                      ),
                                    if (incident.status != 'closed')
                                      _ActionButton(
                                        label: context.l.close,
                                        icon: Icons.close,
                                        color: context.colors.textSecondary,
                                        onTap: () => _updateStatus(
                                            ref, context, 'closed'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Comments section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: context.colors.softShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.comment_outlined,
                                      size: 20, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l.comments,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                  if (incident.comments.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${incident.comments.length}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Comment input
                              if (incident.status != 'resolved' &&
                                  incident.status != 'closed')
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _commentController,
                                        decoration: InputDecoration(
                                          hintText: context.l.writeComment,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                        ),
                                        maxLines: 2,
                                        minLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filled(
                                      onPressed: _isSendingComment
                                          ? null
                                          : () => _addComment(incident),
                                      icon: _isSendingComment
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            )
                                          : const Icon(Icons.send_rounded, size: 20),
                                      tooltip: context.l.sendComment,
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: context.colors.onGradient,
                                      ),
                                    ),
                                  ],
                                ),
                              if (incident.status != 'resolved' &&
                                  incident.status != 'closed')
                                const SizedBox(height: 16),
                              // Comments list
                              if (incident.comments.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      context.l.noComments,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context.colors.textTertiary,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...incident.comments.map((comment) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: AppColors.primary
                                                .withValues(alpha: 0.15),
                                            child: Text(
                                              comment.authorName[0].toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: context.colors.background,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        comment.authorName,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: context.colors
                                                              .textPrimary,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        timeago.format(
                                                            comment.createdAt,
                                                            locale: 'es'),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: context.colors
                                                              .textTertiary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    comment.content,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: context
                                                          .colors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  void _updateStatus(WidgetRef ref, BuildContext context, String status) async {
    try {
      await ref
          .read(incidentControllerProvider.notifier)
          .updateIncidentStatus(widget.incidentId, status);
      ref.invalidate(incidentDetailProvider(widget.incidentId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.statusUpdated),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.errorWithMessage(e.toString())),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _addComment(IncidentEntity incident) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    
    setState(() => _isSendingComment = true);
    try {
      final repository = ref.read(incidentRepositoryProvider);
      await repository.addComment(widget.incidentId, content: content);
      _commentController.clear();
      ref.invalidate(incidentDetailProvider(widget.incidentId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.commentAdded),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.errorAddComment),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingComment = false);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'open' => (context.l.statusOpen, AppColors.warning),
      'in_progress' => (context.l.statusInProgressLabel, AppColors.info),
      'resolved' => (context.l.statusResolved, AppColors.success),
      'closed' => (context.l.statusClosed, context.colors.textSecondary),
      _ => (status, context.colors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      'low' => (context.l.priorityLow, AppColors.success),
      'medium' => (context.l.priorityMedium, AppColors.warning),
      'high' => (context.l.priorityHigh, AppColors.error),
      'critical' => (context.l.priorityCritical, const Color(0xFF7B1FA2)),
      _ => (priority, context.colors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: context.colors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
