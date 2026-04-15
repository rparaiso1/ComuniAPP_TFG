import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoggingIn = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      await ref.read(authControllerProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      final authState = ref.read(authControllerProvider);

      if (authState.error != null) {
        final friendlyMessage = ErrorDialog.getFriendlyMessage(context, authState.error!);
        ErrorDialog.show(
          context,
          title: context.l.loginError,
          message: friendlyMessage,
          onRetry: _handleLogin,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      final friendlyMessage = ErrorDialog.getFriendlyMessage(context, e.toString());
      ErrorDialog.show(
        context,
        title: context.l.unexpectedError,
        message: friendlyMessage,
        onRetry: _handleLogin,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos cambios de autenticación para reaccionar apropiadamente
    ref.listen(authControllerProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.goNamed('home');
      }
    });

    return Scaffold(
      body: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final gradientColors = isDark
              ? const [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)]
              : const [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF0EA5E9)];
          // Glass overlay tint
          final glassBg = isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.15);
          final glassBorder = isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.2);
          // Text on gradient
          final headlineColor = Colors.white;
          final subtitleColor = Colors.white.withValues(alpha: 0.9);
          // Input field styling
          final inputBg = isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.95);
          final inputBorderColor = isDark
              ? const Color(0xFF475569).withValues(alpha: 0.4)
              : const Color(0xFF2563EB).withValues(alpha: 0.2);
          final inputTextColor = isDark
              ? const Color(0xFFF1F5F9)
              : const Color(0xFF1E293B);
          final inputLabelColor = isDark
              ? const Color(0xFFCBD5E1).withValues(alpha: 0.7)
              : const Color(0xFF1E293B).withValues(alpha: 0.6);
          final inputIconColor = isDark
              ? const Color(0xFF60A5FA).withValues(alpha: 0.8)
              : const Color(0xFF2563EB).withValues(alpha: 0.7);
          final inputShadowColor = isDark
              ? Colors.black.withValues(alpha: 0.2)
              : const Color(0xFF2563EB).withValues(alpha: 0.1);
          // Button
          final buttonGradient = isDark
              ? const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF1E293B)])
              : const LinearGradient(colors: [Color(0xFFF0F4FF), Colors.white]);
          final buttonForeground = isDark
              ? const Color(0xFF60A5FA)
              : const Color(0xFF2563EB);
          final buttonDisabledBg = isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo con animación
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: glassBg,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: glassBorder,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.apartment,
                          size: 80,
                          color: headlineColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      context.l.welcome,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: headlineColor,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l.communityManagement,
                      style: TextStyle(
                        fontSize: 16,
                        color: subtitleColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Card glassmorphism
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: glassBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: glassBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _GlassTextField(
                              controller: _emailController,
                              labelText: context.l.email,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_isLoggingIn,
                              validator: FormValidators.email(context),
                              textInputAction: TextInputAction.next,
                              backgroundColor: inputBg,
                              borderColor: inputBorderColor,
                              textColor: inputTextColor,
                              labelColor: inputLabelColor,
                              iconColor: inputIconColor,
                              shadowColor: inputShadowColor,
                            ),
                            const SizedBox(height: 20),
                            _GlassTextField(
                              controller: _passwordController,
                              labelText: context.l.password,
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              enabled: !_isLoggingIn,
                              validator: FormValidators.required(context, fieldName: context.l.thePassword),
                              onFieldSubmitted: _handleLogin,
                              textInputAction: TextInputAction.done,
                              backgroundColor: inputBg,
                              borderColor: inputBorderColor,
                              textColor: inputTextColor,
                              labelColor: inputLabelColor,
                              iconColor: inputIconColor,
                              shadowColor: inputShadowColor,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: inputIconColor,
                                  size: 22,
                                ),
                                tooltip: _obscurePassword ? context.l.showPassword : context.l.hidePassword,
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          const SizedBox(height: 32),
                          // Botón con gradiente
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: _isLoggingIn
                                  ? null
                                  : buttonGradient,
                              color: _isLoggingIn
                                  ? buttonDisabledBg
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoggingIn ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: buttonForeground,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoggingIn
                                  ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      buttonForeground),
                                ),
                              )
                                  : Text(
                                context.l.login,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Link para registro con SMS
                          TextButton(
                            onPressed: () => context.goNamed('registerSms'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mail_outline,
                                  color: subtitleColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    context.l.hasInvitation,
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),  // Cierra Container con Form
                  ],
                ),
              ),
            ),
          ),
        ),
      );
        },
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? Function(String?)? validator;
  final VoidCallback? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color labelColor;
  final Color iconColor;
  final Color shadowColor;

  const _GlassTextField({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.labelColor,
    required this.iconColor,
    required this.shadowColor,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.validator,
    this.onFieldSubmitted,
    this.textInputAction,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: enabled,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onFieldSubmitted: onFieldSubmitted != null ? (_) => onFieldSubmitted!() : null,
        textInputAction: textInputAction,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: labelColor,
            fontSize: 14,
          ),
          floatingLabelStyle: TextStyle(
            color: iconColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: iconColor,
            size: 22,
          ),
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
