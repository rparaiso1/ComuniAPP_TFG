import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/config/env_config.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/booking_entity.dart';
import '../controllers/booking_controller.dart';

/// Lightweight zone model for filter chips
class _ZoneFilter {
  final String id;
  final String name;
  final String zoneType;

  const _ZoneFilter({required this.id, required this.name, required this.zoneType});

  factory _ZoneFilter.fromJson(Map<String, dynamic> json) => _ZoneFilter(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        zoneType: json['zone_type'] ?? '',
      );
}

class BookingsListPage extends ConsumerStatefulWidget {
  const BookingsListPage({super.key});

  @override
  ConsumerState<BookingsListPage> createState() => _BookingsListPageState();
}

class _BookingsListPageState extends ConsumerState<BookingsListPage> {
  final ScrollController _scrollController = ScrollController();
  List<_ZoneFilter> _zones = [];
  String? _selectedZoneId; // null = all zones
  bool _myOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadZones();
      _loadBookings();
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
      ref.read(bookingControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _loadBookings() async {
    await ref.read(bookingControllerProvider.notifier).loadBookings(
          zoneId: _selectedZoneId,
          myOnly: _myOnly,
        );
  }

  Future<void> _loadZones() async {
    try {
      final headers = ref.read(authHeadersProvider);
      final response = await http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/zones'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _zones = data.map((z) => _ZoneFilter.fromJson(z as Map<String, dynamic>)).toList();
          });
        }
      }
    } catch (_) {
      // zones filter is optional – silently fail
    }
  }

  void _selectZone(String? zoneId) {
    if (zoneId == _selectedZoneId) return;
    setState(() => _selectedZoneId = zoneId);
    _loadBookings();
  }

  void _toggleMyOnly() {
    setState(() => _myOnly = !_myOnly);
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isAdminOrPres = authState.user?.role.isAdminOrPresident ?? false;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: ContentConstraint(
        child: RefreshIndicator(
          onRefresh: _loadBookings,
          child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildHeader(context),
            // ── Zone filter bar ─────────────────────────────────
            if (_zones.isNotEmpty)
              SliverToBoxAdapter(
                child: _ZoneFilterBar(
                  zones: _zones,
                  selectedZoneId: _selectedZoneId,
                  myOnly: _myOnly,
                  onZoneSelected: _selectZone,
                  onMyOnlyToggled: _toggleMyOnly,
                ),
              ),
            if (state.isLoading && state.bookings.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && state.bookings.isEmpty)
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
                          onPressed: _loadBookings,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(context.l.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (state.bookings.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 80,
                        color: context.colors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l.noBookings,
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
                      final booking = state.bookings[index];
                      return StaggeredListItem(
                        index: index,
                        child: _BookingCard(
                          booking: booking,
                          onCancel: booking.isCancelled
                              ? null
                              : () => _showCancelDialog(booking),
                          onApprove: isAdminOrPres && booking.isPending
                              ? () => _approveBooking(booking)
                              : null,
                        ),
                      );
                    },
                    childCount: state.bookings.length,
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

  Future<void> _showCancelDialog(BookingEntity booking) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l.cancelBooking),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l.cancelBookingConfirm(booking.zoneName ?? "esta zona"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: context.l.reasonOptional,
                hintText: context.l.reasonExample,
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l.back),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: context.colors.onGradient,
            ),
            child: Text(context.l.cancelBooking),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(bookingControllerProvider.notifier).cancelBooking(
            booking.id,
            reason: reasonController.text.trim().isNotEmpty
                ? reasonController.text.trim()
                : null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.bookingCancelled),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Future<void> _approveBooking(BookingEntity booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l.approveBooking),
        content: Text(context.l.approveBookingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: context.colors.onGradient,
            ),
            child: Text(context.l.approveBooking),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(bookingControllerProvider.notifier).approveBooking(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.bookingApproved),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
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
            onPressed: () => context.pushNamed('newBooking'),
            tooltip: context.l.newBooking,
          ),
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              context.l.bookingsTitle,
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
}

// ─────────────────────────────────────────
// Zone Filter Bar
// ─────────────────────────────────────────

IconData _zoneIconForType(String? type) {
  switch (type) {
    case 'pool':
      return Icons.pool;
    case 'court':
      return Icons.sports_tennis;
    case 'gym':
      return Icons.fitness_center;
    case 'room':
      return Icons.meeting_room;
    case 'playground':
      return Icons.child_care;
    case 'bbq':
      return Icons.outdoor_grill;
    default:
      return Icons.place;
  }
}

class _ZoneFilterBar extends StatelessWidget {
  final List<_ZoneFilter> zones;
  final String? selectedZoneId;
  final bool myOnly;
  final ValueChanged<String?> onZoneSelected;
  final VoidCallback onMyOnlyToggled;

