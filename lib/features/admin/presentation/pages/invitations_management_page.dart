import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';

class InvitationsManagementPage extends ConsumerStatefulWidget {
  const InvitationsManagementPage({super.key});

  @override
  ConsumerState<InvitationsManagementPage> createState() => _InvitationsManagementPageState();
}

class _InvitationsManagementPageState extends ConsumerState<InvitationsManagementPage> {
  List<dynamic> _invitations = [];
  bool _isLoading = false;
  bool _isCreating = false;

  // Controladores del formulario de creación
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dwellingController = TextEditingController();
  String _selectedRole = 'neighbor';

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _dwellingController.dispose();
    super.dispose();
  }

  Map<String, String> get _headers {
    return ref.read(authHeadersProvider);
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/invitations'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        setState(() {
          _invitations = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.l.loadInvitationsError}: $e')),
        );
      }
    }
  }

  Future<void> _createInvitation() async {
    if (_emailController.text.trim().isEmpty || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l.emailAndNameRequired), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final body = {
        'email': _emailController.text.trim(),
        'full_name': _nameController.text.trim(),
        'role': _selectedRole,
      };
      if (_phoneController.text.trim().isNotEmpty) {
        body['phone'] = _phoneController.text.trim();
      }
      if (_dwellingController.text.trim().isNotEmpty) {
        body['dwelling'] = _dwellingController.text.trim();
      }

      final response = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/invitations'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;

        // Limpiar campos
        _emailController.clear();
        _nameController.clear();
        _phoneController.clear();
        _dwellingController.clear();
        setState(() {
          _selectedRole = 'neighbor';
          _isCreating = false;
        });

        _loadInvitations();

        // Mostrar dialog con token
        if (mounted && token != null) {
          _showTokenDialog(token, data['full_name'] ?? '');
        }
      } else {
        final errorBody = jsonDecode(response.body);
        if (!mounted) return;
        throw Exception(errorBody['detail'] ?? context.l.unexpectedError);
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l.errorWithMessage(e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showTokenDialog(String token, String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(child: Text(context.l.invitationCreated)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l.invitationFor(name)),
            const SizedBox(height: 16),
            Text(context.l.registrationToken, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.border),
              ),
              child: SelectableText(
                token,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l.shareTokenHint,
              style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l.tokenCopied), duration: const Duration(seconds: 2)),
              );
            },
            icon: const Icon(Icons.copy),
            label: Text(context.l.copy),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l.accept),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteInvitation(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l.revokeInvitation),
        content: Text(context.l.revokeInvitationConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.error, foregroundColor: context.colors.onGradient),
            child: Text(context.l.delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/invitations/$id'),
        headers: _headers,
      );
      if (response.statusCode == 204) {
        _loadInvitations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l.invitationDeleted), backgroundColor: AppColors.success),
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;

    if (user?.role.isAdminOrPresident != true) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l.noAccess)),
        body: Center(child: Text(context.l.noAccessMessage)),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: ContentConstraint(
        child: RefreshIndicator(
        onRefresh: _loadInvitations,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCreateCard(),
                    const SizedBox(height: 16),
                    _buildHowItWorksCard(),
                    const SizedBox(height: 24),
                    _buildInvitationsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
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
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              context.l.invitationsManagement,
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

  Widget _buildCreateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(context.l.newInvitation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: context.l.emailRequired,
              prefixIcon: const Icon(Icons.email),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: context.l.fullNameRequired,
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: context.l.phoneOptional,
              prefixIcon: const Icon(Icons.phone),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dwellingController,
            decoration: InputDecoration(
              labelText: context.l.dwellingOptional,
              hintText: context.l.dwellingExample,
              prefixIcon: const Icon(Icons.home),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            decoration: InputDecoration(
              labelText: context.l.roleSelect,
              prefixIcon: const Icon(Icons.badge),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'neighbor', child: Text(context.l.roleNeighbor)),
              DropdownMenuItem(value: 'president', child: Text(context.l.rolePresident)),
            ],
            onChanged: (v) => setState(() => _selectedRole = v ?? 'neighbor'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isCreating ? null : _createInvitation,
              icon: _isCreating
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onGradient))
                  : const Icon(Icons.send),
              label: Text(_isCreating ? context.l.creatingInvitation : context.l.createInvitation),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: context.colors.onGradient,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.infoBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: context.colors.info),
              const SizedBox(width: 12),
              Text(context.l.howItWorks, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          _step('1', context.l.step1),
          _step('2', context.l.step2),
          _step('3', context.l.step3),
          _step('4', context.l.step4),
        ],
      ),
    );
  }

  Widget _step(String n, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 12, backgroundColor: context.colors.info, child: Text(n, style: TextStyle(color: context.colors.onGradient, fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: context.colors.textPrimary, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildInvitationsList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_invitations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.mail_outline, size: 48, color: context.colors.textTertiary),
              const SizedBox(height: 12),
              Text(context.l.noInvitationsYet, style: TextStyle(color: context.colors.textSecondary, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l.invitationsSection, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._invitations.map((inv) => _buildInvitationCard(inv)),
      ],
    );
  }

  Widget _buildInvitationCard(dynamic invitation) {
    final status = invitation['status'] as String? ?? 'pending';
    final Color statusColor;
    final String statusLabel;

    switch (status) {
      case 'used':
        statusColor = AppColors.success;
        statusLabel = context.l.statusUsed;
        break;
      case 'expired':
        statusColor = AppColors.error;
        statusLabel = context.l.statusExpired;
        break;
      default:
        statusColor = AppColors.warning;
        statusLabel = context.l.statusPendingUpper;
    }

    final token = invitation['token'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  invitation['full_name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.email, invitation['email'] ?? ''),
          if (invitation['phone'] != null) _infoRow(Icons.phone, invitation['phone']),
          if (invitation['dwelling'] != null) _infoRow(Icons.home, invitation['dwelling']),
          _infoRow(Icons.badge, _roleLabel(invitation['role'] ?? '')),
          if (token != null && status == 'pending') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l.token(token),
                    style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: context.colors.textSecondary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: context.l.copyToken,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: token));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l.tokenCopiedShort), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ],
          if (status == 'pending') ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _deleteInvitation(invitation['id']),
                icon: Icon(Icons.delete_outline, size: 18, color: context.colors.error),
                label: Text(context.l.revoke, style: TextStyle(color: context.colors.error)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.colors.textTertiary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: context.colors.textSecondary))),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return context.l.roleAdmin;
      case 'president':
        return context.l.rolePresident;
      case 'neighbor':
        return context.l.roleNeighbor;
      default:
        return role;
    }
  }
}