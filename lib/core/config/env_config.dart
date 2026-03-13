import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static late String _apiBaseUrl;
  static late String _appEnv;

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');

    _apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    // En Android emulator, localhost apunta al propio emulador.
    // Usamos 10.0.2.2 que redirige al host (tu PC).
    if (!kIsWeb && _isAndroid() && _apiBaseUrl.contains('localhost')) {
      _apiBaseUrl = _apiBaseUrl.replaceFirst('localhost', '10.0.2.2');
    }

    _appEnv = dotenv.env['APP_ENV'] ?? 'development';

    if (_apiBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL not found in .env file');
    }
  }

  // Getters
  static String get apiBaseUrl => _apiBaseUrl;
  static String get appEnv => _appEnv;

  static bool get isDevelopment => _appEnv == 'development';
  static bool get isProduction => _appEnv == 'production';

  /// Detect Android without importing dart:io (incompatible with web).
  static bool _isAndroid() {
    try {
      // ignore: avoid_classes_with_only_static_members
      return defaultTargetPlatform == TargetPlatform.android;
    } catch (_) {
      return false;
    }
  }
}
