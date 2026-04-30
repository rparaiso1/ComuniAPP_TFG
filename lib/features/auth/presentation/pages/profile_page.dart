import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/di/locale_provider.dart';
import '../../../../core/di/theme_provider.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/user_role.dart';
import '../controllers/auth_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l.logout,
      message: context.l.logoutConfirm,
      confirmText: context.l.logout,
      confirmColor: AppColors.error,
      icon: Icons.logout,
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

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
                    onPressed: () => context.canPop() ? context.pop() : context.goNamed('home'),
                  ),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        context.l.myProfile,
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

              // Profile content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: AppColors.mediumShadow,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(user?.name ?? ''),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: context.colors.onGradient,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? context.l.userFallback,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user?.role),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.role.localizedName(context) ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.onGradient,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Data cards
                      _ProfileDataCard(
                        icon: Icons.email_outlined,
                        label: context.l.emailField,
                        value: user?.email ?? '-',
                        canRequest: true,
                        onRequestChange: () => _showChangeRequestDialog(
                          context,
                          context.l.emailField,
                          user?.email ?? '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ProfileDataCard(
                        icon: Icons.person_outlined,
                        label: context.l.fullName,
                        value: user?.name ?? '-',
                        canRequest: true,
                        onRequestChange: () => _showChangeRequestDialog(
                          context,
                          context.l.fullName,
                          user?.name ?? '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ProfileDataCard(
                        icon: Icons.phone_outlined,
                        label: context.l.phone,
                        value: user?.phone ?? context.l.notSpecified,
                        canRequest: true,
                        onRequestChange: () => _showChangeRequestDialog(
                          context,
                          context.l.phone,
                          user?.phone ?? '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ProfileDataCard(
                        icon: Icons.home_outlined,
                        label: context.l.dwelling,
                        value: user?.dwellingId ?? context.l.notSpecified,
                        canRequest: true,
                        onRequestChange: () => _showChangeRequestDialog(
                          context,
                          context.l.dwelling,
                          user?.dwellingId ?? '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ProfileDataCard(
                        icon: Icons.shield_outlined,
                        label: context.l.role,
                        value: user?.role.localizedName(context) ?? '-',
                        canRequest: false,
                      ),
                      const SizedBox(height: 12),
                      _ProfileDataCard(
                        icon: Icons.calendar_today_outlined,
                        label: context.l.memberSince,
                        value: user != null
                            ? '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                            : '-',
                        canRequest: false,
                      ),
                      const SizedBox(height: 24),

                      // Info text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.l.profileEditHint,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Change password button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showChangePasswordDialog(context),
                          icon: const Icon(Icons.lock_outline, color: AppColors.primary),
                          label: Text(
                            context.l.changePassword,
                            style: const TextStyle(color: AppColors.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Language switcher
                      _LanguageSwitcher(),
                      const SizedBox(height: 16),

                      // Theme mode switcher
                      _ThemeModeSwitcher(),
                      const SizedBox(height: 24),

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleLogout(context, ref),
                          icon: const Icon(Icons.logout, color: AppColors.error),
                          label: Text(
                            context.l.logout,
                            style: const TextStyle(color: AppColors.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
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

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l.changePassword),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPwdCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.l.currentPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? context.l.validatorPasswordRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPwdCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.l.newPassword,
                  prefixIcon: const Icon(Icons.lock_reset),
                  helperText: context.l.passwordRequirements,
                  helperMaxLines: 2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return context.l.validatorPasswordRequired;
                  if (v.length < 8) return context.l.validatorPasswordMinLength(8);
                  if (!v.contains(RegExp(r'[A-Z]'))) return context.l.validatorPasswordUppercase;
                  if (!v.contains(RegExp(r'[a-z]'))) return context.l.validatorPasswordLowercase;
                  if (!v.contains(RegExp(r'[0-9]'))) return context.l.validatorPasswordDigit;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPwdCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.l.confirmNewPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v != newPwdCtrl.text) return context.l.passwordsDoNotMatch;
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: context.colors.onGradient,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(context.l.changePassword),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final datasource = ref.read(authRemoteDataSourceProvider);
        await datasource.changePassword(
          currentPassword: currentPwdCtrl.text,
          newPassword: newPwdCtrl.text,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.passwordChanged),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l.changePasswordError}: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Color _getRoleColor(UserRole? role) {
    if (role == null) return context.colors.textSecondary;
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.president:
        return AppColors.warning;
      case UserRole.neighbor:
        return AppColors.primary;
    }
  }

  Future<void> _showChangeRequestDialog(
    BuildContext context,
    String fieldName,
    String currentValue,
  ) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l.requestChange(fieldName)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l.currentValue(currentValue),
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: context.l.newDesiredValue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l.changeRequestNote,
              style: TextStyle(fontSize: 12, color: context.colors.textTertiary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: context.colors.onGradient,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.l.sendRequest),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty && context.mounted) {
      try {
        final datasource = ref.read(authRemoteDataSourceProvider);
        await datasource.requestProfileChange(
          field: fieldName,
          currentValue: currentValue,
          requestedValue: result.trim(),
          title: context.l.profileChangeTitle(fieldName),
          description: context.l.profileChangeDescription(fieldName, currentValue, result.trim()),
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.changeRequestSent(fieldName)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l.changeRequestError}: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }
}

class _ProfileDataCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool canRequest;
  final VoidCallback? onRequestChange;

  const _ProfileDataCard({
    required this.icon,
    required this.label,
    required this.value,
    this.canRequest = false,
    this.onRequestChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: context.colors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (canRequest)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRequestChange,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageSwitcher extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: context.colors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                context.l.language,
                style: TextStyle(
                  fontSize: 15,
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LanguageOption(
                  flag: '🇪🇸',
                  label: 'Español',
                  isSelected: currentLocale.languageCode == 'es',
                  onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('es')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LanguageOption(
                  flag: '🇬🇧',
                  label: 'English',
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSwitcher extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    IconData currentIcon;
    switch (themeMode) {
      case ThemeMode.light:
        currentIcon = Icons.light_mode;
      case ThemeMode.dark:
        currentIcon = Icons.dark_mode;
      case ThemeMode.system:
        currentIcon = Icons.brightness_auto;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: context.colors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(currentIcon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                context.l.themeMode,
                style: TextStyle(
                  fontSize: 15,
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildThemeOption(
                context, ref,
                icon: Icons.light_mode,
                label: context.l.themeModeLight,
                mode: ThemeMode.light,
                currentMode: themeMode,
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                context, ref,
                icon: Icons.dark_mode,
                label: context.l.themeModeDark,
                mode: ThemeMode.dark,
                currentMode: themeMode,
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                context, ref,
                icon: Icons.brightness_auto,
                label: context.l.themeModeSystem,
                mode: ThemeMode.system,
                currentMode: themeMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : context.colors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : context.colors.textSecondary,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 2),
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : context.colors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : context.colors.textSecondary,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
