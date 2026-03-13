import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../utils/l10n_extension.dart';
import '../utils/responsive.dart';
import '../../features/admin/presentation/pages/admin_export_page.dart';
import '../../features/admin/presentation/pages/admin_import_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_zones_page.dart';
import '../../features/admin/presentation/pages/invitations_management_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_with_invitation_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/board/presentation/pages/board_page.dart';
import '../../features/board/presentation/pages/post_detail_page.dart';
import '../../features/bookings/presentation/pages/bookings_list_page.dart';
import '../../features/bookings/presentation/pages/new_booking_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/documents/presentation/pages/documents_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/incidents/presentation/pages/incidents_list_page.dart';
import '../../features/incidents/presentation/pages/incident_detail_page.dart';
import '../../features/incidents/presentation/pages/new_incident_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/budget/presentation/pages/budget_page.dart';
import 'route_names.dart';

// --- Transition helpers (Material 3 motion) ---

/// Fade through — for top-level destination switches (tabs)
CustomTransitionPage<T> _fadeTransition<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
        child: child,
      );
    },
  );
}

/// Shared axis Z — for forward/backward navigation (details, sub-pages)
CustomTransitionPage<T> _sharedAxisZ<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      );
      final scaleIn = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      // Outgoing page fades and scales down
      final fadeOut = CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInCubic),
      );
      final scaleOut = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(
            parent: secondaryAnimation, curve: Curves.easeInCubic),
      );
      return ScaleTransition(
        scale: scaleOut,
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
          child: ScaleTransition(
            scale: scaleIn,
            child: FadeTransition(
              opacity: fadeIn,
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

/// Slide up + fade — for modals, bottom sheets, creation forms
CustomTransitionPage<T> _slideUpTransition<T>(
    Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      );
      return SlideTransition(
        position: animation.drive(slide),
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}

// GoRouter exposed as a Riverpod provider (injectable, testable)
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: false,
  redirect: (context, state) {
    final box = Hive.box('user_box');
    final isLoggedIn = box.get('session_token') != null;
    final isSplash = state.matchedLocation == '/splash';
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation.startsWith('/register');

    // Splash siempre se ejecuta — valida el token y navega
    if (isSplash) return null;

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/home';

    // Role guard for admin routes
    const adminRoutes = ['/invitations', '/admin/import', '/admin/export', '/admin/users', '/admin/zones'];
    final isAdminRoute = adminRoutes.any((r) => state.matchedLocation.startsWith(r));
    if (isLoggedIn && isAdminRoute) {
      final userData = box.get('current_user');
      if (userData != null) {
        final role = (userData as Map)['role']?.toString().toLowerCase() ?? '';
        if (role != 'admin' && role != 'president') {
          return '/home';
        }
      }
    }

    return null;
  },
  routes: [
    // Auth routes
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register-sms',
      name: 'registerSms',
      pageBuilder: (context, state) => _fadeTransition(
        const RegisterWithInvitationPage(), state,
      ),
    ),
    GoRoute(
      path: '/invitations',
      name: 'invitations',
      pageBuilder: (context, state) => _sharedAxisZ(
        const InvitationsManagementPage(), state,
      ),
    ),
    GoRoute(
      path: '/admin/import',
      name: 'adminImport',
      pageBuilder: (context, state) => _sharedAxisZ(
        const AdminImportPage(), state,
      ),
    ),
    GoRoute(
      path: '/admin/export',
      name: 'adminExport',
      pageBuilder: (context, state) => _sharedAxisZ(
        const AdminExportPage(), state,
      ),
    ),
    GoRoute(
      path: '/admin/users',
      name: 'adminUsers',
      pageBuilder: (context, state) => _sharedAxisZ(
        const AdminUsersPage(), state,
      ),
    ),
    GoRoute(
      path: '/admin/zones',
      name: 'adminZones',
      pageBuilder: (context, state) => _sharedAxisZ(
        const AdminZonesPage(), state,
      ),
    ),

    // Shell route with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        return _ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: RouteNames.home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: RouteNames.board,
          name: 'board',
          builder: (context, state) => const BoardPage(),
        ),
        GoRoute(
          path: RouteNames.bookings,
          name: 'bookings',
          builder: (context, state) => const BookingsListPage(),
        ),
        GoRoute(
          path: RouteNames.incidents,
          name: 'incidents',
          builder: (context, state) => const IncidentsListPage(),
        ),
        GoRoute(
          path: RouteNames.documents,
          name: 'documents',
          builder: (context, state) => const DocumentsPage(),
        ),
        GoRoute(
          path: RouteNames.budget,
          name: 'budget',
          builder: (context, state) => const BudgetPage(),
        ),
      ],
    ),

    // Calendar (standalone)
    GoRoute(
      path: RouteNames.calendar,
      name: 'calendar',
      pageBuilder: (context, state) => _fadeTransition(
        const CalendarPage(), state,
      ),
    ),

    // Board detail
    GoRoute(
      path: '${RouteNames.board}/detail/:postId',
      name: 'boardDetail',
      pageBuilder: (context, state) {
        final postId = state.pathParameters['postId'] ?? '';
        return _sharedAxisZ(
          PostDetailPage(postId: postId), state,
        );
      },
    ),

    // New booking
    GoRoute(
      path: RouteNames.newBooking,
      name: 'newBooking',
      pageBuilder: (context, state) => _slideUpTransition(
        const NewBookingPage(), state,
      ),
    ),

    // Incidents detail
    GoRoute(
      path: '${RouteNames.incidents}/detail/:incidentId',
      name: 'incidentDetail',
      pageBuilder: (context, state) {
        final incidentId = state.pathParameters['incidentId'] ?? '';
        return _sharedAxisZ(
          IncidentDetailPage(incidentId: incidentId), state,
        );
      },
    ),

    // New incident
    GoRoute(
      path: RouteNames.newIncident,
      name: 'newIncident',
      pageBuilder: (context, state) => _slideUpTransition(
        const NewIncidentPage(), state,
      ),
    ),

    // Notifications
    GoRoute(
      path: RouteNames.notifications,
      name: 'notifications',
      pageBuilder: (context, state) => _sharedAxisZ(
        const NotificationsPage(), state,
      ),
    ),

    // Profile
    GoRoute(
      path: RouteNames.profile,
      name: 'profile',
      pageBuilder: (context, state) => _sharedAxisZ(
        const ProfilePage(), state,
      ),
    ),
  ],
);
});

