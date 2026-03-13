import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/env_config.dart';
import 'app_logger.dart';

/// Service for managing FCM push notification device token registration.
///
/// This service handles registering and unregistering the device's FCM token
/// with the backend API so push notifications can be delivered.
///
/// ## Firebase Setup Required
///
/// Before push notifications work, you need to:
/// 1. Create a Firebase project at https://console.firebase.google.com
/// 2. Run `flutterfire configure` to generate `firebase_options.dart`
/// 3. Add `firebase_core` and `firebase_messaging` to pubspec.yaml
/// 4. Initialize Firebase in `main.dart` before runApp
/// 5. Set `FIREBASE_CREDENTIALS_PATH` in backend `.env`
///
/// Until then, this service handles token management via the backend API
/// and can be integrated with any push provider.
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  PushNotificationService._internal();

  String? _currentToken;
  String? _authToken;

  /// Initialize the push notification service.
  ///
  /// Call this after user login, passing the auth token.
  Future<void> init({required String authToken}) async {
    _authToken = authToken;
    AppLogger.info('Push notification service initialized', tag: 'Push');
  }

  /// Register a device token with the backend.
  ///
  /// [token] is the FCM token obtained from `FirebaseMessaging.instance.getToken()`.
  /// [platform] should be 'web', 'android', or 'ios'.
  Future<bool> registerToken(String token, {String? platform}) async {
    _currentToken = token;
    final detectPlatform =
        platform ?? (kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase());

    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/auth/device-token'),
        headers: _headers,
        body: jsonEncode({
          'token': token,
          'platform': detectPlatform,
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.info(
          'Device token registered ($detectPlatform)',
          tag: 'Push',
        );
        return true;
      } else {
        AppLogger.warning(
          'Failed to register device token: ${response.statusCode}',
          tag: 'Push',
        );
        return false;
      }
    } catch (e) {
      AppLogger.warning('Error registering device token: $e', tag: 'Push');
      return false;
    }
  }

  /// Unregister the current device token (e.g., on logout).
  Future<bool> unregisterToken() async {
    if (_currentToken == null) return true;

    try {
      final response = await http.delete(
        Uri.parse('${EnvConfig.apiBaseUrl}/auth/device-token'),
        headers: _headers,
        body: jsonEncode({'token': _currentToken}),
      );

      if (response.statusCode == 200) {
        AppLogger.info('Device token unregistered', tag: 'Push');
        _currentToken = null;
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.warning('Error unregistering device token: $e', tag: 'Push');
      return false;
    }
  }

  /// Clean up on logout.
  Future<void> dispose() async {
    await unregisterToken();
    _authToken = null;
    _currentToken = null;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
}
