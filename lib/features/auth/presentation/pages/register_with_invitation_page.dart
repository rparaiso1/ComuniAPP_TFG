import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';

/// Página de registro con invitación (solo token + contraseña).
/// Flujo simplificado: 
/// 1. Introducir token de invitación
/// 2. Se verifica automáticamente
/// 3. Crear contraseña y completar registro
class RegisterWithInvitationPage extends ConsumerStatefulWidget {
  final String? token;

  const RegisterWithInvitationPage({super.key, this.token});

  @override
  ConsumerState<RegisterWithInvitationPage> createState() => _RegisterWithInvitationPageState();
}

class _RegisterWithInvitationPageState extends ConsumerState<RegisterWithInvitationPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isVerifying = false;
  bool _isRegistering = false;
  bool _isVerified = false;
  String? _errorMessage;
  Map<String, dynamic>? _invitationData;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _tokenController.text = widget.token!;
      // Auto-verificar si viene con token
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyInvitation();
      });
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyInvitation() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _errorMessage = context.l.enterInvitationToken);
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/invitations/verify/$token'),
      );

      final data = jsonDecode(response.body);

      if (data['valid'] == true) {
        setState(() {
          _isVerified = true;
          _invitationData = data['invitation'];
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = data['message'] ?? context.l.registrationError;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${context.l.connectionError}: $e';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = context.l.passwordsDoNotMatch;
      });
      return;
    }

    setState(() {
      _isRegistering = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/invitations/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': _tokenController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 32),
                  const SizedBox(width: 12),
                  Text(context.l.registrationComplete),
                ],
              ),
              content: Text(
                context.l.accountCreatedMessage(data['user']['email'] ?? '', data['user']['dwelling'] ?? ''),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(context.l.goToLogin),
                ),
              ],
            ),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['detail'] ?? context.l.registrationError;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${context.l.connectionError}: $e';
      });
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FormConstraint(
        child: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isVerified) ...[
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildTokenForm(),
                    ] else ...[
                      _buildInvitationInfo(),
                      const SizedBox(height: 24),
                      _buildPasswordForm(),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                        color: context.colors.errorBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.error),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: context.colors.error),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              context.l.registerTitle,
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.infoBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline, color: AppColors.info),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l.haveInvitation,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.l.invitationExplanation,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _tokenController,
            decoration: InputDecoration(
              labelText: context.l.invitationTokenLabel,
              hintText: context.l.invitationTokenHint,
              prefixIcon: const Icon(Icons.vpn_key),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l.enterInvitationToken;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isVerifying ? null : _verifyInvitation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: context.colors.onGradient,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isVerifying
                ? CircularProgressIndicator(color: context.colors.onGradient)
                : Text(
                    context.l.verifyInvitation,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationInfo() {
    final roleDisplay = {
      'admin': context.l.roleAdmin,
      'president': context.l.rolePresident,
      'neighbor': context.l.roleNeighbor,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.successBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              const SizedBox(width: 12),
              Text(
                context.l.validInvitation,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context.l.nameLabel, _invitationData?['full_name'] ?? ''),
          _buildInfoRow(context.l.emailLabel, _invitationData?['email'] ?? ''),
          _buildInfoRow(context.l.dwellingLabel, _invitationData?['dwelling'] ?? ''),
          _buildInfoRow(context.l.roleLabel, roleDisplay[_invitationData?['role']] ?? _invitationData?['role'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l.choosePassword,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: context.l.password,
              hintText: context.l.minChars,
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 8) {
                return context.l.minChars;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: context.l.confirmPassword,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return context.l.passwordsDoNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isRegistering ? null : _completeRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: context.colors.onGradient,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isRegistering
                ? CircularProgressIndicator(color: context.colors.onGradient)
                : Text(
                    context.l.completeRegistration,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