  const _ZoneFilterBar({
    required this.zones,
    required this.selectedZoneId,
    required this.myOnly,
    required this.onZoneSelected,
    required this.onMyOnlyToggled,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = selectedZoneId == null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // "Mis reservas" toggle
            _FilterChipButton(
              label: context.l.myBookings,
              icon: Icons.person_rounded,
              isSelected: myOnly,
              color: AppColors.primary,
              onTap: onMyOnlyToggled,
            ),
            const SizedBox(width: 6),
            // Vertical divider
            Container(
              width: 1,
              height: 28,
              color: context.colors.textTertiary.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 6),
            // "All" chip
            _FilterChipButton(
              label: context.l.allZones,
              icon: Icons.grid_view_rounded,
              isSelected: isAll,
              color: AppColors.primary,
              onTap: () => onZoneSelected(null),
            ),
            const SizedBox(width: 8),
            // One chip per zone
            for (final zone in zones) ...[
              _FilterChipButton(
                label: zone.name,
                icon: _zoneIconForType(zone.zoneType),
                isSelected: selectedZoneId == zone.id,
                color: _chipColorForType(zone.zoneType),
                onTap: () => onZoneSelected(zone.id),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Color _chipColorForType(String type) {
    switch (type) {
      case 'pool':
        return const Color(0xFF0EA5E9);
      case 'court':
        return const Color(0xFF10B981);
      case 'gym':
        return const Color(0xFFF59E0B);
      case 'room':
        return const Color(0xFF8B5CF6);
      case 'playground':
        return const Color(0xFFEC4899);
      case 'bbq':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : context.colors.textTertiary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? context.colors.onGradient : context.colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? context.colors.onGradient : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Booking Card Widget
// ─────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onCancel;
  final VoidCallback? onApprove;

  const _BookingCard({
    required this.booking,
    this.onCancel,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPast = booking.endTime.isBefore(now);
    final isActive = booking.startTime.isBefore(now) && booking.endTime.isAfter(now);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (booking.isCancelled) {
      statusColor = const Color(0xFFEF4444);
      statusText = context.l.statusCancelled;
      statusIcon = Icons.cancel_rounded;
    } else if (isPast) {
      statusColor = const Color(0xFF6B7280);
      statusText = context.l.statusCompleted;
      statusIcon = Icons.check_circle_rounded;
    } else if (isActive) {
      statusColor = const Color(0xFF10B981);
      statusText = context.l.statusInProgress;
      statusIcon = Icons.play_circle_filled_rounded;
    } else if (booking.isPending) {
      statusColor = const Color(0xFFF59E0B);
      statusText = context.l.statusPending;
      statusIcon = Icons.hourglass_top_rounded;
    } else {
      statusColor = const Color(0xFF3B82F6);
      statusText = context.l.statusConfirmed;
      statusIcon = Icons.verified_rounded;
    }

    final dateFmt = DateFormat('EEE, d MMM', 'es_ES');
    final timeFmt = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          ...context.colors.softShadow,
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Color accent bar + status ─────────────────────────────────
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withValues(alpha: 0.4)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: zone & status chip ─────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zone icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: booking.isCancelled
                            ? LinearGradient(
                                colors: [context.colors.neutral.withAlpha(77), context.colors.neutral.withAlpha(102)])
                            : LinearGradient(colors: [
                                statusColor.withValues(alpha: 0.15),
                                statusColor.withValues(alpha: 0.05),
                              ]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _zoneIcon(booking.zoneType),
                        color: booking.isCancelled ? context.colors.neutral : statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Zone name + type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.zoneName ?? context.l.zone,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                              decoration: booking.isCancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: context.colors.textTertiary,
                            ),
                          ),
                          if (booking.zoneType != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _zoneTypeLabel(context, booking.zoneType!),
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 13, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Date & time row ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 16, color: AppColors.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateFmt.format(booking.startTime),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${timeFmt.format(booking.startTime)} – ${timeFmt.format(booking.endTime)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Notes ──────────────────────────────────────────────
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes_rounded, size: 15,
                          color: context.colors.textTertiary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.notes!,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // ── Cancellation reason ────────────────────────────────
                if (booking.cancellationReason != null &&
                    booking.cancellationReason!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 15,
                            color: Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.l.reason(booking.cancellationReason!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Bottom row: user + time ago + actions ──────────────
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          (booking.userName ?? 'U')[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.onGradient,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (booking.userName != null)
                            Text(
                              booking.userName!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            timeago.format(booking.createdAt, locale: 'es'),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onApprove != null)
                      TextButton.icon(
                        onPressed: onApprove,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: AppColors.success.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(
                          context.l.approveBooking,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (onCancel != null)
                      TextButton.icon(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFF59E0B),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: Text(
                          context.l.cancelBookingTooltip,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _zoneIcon(String? type) => _zoneIconForType(type);

  String _zoneTypeLabel(BuildContext context, String type) {
    switch (type) {
      case 'pool':
        return context.l.zoneTypePool;
      case 'court':
        return context.l.zoneTypeCourt;
      case 'gym':
        return context.l.zoneTypeGym;
      case 'room':
        return context.l.zoneTypeRoom;
      case 'playground':
        return context.l.zoneTypePlayground;
      case 'bbq':
        return context.l.zoneTypeBbq;
      default:
        return type;
    }
  }
}