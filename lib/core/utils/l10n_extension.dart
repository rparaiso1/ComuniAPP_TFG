import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../features/auth/domain/entities/user_role.dart';

/// Convenience extension to access localizations from BuildContext.
/// Usage: context.l.someKey
extension LocalizationExt on BuildContext {
  S get l => S.of(this)!;
}

/// Extension to get localized role name from UserRole.
/// Usage: role.localizedName(context)
extension UserRoleLocalizationExt on UserRole {
  String localizedName(BuildContext context) {
    switch (this) {
      case UserRole.admin:
        return context.l.roleAdmin;
      case UserRole.president:
        return context.l.rolePresident;
      case UserRole.neighbor:
        return context.l.roleNeighbor;
    }
  }
}
