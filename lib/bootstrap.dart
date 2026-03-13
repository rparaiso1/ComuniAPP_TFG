import 'core/config/env_config.dart';
import 'core/services/app_logger.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notifications_service.dart';

/// Bootstrap the application with all necessary initializations
Future<void> bootstrap() async {
  try {
    AppLogger.info('Starting app bootstrap...');

    // 1. Load environment configuration
    AppLogger.info('Loading environment configuration...');
    await EnvConfig.init();

    // 2. Initialize Local Storage
    AppLogger.info('Initializing Local Storage...');
    await LocalStorageService().init();

    // 3. Check session token
    AppLogger.info('Checking session token...');
    final token = LocalStorageService().getUserData('session_token');
    if (token != null) {
      AppLogger.info('Session token found');
    } else {
      AppLogger.info('No session token found');
    }

    // 4. Initialize Local Notifications (non-critical)
    AppLogger.info('Initializing Local Notifications...');
    try {
      await NotificationsService().init();
    } catch (e, stackTrace) {
      AppLogger.error('Notifications init failed (non-critical)', error: e, stackTrace: stackTrace);
    }

    AppLogger.info('Bootstrap completed successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Bootstrap failed', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
