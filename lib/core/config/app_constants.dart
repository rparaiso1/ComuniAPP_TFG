class AppConstants {
  // API
  static const Duration apiTimeout = Duration(seconds: 30);

  // App
  static const String appName = 'ComuniApp';
  static const String appVersion = '0.1.0';

  // Roles
  static const String roleAdmin = 'admin';
  static const String rolePresident = 'president';
  static const String roleNeighbor = 'neighbor';

  // Incident Status
  static const String statusOpen = 'open';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';

  // Duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);
}
