import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';

class AdminZonesPage extends ConsumerStatefulWidget {
  const AdminZonesPage({super.key});

  @override
  ConsumerState<AdminZonesPage> createState() => _AdminZonesPageState();
}

class _AdminZonesPageState extends ConsumerState<AdminZonesPage> {
  List<dynamic> _zones = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Map<String, String> get _headers => ref.read(authHeadersProvider);

  Future<void> _loadZones() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/zones?active_only=false'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        setState(() {
          _zones = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l.errorWithMessage(e.toString()))),
        );
      }
    }
  }

  Future<void> _createZone(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/zones'),
        headers: _headers,
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l.zoneCreated)),
          );
        }
        _loadZones();
      } else {
        final err = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err['detail'] ?? context.l.unexpectedError),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l.errorWithMessage(e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _updateZone(String zoneId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/zones/$zoneId'),
        headers: _headers,
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l.zoneUpdated)),
          );
        }
        _loadZones();
      } else {
        final err = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err['detail'] ?? context.l.unexpectedError),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l.errorWithMessage(e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteZone(String zoneId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l.deleteZone),
        content: Text(context.l.deleteZoneConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/zones/$zoneId'),
        headers: _headers,
      );
      if (response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l.zoneDeleted)),
          );
        }
        _loadZones();
      } else {
        final err = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err['detail'] ?? context.l.unexpectedError),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l.errorWithMessage(e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showCreateEditDialog({dynamic zone}) {
    final isEditing = zone != null;
    final nameController =
        TextEditingController(text: zone?['name'] ?? '');
    final descController =
        TextEditingController(text: zone?['description'] ?? '');
    final capacityController = TextEditingController(
        text: zone?['max_capacity']?.toString() ?? '');
    final maxHoursController = TextEditingController(
        text: (zone?['max_booking_hours'] ?? 2).toString());
    final maxBookingsController = TextEditingController(
        text: (zone?['max_bookings_per_user_day'] ?? 1).toString());
    final advanceDaysController = TextEditingController(
        text: (zone?['advance_booking_days'] ?? 30).toString());

    String selectedType = zone?['zone_type'] ?? 'pool';
    bool requiresApproval = zone?['requires_approval'] ?? false;

    final types = ['pool', 'court', 'gym', 'room', 'playground', 'bbq'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? context.l.editZone : context.l.createZone),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: context.l.zoneName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: types.contains(selectedType)
                        ? selectedType
                        : types.first,
                    decoration: InputDecoration(
                      labelText: context.l.zoneDescription,
                      border: const OutlineInputBorder(),
                    ),
                    items: types.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(_zoneTypeLabel(t)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() => selectedType = val!);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: context.l.zoneDescription,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: capacityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l.zoneCapacity,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: maxHoursController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l.maxBookingHours,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: maxBookingsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l.maxBookingsPerDay,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: advanceDaysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l.advanceBookingDays,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(context.l.zoneRequiresApproval),
                    value: requiresApproval,
                    onChanged: (val) {
                      setDialogState(() => requiresApproval = val);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  nameController.dispose();
                  descController.dispose();
                  capacityController.dispose();
                  maxHoursController.dispose();
                  maxBookingsController.dispose();
                  advanceDaysController.dispose();
                },
                child: Text(context.l.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  final data = <String, dynamic>{
                    'name': nameController.text.trim(),
                    'zone_type': selectedType,
                    'requires_approval': requiresApproval,
                  };
                  if (descController.text.trim().isNotEmpty) {
                    data['description'] = descController.text.trim();
                  }
                  final cap = int.tryParse(capacityController.text.trim());
                  if (cap != null) data['max_capacity'] = cap;
                  final mh = int.tryParse(maxHoursController.text.trim());
                  if (mh != null) data['max_booking_hours'] = mh;
                  final mb =
                      int.tryParse(maxBookingsController.text.trim());
                  if (mb != null) data['max_bookings_per_user_day'] = mb;
                  final ad =
                      int.tryParse(advanceDaysController.text.trim());
                  if (ad != null) data['advance_booking_days'] = ad;

                  Navigator.pop(ctx);
                  nameController.dispose();
                  descController.dispose();
                  capacityController.dispose();
                  maxHoursController.dispose();
                  maxBookingsController.dispose();
                  advanceDaysController.dispose();

                  if (isEditing) {
                    _updateZone(zone['id'].toString(), data);
                  } else {
                    _createZone(data);
                  }
                },
                child: Text(context.l.save),
              ),
            ],
          );
        },
      ),
    );
  }

  String _zoneTypeLabel(String type) {
    switch (type.toLowerCase()) {
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

  IconData _zoneTypeIcon(String type) {
    switch (type.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.manageZones),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEditDialog(),
        icon: const Icon(Icons.add),
        label: Text(context.l.createZone),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _zones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.place_outlined,
                          size: 64, color: context.colors.textTertiary),
                      const SizedBox(height: 16),
                      Text(context.l.noZones,
                          style: TextStyle(
                              color: context.colors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadZones,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.isDesktop ? 32 : 16,
                      vertical: 8,
                    ),
                    itemCount: _zones.length,
                    itemBuilder: (context, index) {
                      final zone = _zones[index];
                      return _ZoneCard(
                        zone: zone,
                        zoneTypeLabel: _zoneTypeLabel,
                        zoneTypeIcon: _zoneTypeIcon,
                        onEdit: () => _showCreateEditDialog(zone: zone),
                        onDelete: () =>
                            _deleteZone(zone['id'].toString()),
                      );
                    },
                  ),
                ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final dynamic zone;
  final String Function(String) zoneTypeLabel;
  final IconData Function(String) zoneTypeIcon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ZoneCard({
    required this.zone,
    required this.zoneTypeLabel,
    required this.zoneTypeIcon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = zone['name'] ?? '';
    final type = (zone['zone_type'] ?? '').toString();
    final description = zone['description'] ?? '';
    final isActive = zone['is_active'] == true;
    final capacity = zone['max_capacity'];
    final requiresApproval = zone['requires_approval'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(zoneTypeIcon(type),
                      color: Theme.of(context).colorScheme.primary),
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
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (!isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.l.inactive,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        zoneTypeLabel(type),
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (capacity != null)
                  _InfoChip(
                    icon: Icons.people_outline,
                    label: '$capacity',
                  ),
                if (requiresApproval)
                  _InfoChip(
                    icon: Icons.approval,
                    label: context.l.zoneRequiresApproval,
                  ),
                _InfoChip(
                  icon: Icons.schedule,
                  label:
                      '${zone['available_from'] ?? '08:00'} - ${zone['available_until'] ?? '22:00'}',
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(context.l.editZone),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(context.l.deleteZone),
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.colors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
        ),
      ],
    );
  }
}