/// Adaptive scaffold — NavigationBar on mobile, NavigationRail on tablet/desktop
class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const _ScaffoldWithNavBar({required this.child});

  static int _indexFromLocation(String location) {
    if (location.startsWith('/board')) return 1;
    if (location.startsWith('/bookings')) return 2;
    if (location.startsWith('/incidents')) return 3;
    if (location.startsWith('/documents')) return 4;
    if (location.startsWith('/budget')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexFromLocation(location);
    final r = context.responsive;

    // Destination data — (outline icon, filled icon, label)
    final items = [
      (Icons.home_outlined, Icons.home_rounded, context.l.navHome),
      (Icons.dashboard_outlined, Icons.dashboard_rounded, context.l.navBoard),
      (Icons.calendar_month_outlined, Icons.calendar_month_rounded, context.l.navBookings),
      (Icons.warning_amber_outlined, Icons.warning_amber_rounded, context.l.navIncidents),
      (Icons.description_outlined, Icons.description_rounded, context.l.navDocs),
      (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, context.l.navBudget),
    ];

    void onTap(int index) {
      const names = ['home', 'board', 'bookings', 'incidents', 'documents', 'budget'];
      context.goNamed(names[index]);
    }

    // Fade-through animated body for tab transitions
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: ValueKey(location),
        child: child,
      ),
    );

    // ── Tablet / Desktop — NavigationRail ──
    if (r.useNavRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onTap,
              labelType: r.showNavLabels
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              useIndicator: true,
              minWidth: 72,
              groupAlignment: -0.85,
              leading: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: Icon(
                  Icons.apartment_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              destinations: [
                for (final (icon, selectedIcon, label) in items)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selectedIcon),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // ── Mobile — Material 3 NavigationBar ──
    return Scaffold(
      body: body,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
              TextStyle(
                fontSize: 11,
                overflow: TextOverflow.ellipsis,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onTap,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final (icon, selectedIcon, label) in items)
              NavigationDestination(
                icon: Icon(icon),
                selectedIcon: Icon(selectedIcon),
                label: label,
              ),
          ],
        ),
      ),
    );
  }
}
