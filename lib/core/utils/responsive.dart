import 'package:flutter/material.dart';

/// Breakpoints for responsive design (Material 3 recommendations)
class Breakpoints {
  Breakpoints._();

  /// Compact: phones in portrait
  static const double compact = 600;

  /// Medium: tablets, foldables
  static const double medium = 840;

  /// Expanded: tablets landscape, small desktops
  static const double expanded = 1200;

  /// Large: desktops, wide screens
  static const double large = 1600;
}

/// Responsive layout helper — access via `context.responsive`
class Responsive {
  final BuildContext context;

  const Responsive(this.context);

  double get width => MediaQuery.sizeOf(context).width;
  double get height => MediaQuery.sizeOf(context).height;

  // ── Breakpoint queries ──

  bool get isMobile => width < Breakpoints.compact;
  bool get isTablet =>
      width >= Breakpoints.compact && width < Breakpoints.expanded;
  bool get isDesktop => width >= Breakpoints.expanded;
  bool get isLargeDesktop => width >= Breakpoints.large;

  /// True when NavigationRail should replace BottomNavigationBar
  bool get useNavRail => width >= Breakpoints.medium;

  /// True when NavigationRail labels should always be visible
  bool get showNavLabels => width >= Breakpoints.expanded;

  // ── Adaptive values ──

  /// Returns value based on screen size
  T value<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  /// Grid cross-axis count — adapts to available width
  int get gridColumns => value(mobile: 2, tablet: 3, desktop: 4);

  /// List grid columns (for list pages that can become grids on wide screens)
  int get listColumns => value(mobile: 1, tablet: 1, desktop: 2);

  /// Content max width (centered on large screens)
  double get contentMaxWidth =>
      value<double>(mobile: double.infinity, tablet: 720, desktop: 960);

  /// Max width for form content (login, new booking, etc.)
  double get formMaxWidth =>
      value<double>(mobile: double.infinity, tablet: 480, desktop: 480);

  /// Horizontal padding that scales with viewport
  double get horizontalPadding =>
      value<double>(mobile: 16, tablet: 24, desktop: 32);

  /// Vertical spacing between sections
  double get sectionSpacing =>
      value<double>(mobile: 16, tablet: 20, desktop: 24);

  /// Card border radius
  double get cardRadius => value<double>(mobile: 16, tablet: 18, desktop: 20);
}

/// Extension for easy access
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
}

/// Widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    if (r.isDesktop && desktop != null) return desktop!(context);
    if (r.isTablet && tablet != null) return tablet!(context);
    return mobile(context);
  }
}

/// Constrained content wrapper for web/desktop.
/// Automatically centers and constrains content for large screens.
class ContentConstraint extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ContentConstraint({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final mw = maxWidth ?? r.contentMaxWidth;

    Widget result = child;

    if (padding != null) {
      result = Padding(padding: padding!, child: result);
    }

    if (mw == double.infinity) return result;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: mw),
        child: result,
      ),
    );
  }
}

/// Wrapper that constrains forms to a max width and centers them
class FormConstraint extends StatelessWidget {
  final Widget child;

  const FormConstraint({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final mw = r.formMaxWidth;
    if (mw == double.infinity) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: mw),
        child: child,
      ),
    );
  }
}
