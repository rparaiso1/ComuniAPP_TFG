import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'package:comuniapp/core/config/app_constants.dart';

/// Centralized logger for the application
/// 
/// Provides consistent logging across the app with different levels:
/// - debug: Development only messages
/// - info: General information
/// - warning: Potential issues
/// - error: Errors and exceptions
class AppLogger {
  static const String _appName = AppConstants.appName;
  
  /// Log debug messages (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      developer.log(
        '$prefix $message',
        name: '$_appName.DEBUG',
        level: 500,
      );
      debugPrint('[DEBUG] $prefix: $message');
    }
  }
  
  /// Log info messages
  static void info(String message, {String? tag}) {
    final prefix = tag != null ? '[$tag]' : '';
    developer.log(
      '$prefix $message',
      name: '$_appName.INFO',
      level: 800,
    );
    if (kDebugMode) {
      debugPrint('[INFO] $prefix: $message');
    }
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag, Object? error}) {
    final prefix = tag != null ? '[$tag]' : '';
    developer.log(
      '$prefix $message',
      name: '$_appName.WARNING',
      level: 900,
      error: error,
    );
    if (kDebugMode) {
      debugPrint('[WARNING] $prefix: $message');
      if (error != null) {
        debugPrint('  Error: $error');
      }
    }
  }
  
  /// Log error messages
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final prefix = tag != null ? '[$tag]' : '';
    developer.log(
      '$prefix $message',
      name: '$_appName.ERROR',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
    if (kDebugMode) {
      debugPrint('[ERROR] $prefix: $message');
      if (error != null) {
        debugPrint('  Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('  StackTrace: $stackTrace');
      }
    }
  }
  
  /// Log network requests
  static void network(String method, String url, {int? statusCode, String? response}) {
    if (kDebugMode) {
      final status = statusCode != null ? '[$statusCode]' : '';
      debugPrint('[NETWORK] $method $url $status');
      if (response != null && response.length <= 500) {
        debugPrint('  Response: $response');
      }
    }
  }
  
  /// Log performance metrics
  static void performance(String operation, Duration duration) {
    if (kDebugMode) {
      debugPrint('[PERF] $operation took ${duration.inMilliseconds}ms');
    }
  }
  
  /// Log user actions
  static void userAction(String action, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      debugPrint('[ACTION] $action');
      if (params != null) {
        debugPrint('  Params: $params');
      }
    }
  }
}
