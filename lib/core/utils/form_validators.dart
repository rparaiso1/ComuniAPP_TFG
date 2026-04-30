import 'package:flutter/widgets.dart';
import 'l10n_extension.dart';

class FormValidators {
  /// Valida email (con i18n)
  static String? Function(String?) email(BuildContext context) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return context.l.validatorEmailRequired;
      }

      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(value)) {
        return context.l.validatorEmailInvalid;
      }

      return null;
    };
  }

  /// Valida contraseña
  static String? Function(String?) password(BuildContext context, {int minLength = 6}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return context.l.validatorPasswordRequired;
      }

      if (value.length < minLength) {
        return context.l.validatorPasswordMinLength(minLength);
      }

      return null;
    };
  }

  /// Valida contraseña fuerte (para registro)
  static String? Function(String?) strongPassword(BuildContext context) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return context.l.validatorPasswordRequired;
      }

      if (value.length < 8) {
        return context.l.validatorPasswordMinLength(8);
      }

      if (!value.contains(RegExp(r'[A-Z]'))) {
        return context.l.validatorPasswordUppercase;
      }

      if (!value.contains(RegExp(r'[a-z]'))) {
        return context.l.validatorPasswordLowercase;
      }

      if (!value.contains(RegExp(r'[0-9]'))) {
        return context.l.validatorPasswordDigit;
      }

      return null;
    };
  }

  /// Valida que las contraseñas coincidan
  static String? Function(String?) confirmPassword(BuildContext context, String? password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return context.l.validatorConfirmPasswordRequired;
      }

      if (value != password) {
        return context.l.passwordsDoNotMatch;
      }

      return null;
    };
  }

  /// Valida campo requerido
  static String? Function(String?) required(BuildContext context, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return context.l.validatorFieldRequired(fieldName ?? context.l.thisField);
      }
      return null;
    };
  }

  /// Valida longitud mínima
  static String? Function(String?) minLength(BuildContext context, int length, {String? fieldName}) {
    return (String? value) {
      final name = fieldName ?? context.l.thisField;
      if (value == null || value.isEmpty) {
        return context.l.validatorFieldRequired(name);
      }

      if (value.length < length) {
        return context.l.validatorFieldMinLength(name, length);
      }

      return null;
    };
  }

  /// Valida longitud máxima
  static String? Function(String?) maxLength(BuildContext context, int length, {String? fieldName}) {
    return (String? value) {
      if (value != null && value.length > length) {
        return context.l.validatorFieldMaxLength(fieldName ?? context.l.thisField, length);
      }
      return null;
    };
  }

  /// Valida teléfono
  static String? Function(String?) phone(BuildContext context) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return context.l.validatorPhoneRequired;
      }

      // Eliminar espacios y guiones
      final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');

      // Validar formato español (+34 o 34 seguido de 9 dígitos)
      final phoneRegex = RegExp(r'^(\+34|34)?[6-9]\d{8}$');

      if (!phoneRegex.hasMatch(cleanPhone)) {
        return context.l.validatorPhoneInvalid;
      }

      return null;
    };
  }

  /// Valida número
  static String? Function(String?) number(BuildContext context, {String? fieldName}) {
    return (String? value) {
      final name = fieldName ?? context.l.thisField;
      if (value == null || value.isEmpty) {
        return context.l.validatorFieldRequired(name);
      }

      if (int.tryParse(value) == null) {
        return context.l.validatorNumberInvalid(name);
      }

      return null;
    };
  }

  /// Valida rango numérico
  static String? Function(String?) numberRange(BuildContext context, int min, int max, {String? fieldName}) {
    return (String? value) {
      final name = fieldName ?? context.l.thisField;
      if (value == null || value.isEmpty) {
        return context.l.validatorFieldRequired(name);
      }

      final number = int.tryParse(value);
      if (number == null) {
        return context.l.validatorNumberInvalid(name);
      }

      if (number < min || number > max) {
        return context.l.validatorNumberRange(name, min, max);
      }

      return null;
    };
  }

  /// Valida fecha futura
  static String? futureDate(BuildContext context, DateTime? value, {String? fieldName}) {
    final name = fieldName ?? context.l.theDate;
    if (value == null) {
      return context.l.validatorDateRequired(name);
    }

    if (value.isBefore(DateTime.now())) {
      return context.l.validatorDateFuture(name);
    }

    return null;
  }

  /// Valida URL
  static String? Function(String?) url(BuildContext context) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return context.l.validatorUrlRequired;
      }

      final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      );

      if (!urlRegex.hasMatch(value)) {
        return context.l.validatorUrlInvalid;
      }

      return null;
    };
  }

  /// Valida código postal español
  static String? Function(String?) postalCode(BuildContext context) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return context.l.validatorPostalCodeRequired;
      }

      final postalRegex = RegExp(r'^\d{5}$');

      if (!postalRegex.hasMatch(value)) {
        return context.l.validatorPostalCodeInvalid;
      }

      return null;
    };
  }

  /// Combina múltiples validadores
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
