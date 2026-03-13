import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/l10n_extension.dart';
import '../../features/home/presentation/providers/community_provider.dart';
import '../../features/home/presentation/providers/dashboard_stats_provider.dart';

/// Compact organization selector widget for app bars and headers.
/// Shows a dropdown when the user belongs to multiple organizations.
class OrgSelectorChip extends ConsumerWidget {
  const OrgSelectorChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityState = ref.watch(communityControllerProvider);
    final theme = Theme.of(context);

    if (communityState.organizations.length <= 1) {
      // Single org — show as label
      final orgName = communityState.selected?.name ?? '';
      if (orgName.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                orgName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Multiple orgs — dropdown
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.apartment, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: communityState.selected?.id,
                isDense: true,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                icon: Icon(Icons.expand_more, size: 20, color: theme.colorScheme.primary),
                items: communityState.organizations.map((org) {
                  return DropdownMenuItem(
                    value: org.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: Text(org.name, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 6),
                        _RoleBadge(role: org.role),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id != null) {
                    final org = communityState.organizations.firstWhere((o) => o.id == id);
                    ref.read(communityControllerProvider.notifier).selectOrganization(org);
                    ref.invalidate(dashboardStatsProvider);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (role.toUpperCase()) {
      case 'ADMIN':
        color = AppColors.error;
        label = context.l.roleAdmin;
        break;
      case 'PRESIDENT':
        color = AppColors.warning;
        label = context.l.rolePresident;
        break;
      default:
        color = AppColors.info;
        label = context.l.roleNeighbor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
