import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = false;
  String _filter = 'all'; // all, active, inactive
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, String> get _headers => ref.read(authHeadersProvider);

  String? get _currentUserId {
    final user = ref.read(authControllerProvider).user;
    return user?.id;
  }

  bool get _isCurrentUserAdmin {
    final user = ref.read(authControllerProvider).user;
    return user?.role.value == 'admin';
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/admin/users'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        setState(() {
          _users = jsonDecode(response.body);
          _isLoading = false;
        });
        _applyFilters();
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

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((u) {
        final matchesSearch = query.isEmpty ||
            (u['full_name'] ?? '').toString().toLowerCase().contains(query) ||
            (u['email'] ?? '').toString().toLowerCase().contains(query);
        final isActive = u['is_active'] == true;
        final matchesFilter = _filter == 'all' ||
            (_filter == 'active' && isActive) ||
            (_filter == 'inactive' && !isActive);
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _toggleUser(dynamic user) async {
    final userId = user['id'];
    try {
      final response = await http.put(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/admin/users/$userId/toggle'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final isNowActive = !(user['is_active'] == true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isNowActive
                  ? context.l.userActivated
                  : context.l.userDeactivated),
            ),
          );
        }
        _loadUsers();
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

  Future<void> _changeRole(dynamic user, String newRole) async {
    final userId = user['id'];
    try {
      final response = await http.put(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/admin/users/$userId/role'),
        headers: _headers,
        body: jsonEncode({'role': newRole}),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l.roleChanged)),
          );
        }
        _loadUsers();
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

  Future<void> _resetPassword(dynamic user) async {
    final userId = user['id'];
    final userName = user['full_name'] ?? user['email'] ?? '';
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l.resetPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l.newPasswordFor(userName)),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.l.newPassword,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l.resetPassword),
          ),
        ],
      ),
    );

    if (confirmed != true || passwordController.text.trim().isEmpty) {
      passwordController.dispose();
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
            '${EnvConfig.apiBaseUrl}/api/admin/users/$userId/reset-password'),
        headers: _headers,
        body: jsonEncode({'new_password': passwordController.text.trim()}),
      );
      passwordController.dispose();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l.passwordResetSuccess)),
          );
        }
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
      passwordController.dispose();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l.errorWithMessage(e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showChangeRoleDialog(dynamic user) {
    final currentRole =
        (user['role'] ?? 'neighbor').toString().toLowerCase();
    String selectedRole = currentRole;

    // Roles available depending on current user
    final roles = <String>['neighbor', 'president'];
    if (_isCurrentUserAdmin) {
      roles.add('admin');
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(context.l.changeRole),
          content: RadioGroup<String>(
            groupValue: selectedRole,
            onChanged: (val) {
              if (val != null) setDialogState(() => selectedRole = val);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: roles.map((role) {
                return RadioListTile<String>(
                  value: role,
                  title: Text(_roleLabel(role)),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l.cancel),
            ),
            ElevatedButton(
              onPressed: selectedRole == currentRole
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      _changeRole(user, selectedRole);
                    },
              child: Text(context.l.save),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return context.l.roleAdmin;
      case 'president':
        return context.l.rolePresident;
      default:
        return context.l.roleNeighbor;
    }
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'president':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.adminUsers),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l.searchUsers,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: context.l.allUsers,
                  selected: _filter == 'all',
                  onTap: () {
                    setState(() => _filter = 'all');
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: context.l.activeUsers,
                  selected: _filter == 'active',
                  onTap: () {
                    setState(() => _filter = 'active');
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: context.l.inactiveUsers,
                  selected: _filter == 'inactive',
                  onTap: () {
                    setState(() => _filter = 'inactive');
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64,
                                color: context.colors.textTertiary),
                            const SizedBox(height: 16),
                            Text(context.l.noUsers,
                                style: TextStyle(
                                    color: context.colors.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: r.isDesktop ? 32 : 16,
                            vertical: 8,
                          ),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _UserCard(
                              user: user,
                              isSelf: user['id'] == _currentUserId,
                              onToggle: () => _toggleUser(user),
                              onChangeRole: () => _showChangeRoleDialog(user),
                              onResetPassword: () => _resetPassword(user),
                              roleLabel: _roleLabel,
                              roleColor: _roleColor,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _UserCard extends StatelessWidget {
  final dynamic user;
  final bool isSelf;
  final VoidCallback onToggle;
  final VoidCallback onChangeRole;
  final VoidCallback onResetPassword;
  final String Function(String) roleLabel;
  final Color Function(String) roleColor;

  const _UserCard({
    required this.user,
    required this.isSelf,
    required this.onToggle,
    required this.onChangeRole,
    required this.onResetPassword,
    required this.roleLabel,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    final name = user['full_name'] ?? user['email'] ?? '';
    final email = user['email'] ?? '';
    final role = (user['role'] ?? 'neighbor').toString().toLowerCase();
    final isActive = user['is_active'] == true;
    final phone = user['phone'] ?? '';
    final dwelling = user['dwelling'] ?? '';

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
                  backgroundColor: roleColor(role).withValues(alpha: 0.15),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: roleColor(role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor(role).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              roleLabel(role),
                              style: TextStyle(
                                color: roleColor(role),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        email,
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
            if (phone.isNotEmpty || dwelling.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (phone.isNotEmpty) ...[
                    Icon(Icons.phone_outlined,
                        size: 14, color: context.colors.textTertiary),
                    const SizedBox(width: 4),
                    Text(phone,
                        style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textSecondary)),
                    const SizedBox(width: 16),
                  ],
                  if (dwelling.isNotEmpty) ...[
                    Icon(Icons.home_outlined,
                        size: 14, color: context.colors.textTertiary),
                    const SizedBox(width: 4),
                    Text(dwelling,
                        style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textSecondary)),
                  ],
                ],
              ),
            ],
            if (!isActive) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l.inactiveUsers,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (!isSelf) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onToggle,
                    icon: Icon(
                      isActive
                          ? Icons.person_off_outlined
                          : Icons.person_outlined,
                      size: 18,
                    ),
                    label: Text(context.l.toggleActive),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isActive ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onChangeRole,
                    icon: const Icon(Icons.shield_outlined, size: 18),
                    label: Text(context.l.changeRole),
                  ),
                  TextButton.icon(
                    onPressed: onResetPassword,
                    icon: const Icon(Icons.lock_reset_outlined, size: 18),
                    label: Text(context.l.resetPassword),
                    style:
                        TextButton.styleFrom(foregroundColor: AppColors.error),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
