import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/entities/user_organization.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import 'local_storage_service.dart';

/// Manages the currently selected organization for multi-org users.
/// Persists the selection in Hive and sends X-Organization-ID header.
class OrgSelectorService extends Notifier<String?> {
  late final LocalStorageService _storage;
  static const _storageKey = 'selected_org_id';

  @override
  String? build() {
    _storage = LocalStorageService();
    // Restore persisted org
    final saved = _storage.getSetting(_storageKey);
    if (saved is String && saved.isNotEmpty) {
      return saved;
    }
    return null;
  }

  /// Select an organization by ID
  void selectOrg(String orgId) {
    state = orgId;
    _storage.saveSetting(_storageKey, orgId);
  }

  /// Clear selection (use all orgs)
  void clearSelection() {
    state = null;
    _storage.deleteSetting(_storageKey);
  }
}

/// Provider for the currently selected organization ID
final selectedOrgIdProvider = NotifierProvider<OrgSelectorService, String?>(
  () => OrgSelectorService(),
);

/// Provider resolving the effective organization ID.
/// Returns the user-selected org, or the first org if only one, or null if none.
final activeOrgIdProvider = Provider<String?>((ref) {
  final selectedId = ref.watch(selectedOrgIdProvider);
  final authState = ref.watch(authControllerProvider);
  final user = authState.user;

  if (user == null) return null;

  final orgs = user.organizations;
  if (orgs.isEmpty) return null;
  if (orgs.length == 1) return orgs.first.organizationId;

  // If selected ID is valid for this user, use it
  if (selectedId != null && orgs.any((o) => o.organizationId == selectedId)) {
    return selectedId;
  }

  // Default to first org
  return orgs.first.organizationId;
});

/// Provider for the active organization entity
final activeOrgProvider = Provider<UserOrganization?>((ref) {
  final activeId = ref.watch(activeOrgIdProvider);
  final authState = ref.watch(authControllerProvider);
  final user = authState.user;

  if (user == null || activeId == null) return null;
  try {
    return user.organizations.firstWhere((o) => o.organizationId == activeId);
  } catch (_) {
    return user.organizations.isNotEmpty ? user.organizations.first : null;
  }
});

/// Whether the user has multiple organizations
final hasMultipleOrgsProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return (authState.user?.organizations.length ?? 0) > 1;
});
