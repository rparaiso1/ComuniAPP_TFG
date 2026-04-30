import 'package:flutter/material.dart';

class AppColors {
  // Primary - Azul profesional comunitario
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF0EA5E9);
  static const Color accentLight = Color(0xFF38BDF8);

  // Background - Limpio y luminoso
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text - Alta legibilidad
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status - Colores claros
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFF3B82F6);

  // Semantic extended
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFA78BFA);
  static const Color purpleDark = Color(0xFF7B1FA2);
  static const Color pink = Color(0xFFEC4899);
  static const Color teal = Color(0xFF14B8A6);
  static const Color cyan = Color(0xFF0EA5E9);
  static const Color neutral = Color(0xFF6B7280);

  // Chart palette
  static const List<Color> chartColors = [
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF0EA5E9),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];

  // Borders & Dividers
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFF1F5F9);

  // Input
  static const Color inputBackground = Color(0xFFF8FAFC);
  static const Color inputBorder = Color(0xFFCBD5E1);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dark mode gradients
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Card gradients (semantic)
  static const LinearGradient bookingsGradient = LinearGradient(
    colors: [primary, Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incidentsGradient = LinearGradient(
    colors: [error, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient boardGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient documentsGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient invitationsGradient = LinearGradient(
    colors: [warning, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient budgetGradient = LinearGradient(
    colors: [Color(0xFF0369A1), accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sombras
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Extension providing theme-aware colors via BuildContext.
/// Use `context.colors` to get colors that respect light/dark mode.
extension ThemeColorsExtension on BuildContext {
  ThemeColors get colors => ThemeColors(Theme.of(this));
}

class ThemeColors {
  final ThemeData _theme;
  const ThemeColors(this._theme);

  bool get _isDark => _theme.brightness == Brightness.dark;

  // Surfaces
  Color get surface => _theme.colorScheme.surface;
  Color get surfaceVariant => _isDark ? const Color(0xFF1E293B) : AppColors.surfaceVariant;
  Color get background => _theme.scaffoldBackgroundColor;
  Color get card => _isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get cardElevated => _isDark ? const Color(0xFF2D3F55) : Colors.white;
  Color get navBackground => _isDark ? const Color(0xFF0F172A) : Colors.white;
  Color get inputBackground => _isDark ? const Color(0xFF1E293B) : AppColors.inputBackground;
  Color get chipBackground => _isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);
  Color get iconButtonBackground => _isDark ? const Color(0xFF1E293B) : Colors.white;

  // Text
  Color get textPrimary => _isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
  Color get textSecondary => _isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;
  Color get textTertiary => _isDark ? const Color(0xFF94A3B8) : AppColors.textTertiary;
  Color get textOnPrimary => Colors.white;
  Color get textOnCard => _isDark ? const Color(0xFFE2E8F0) : AppColors.textPrimary;

  // Borders
  Color get border => _isDark ? const Color(0xFF334155) : AppColors.borderColor;
  Color get divider => _isDark ? const Color(0xFF2D3F55) : AppColors.dividerColor;
  Color get inputBorder => _isDark ? const Color(0xFF475569) : AppColors.inputBorder;

  // Status (work in both modes)
  Color get success => _isDark ? const Color(0xFF4ADE80) : AppColors.success;
  Color get successBg => _isDark ? const Color(0xFF14532D).withValues(alpha: 0.6) : const Color(0xFFDCFCE7);
  Color get warning => _isDark ? const Color(0xFFFBBF24) : AppColors.warning;
  Color get warningBg => _isDark ? const Color(0xFF78350F).withValues(alpha: 0.6) : const Color(0xFFFEF3C7);
  Color get error => _isDark ? const Color(0xFFF87171) : AppColors.error;
  Color get errorBg => _isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.6) : const Color(0xFFFEE2E2);
  Color get info => _isDark ? const Color(0xFF38BDF8) : AppColors.info;
  Color get infoBg => _isDark ? const Color(0xFF0C4A6E).withValues(alpha: 0.6) : const Color(0xFFE0F2FE);

  // Gradients
  LinearGradient get backgroundGradient =>
      _isDark ? AppColors.darkBackgroundGradient : AppColors.backgroundGradient;

  // Shadows (subtle in dark mode)
  List<BoxShadow> get softShadow => _isDark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
      : AppColors.softShadow;
  List<BoxShadow> get cardShadow => _isDark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))]
      : AppColors.cardShadow;

  // Overlay / on-gradient (for text & icons on gradient backgrounds)
  Color get onGradient => Colors.white;
  Color get onGradientVariant => Colors.white.withValues(alpha: 0.9);
  Color get onGradientSubtle => Colors.white.withValues(alpha: 0.7);
  Color get onGradientMuted => Colors.white.withValues(alpha: 0.3);

  // Purple (semantic)
  Color get purple => _isDark ? AppColors.purpleLight : AppColors.purple;
  Color get purpleBg => _isDark
      ? const Color(0xFF4C1D95).withValues(alpha: 0.6)
      : const Color(0xFFEDE9FE);

  // Teal
  Color get teal => _isDark ? const Color(0xFF5EEAD4) : AppColors.teal;

  // Pink
  Color get pink => _isDark ? const Color(0xFFF9A8D4) : AppColors.pink;

  // Neutral
  Color get neutral => _isDark ? const Color(0xFF9CA3AF) : AppColors.neutral;
  Color get neutralBg => _isDark
      ? const Color(0xFF374151).withValues(alpha: 0.6)
      : const Color(0xFFF3F4F6);

  // Chart colors (theme-aware)
  List<Color> get chartColors => _isDark
      ? const [
          Color(0xFF60A5FA),
          Color(0xFF4ADE80),
          Color(0xFFFBBF24),
          Color(0xFFF87171),
          Color(0xFFA78BFA),
          Color(0xFF38BDF8),
          Color(0xFFF9A8D4),
          Color(0xFF5EEAD4),
        ]
      : AppColors.chartColors;
}
