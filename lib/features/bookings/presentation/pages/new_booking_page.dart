import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../controllers/booking_controller.dart';

/// Modelo ligero para las zonas obtenidas de la API
class _ZoneItem {
  final String id;
  final String name;
  final String zoneType;
  final int maxBookingHours;

  _ZoneItem({
    required this.id,
    required this.name,
    required this.zoneType,
    required this.maxBookingHours,
  });

  factory _ZoneItem.fromJson(Map<String, dynamic> json) {
    return _ZoneItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      zoneType: json['zone_type'] ?? '',
      maxBookingHours: json['max_booking_hours'] ?? 2,
    );
  }
}

class NewBookingPage extends ConsumerStatefulWidget {
  const NewBookingPage({super.key});

  @override
  ConsumerState<NewBookingPage> createState() => _NewBookingPageState();
}

class _NewBookingPageState extends ConsumerState<NewBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  List<_ZoneItem> _zones = [];
  bool _loadingZones = true;
  _ZoneItem? _selectedZone;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
        setState(() {
          _zones = data.map((z) => _ZoneItem.fromJson(z)).toList();
          _loadingZones = false;
        });
      } else {
        setState(() => _loadingZones = false);
      }
    } catch (_) {
      setState(() => _loadingZones = false);
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initialDate = isStart
        ? DateTime.now()
        : (_startDate ?? DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStart ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startDate = picked;
        // Auto-set end = start + max hours
        if (_selectedZone != null) {
          _endDate = picked.add(Duration(hours: _selectedZone!.maxBookingHours));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedZone == null) {
      ErrorDialog.show(context, title: context.l.zoneRequired, message: context.l.selectZone);
      return;
    }
    if (_startDate == null || _endDate == null) {
      ErrorDialog.show(context, title: context.l.datesRequired, message: context.l.selectDates);
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ErrorDialog.show(context, title: context.l.invalidDates, message: context.l.endAfterStart);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(bookingControllerProvider.notifier).createBooking(
            zoneId: _selectedZone!.id,
            startTime: _startDate!,
            endTime: _endDate!,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );

      if (!mounted) return;

      final state = ref.read(bookingControllerProvider);
      if (state.error != null) {
        ErrorDialog.show(
          context,
          title: context.l.createBookingError,
          message: ErrorDialog.getFriendlyMessage(context, state.error!),
        );
        setState(() => _isSubmitting = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l.bookingCreated), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      ErrorDialog.show(context, title: context.l.error, message: e.toString());
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.colors.backgroundGradient,
        ),
        child: SafeArea(
          child: FormConstraint(
            child: CustomScrollView(
              slivers: [
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
                      onPressed: () => context.canPop() ? context.pop() : context.goNamed('bookings'),
                    ),
                  ),
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(
                          context.l.newBooking,
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
                if (_loadingZones)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_zones.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.warningLight),
                          const SizedBox(height: 16),
                          Text(context.l.noZonesAvailable, style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(
                            context.l.adminMustCreateZones,
                            style: TextStyle(color: context.colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Zone selector ──
                            Text(context.l.zone, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textSecondary)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _zones.map((zone) {
                                final selected = _selectedZone?.id == zone.id;
                                return ChoiceChip(
                                  label: Text(zone.name),
                                  avatar: Icon(_zoneIcon(zone.zoneType), size: 18),
                                  selected: selected,
                                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                  onSelected: (_) => setState(() => _selectedZone = zone),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // ── Start date ──
                            _DateTile(
                              label: context.l.start,
                              value: _startDate,
                              onTap: () => _pickDateTime(isStart: true),
                            ),

                            const SizedBox(height: 12),

                            // ── End date ──
                            _DateTile(
                              label: context.l.end,
                              value: _endDate,
                              onTap: () => _pickDateTime(isStart: false),
                            ),

                            const SizedBox(height: 24),

                            // ── Notes ──
                            TextFormField(
                              controller: _notesController,
                              decoration: InputDecoration(
                                labelText: context.l.notesOptional,
                                hintText: context.l.notesExample,
                                prefixIcon: const Icon(Icons.notes),
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),

                            const SizedBox(height: 32),

                            // ── Submit ──
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submit,
                                icon: _isSubmitting
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onGradient),
                                      )
                                    : const Icon(Icons.check),
                                label: Text(_isSubmitting ? context.l.creating : context.l.createBooking),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: context.colors.onGradient,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
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

  IconData _zoneIcon(String type) {
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
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateTile({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              value != null
                  ? '$label: ${DateFormat('dd/MM/yyyy HH:mm').format(value!)}'
                  : '$label: ${context.l.tapToSelect}',
              style: TextStyle(
                fontSize: 15,
                color: value != null ? context.colors.textPrimary : context.colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
