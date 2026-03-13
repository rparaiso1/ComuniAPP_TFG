import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/l10n_extension.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
      ),
    );
  }

  /// Mapea errores técnicos a mensajes amigables
  static String getFriendlyMessage(BuildContext context, String technicalError) {
    final l = context.l;
    final errorLower = technicalError.toLowerCase();
    
    // Errores de red/conexión
    if (errorLower.contains('network') || 
        errorLower.contains('connection') ||
        errorLower.contains('timeout') ||
        errorLower.contains('socketexception') ||
        errorLower.contains('handshakeexception') ||
        errorLower.contains('clientexception') ||
        errorLower.contains('no internet') ||
        errorLower.contains('unreachable')) {
      return l.errorConnection;
    }
    
    // Errores de autenticación
    if (errorLower.contains('401') || 
        errorLower.contains('unauthorized') ||
        errorLower.contains('invalid credentials') ||
        errorLower.contains('incorrect') ||
        errorLower.contains('wrong password')) {
      return l.errorInvalidCredentials;
    }

    // Sesión expirada
    if (errorLower.contains('token') && (errorLower.contains('expired') || errorLower.contains('invalid'))) {
      return l.errorSessionExpired;
    }
    
    // Permisos
    if (errorLower.contains('403') || errorLower.contains('forbidden') || errorLower.contains('permiso')) {
      return l.errorForbidden;
    }
    
    // No encontrado
    if (errorLower.contains('404') || errorLower.contains('not found') || errorLower.contains('no encontrad')) {
      return l.errorNotFound;
    }

    // Conflicto / duplicado
    if (errorLower.contains('409') || errorLower.contains('conflict') || errorLower.contains('already exists') || errorLower.contains('duplicate') || errorLower.contains('ya existe')) {
      return l.errorDuplicate;
    }

    // Solapamiento de reservas
    if (errorLower.contains('solapamiento') || errorLower.contains('overlap') || errorLower.contains('ya existe una reserva')) {
      return l.errorBookingConflict;
    }

    // Validación
    if (errorLower.contains('422') || errorLower.contains('validation') || errorLower.contains('invalid') || errorLower.contains('inválid')) {
      return l.errorValidation;
    }
    
    // Errores de servidor
    if (errorLower.contains('500') || errorLower.contains('502') || errorLower.contains('503') || errorLower.contains('server error') || errorLower.contains('internal')) {
      return l.errorServer;
    }

    // Errores de formato/parsing
    if (errorLower.contains('formatexception') || errorLower.contains('type') && errorLower.contains('not a subtype')) {
      return l.errorUnexpectedResponse;
    }
    
    // Error genérico pero amigable
    return l.errorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.card,
              context.colors.errorBg,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de error
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.errorBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: context.colors.error,
              ),
            ),
            const SizedBox(height: 24),
            
            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Mensaje
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón cerrar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l.confirm,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                if (onRetry != null) ...[
                  const SizedBox(width: 12),
                  // Botón reintentar
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRetry!();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        context.l.retry,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar errores inline en la UI
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.error.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: context.colors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textSecondary,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      context.l.retry,
                      style: TextStyle(
                        color: context.colors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close),
              iconSize: 20,
              color: context.colors.textSecondary,
              onPressed: onDismiss,
              tooltip: context.l.dismissError,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
