import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  /// Devuelve las notificaciones y el contador de no leídas.
  Future<({List<NotificationModel> notifications, int unreadCount})>
      getNotifications({int skip = 0, int limit = 20});
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> clearAll();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final http.Client client;
  final String Function() getToken;
  final String? Function()? getOrgId;

  NotificationRemoteDataSourceImpl({
    required this.client,
    required this.getToken,
    this.getOrgId,
  });

  String get _baseUrl => EnvConfig.apiBaseUrl;

  Map<String, String> get _headers {
    final token = getToken();
    final orgId = getOrgId?.call();
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (orgId != null && orgId.isNotEmpty) 'X-Organization-ID': orgId,
    };
  }

  @override
  Future<({List<NotificationModel> notifications, int unreadCount})>
      getNotifications({int skip = 0, int limit = 20}) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/notifications?skip=$skip&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final list = data['notifications'] ?? data['items'] ?? [];
        final items = (list as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        final unread = (data['unread_count'] ?? 0) as int;
        return (notifications: items, unreadCount: unread);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Tu sesión ha expirado. Inicia sesión de nuevo.');
      } else {
        throw ServerException(
            message:
                'No se pudieron cargar las notificaciones. Inténtalo de nuevo.');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      if (e.toString().contains('Connection') ||
          e.toString().contains('SocketException')) {
        throw NetworkException(
            message:
                'Sin conexión. Verifica tu internet e inténtalo de nuevo.');
      }
      throw NetworkException(
          message: 'Error al cargar notificaciones. Inténtalo de nuevo.');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/notifications/$notificationId/read'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Error al marcar notificación como leída');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/notifications/read-all'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(
            message: 'Error al marcar todas como leídas');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl/api/notifications/$notificationId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Error al eliminar notificación');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl/api/notifications'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Error al eliminar notificaciones');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Error de red: ${e.toString()}');
    }
  }
}
