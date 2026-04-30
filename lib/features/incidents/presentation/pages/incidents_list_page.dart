import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/incident_controller.dart';

class IncidentsListPage extends ConsumerStatefulWidget {
  const IncidentsListPage({super.key});

  @override
  ConsumerState<IncidentsListPage> createState() => _IncidentsListPageState();
}

class _IncidentsListPageState extends ConsumerState<IncidentsListPage> {
  final ScrollController _scrollController = ScrollController();
  String? _statusFilter;
  String? _priorityFilter;
  bool _myOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIncidents();
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
      ref.read(incidentControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _loadIncidents() async {
    await ref.read(incidentControllerProvider.notifier).loadIncidents(
      statusFilter: _statusFilter,
      priorityFilter: _priorityFilter,
      myOnly: _myOnly,
    );
  }

  void _selectStatus(String? status) {
    setState(() => _statusFilter = status);
    _loadIncidents();
  }

  void _selectPriority(String? priority) {
    setState(() => _priorityFilter = priority);
    _loadIncidents();
  }

  void _toggleMyOnly() {
    setState(() => _myOnly = !_myOnly);
    _loadIncidents();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidentControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final canManage = authState.user?.role.isAdminOrPresident ?? false;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: ContentConstraint(
        child: RefreshIndicator(
          onRefresh: _loadIncidents,
          child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildHeader(context),
            _buildFilterBar(context),
            if (state.isLoading && state.incidents.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && state.incidents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 64, color: context.colors.textTertiary),
                        const SizedBox(height: 16),
                        Text(
                          ErrorDialog.getFriendlyMessage(context, state.error!),
                          style: TextStyle(color: context.colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _loadIncidents,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(context.l.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (state.incidents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.report_problem_outlined,
                        size: 80,
                        color: context.colors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l.noIncidents,
                        style: TextStyle(
                          fontSize: 18,
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final incident = state.incidents[index];
                      return StaggeredListItem(
                        index: index,
                        child: _IncidentCard(
                          incident: incident,
                          canManage: canManage,
                          onStatusChange: (newStatus) async {
                            await ref
                                .read(incidentControllerProvider.notifier)
                                .updateIncidentStatus(incident.id, newStatus);
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(context.l.deleteIncident),
                                content: Text(context.l.deleteIncidentConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(context.l.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: context.colors.onGradient,
                                    ),
                                    child: Text(context.l.delete),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref
                                  .read(incidentControllerProvider.notifier)
                                  .deleteIncident(incident.id);
                            }
                          },
                        ),
                      );
                    },
                    childCount: state.incidents.length,
                  ),
                ),
              ),
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
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
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.softShadow,
          ),
          child: IconButton(
            icon: Icon(Icons.add_rounded, color: context.colors.onGradient),
            tooltip: context.l.newIncident,
            onPressed: () async {
              await _showCreateDialog(context);
            },
          ),
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              context.l.incidentsTitle,
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
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status filter row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: context.l.allStatuses,
                    selected: _statusFilter == null,
                    onTap: () => _selectStatus(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: context.l.statusOpen,
                    selected: _statusFilter == 'open',
                    onTap: () => _selectStatus('open'),
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: context.l.statusInProgressLabel,
                    selected: _statusFilter == 'in_progress',
                    onTap: () => _selectStatus('in_progress'),
                    color: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: context.l.statusResolved,
                    selected: _statusFilter == 'resolved',
                    onTap: () => _selectStatus('resolved'),
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: context.l.statusClosed,
                    selected: _statusFilter == 'closed',
                    onTap: () => _selectStatus('closed'),
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Priority filter row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: context.l.allPriorities,
                    selected: _priorityFilter == null,
                    onTap: () => _selectPriority(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: context.l.priorityLow,
                    selected: _priorityFilter == 'low',
                    onTap: () => _selectPriority('low'),
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: context.l.priorityMedium,
                    selected: _priorityFilter == 'medium',
                    onTap: () => _selectPriority('medium'),
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: context.l.priorityHigh,
                    selected: _priorityFilter == 'high',
                    onTap: () => _selectPriority('high'),
                    color: const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: context.l.priorityCritical,
                    selected: _priorityFilter == 'critical',
                    onTap: () => _selectPriority('critical'),
                    color: const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // My incidents toggle
            _FilterChip(
              label: context.l.myIncidents,
              selected: _myOnly,
              onTap: _toggleMyOnly,
              icon: Icons.person,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    String selectedPriority = 'low';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(context.l.newIncidentDialog),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: context.l.title,
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: context.l.description,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: context.l.locationOptional,
                      prefixIcon: const Icon(Icons.location_on),
                      hintText: context.l.locationExample,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPriority,
                    decoration: InputDecoration(
                      labelText: context.l.priority,
                      prefixIcon: const Icon(Icons.priority_high),
                    ),
                    items: [
                      DropdownMenuItem(value: 'low', child: Text(context.l.priorityLow)),
                      DropdownMenuItem(value: 'medium', child: Text(context.l.priorityMedium)),
                      DropdownMenuItem(value: 'high', child: Text(context.l.priorityHigh)),
                      DropdownMenuItem(value: 'critical', child: Text(context.l.priorityCritical)),
                    ],
                    onChanged: (value) {
                      setState(() => selectedPriority = value!);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l.completeTitleDescription),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  await ref.read(incidentControllerProvider.notifier).createIncident(
                        title: titleController.text,
                        description: descriptionController.text,
                        priority: selectedPriority,
                        location: locationController.text.isNotEmpty
                            ? locationController.text
                            : null,
                      );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: context.colors.onGradient,
                  backgroundColor: AppColors.primary,
                ),
                child: Text(context.l.create),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final dynamic incident;
  final bool canManage;
  final Function(String) onStatusChange;
  final VoidCallback onDelete;

  const _IncidentCard({
    required this.incident,
    required this.canManage,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priorityConfig = _getPriorityConfig(context, incident.priority);
    final statusConfig = _getStatusConfig(context, incident.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: priorityConfig['color'].withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.goNamed(
            'incidentDetail',
            pathParameters: {'incidentId': incident.id},
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: priorityConfig['color'].withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.report_problem,
                        color: priorityConfig['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            incident.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityConfig['color'].withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  priorityConfig['label'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: priorityConfig['color'],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusConfig['color'].withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusConfig['icon'],
                                      size: 12,
                                      color: statusConfig['color'],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusConfig['label'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: statusConfig['color'],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (canManage)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete();
                        } else {
                          onStatusChange(value);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'open',
                          child: Row(
                            children: [
                              const Icon(Icons.radio_button_unchecked, size: 18),
                              const SizedBox(width: 8),
                              Text(context.l.statusOpen),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'in_progress',
                          child: Row(
                            children: [
                              const Icon(Icons.sync, size: 18),
                              const SizedBox(width: 8),
                              Text(context.l.statusInProgressLabel),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'resolved',
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 18),
                              const SizedBox(width: 8),
                              Text(context.l.statusResolved),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'closed',
                          child: Row(
                            children: [
                              const Icon(Icons.cancel, size: 18),
                              const SizedBox(width: 8),
                              Text(context.l.statusClosed),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: context.colors.error),
                              const SizedBox(width: 8),
                              Text(context.l.delete, style: TextStyle(color: context.colors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  incident.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                  ),
                ),
                if (incident.location != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: context.colors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        incident.location!,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        incident.userName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.onGradient,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      incident.userName,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeago.format(incident.createdAt, locale: 'es'),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getPriorityConfig(BuildContext context, String priority) {
    switch (priority) {
      case 'critical':
        return {
          'color': const Color(0xFFDC2626),
          'label': context.l.priorityCritical,
        };
      case 'high':
        return {
          'color': const Color(0xFFEF4444),
          'label': context.l.priorityHigh,
        };
      case 'medium':
        return {
          'color': const Color(0xFFF59E0B),
          'label': context.l.priorityMedium,
        };
      default:
        return {
          'color': const Color(0xFF10B981),
          'label': context.l.priorityLow,
        };
    }
  }

  Map<String, dynamic> _getStatusConfig(BuildContext context, String status) {
    switch (status) {
      case 'in_progress':
        return {
          'color': const Color(0xFF3B82F6),
          'icon': Icons.sync,
          'label': context.l.statusInProgressLabel,
        };
      case 'resolved':
        return {
          'color': const Color(0xFF10B981),
          'icon': Icons.check_circle,
          'label': context.l.statusResolved,
        };
      case 'closed':
        return {
          'color': const Color(0xFF6B7280),
          'icon': Icons.cancel,
          'label': context.l.statusClosed,
        };
      default:
        return {
          'color': const Color(0xFFF59E0B),
          'icon': Icons.radio_button_unchecked,
          'label': context.l.statusOpen,
        };
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (color ?? AppColors.primary).withValues(alpha: 0.15)
              : context.colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (color ?? AppColors.primary)
                : context.colors.textTertiary.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? (color ?? AppColors.primary) : context.colors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? (color ?? AppColors.primary) : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
