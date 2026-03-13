import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  String? get accessToken;
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateProfile({String? fullName, String? phone, String? dwelling});
  Future<void> requestProfileChange({required String field, required String currentValue, required String requestedValue, String? title, String? description});
  Future<void> changePassword({required String currentPassword, required String newPassword});
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  void setAccessToken(String? token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  String? _accessToken;
  String? _refreshToken;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  String? get accessToken => _accessToken;

  String? get refreshTokenValue => _refreshToken;

  @override
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void setRefreshToken(String? token) {
    _refreshToken = token;
  }

  String get _baseUrl => EnvConfig.apiBaseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw AppAuthException(
            message: 'Connection timeout. Please check your internet connection.',
            code: 'TIMEOUT_ERROR',
          );
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];

        // Get user profile after login
        final user = await getCurrentUser();
        if (user == null) {
          throw AppAuthException(
            message: 'Failed to retrieve user profile',
            code: 'PROFILE_ERROR',
          );
        }
        return user;
      } else if (response.statusCode == 401) {
        throw AppAuthException(
          message: 'Email or password incorrect',
          code: 'INVALID_CREDENTIALS',
        );
      } else if (response.statusCode == 503) {
        throw AppAuthException(
          message: 'Service temporarily unavailable. Please try again.',
          code: 'SERVICE_UNAVAILABLE',
        );
      } else {
        final error = jsonDecode(response.body);
        throw AppAuthException(
          message: error['detail'] ?? 'An error occurred during login',
          code: 'LOGIN_ERROR',
        );
      }
    } on AppAuthException {
      rethrow;
    } on http.ClientException {
      throw AppAuthException(
        message: 'Network error. Please check your connection.',
        code: 'NETWORK_ERROR',
      );
    } on FormatException {
      throw AppAuthException(
        message: 'Invalid server response',
        code: 'FORMAT_ERROR',
      );
    } catch (e) {
      throw AppAuthException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      if (_accessToken != null) {
        await client.post(
          Uri.parse('$_baseUrl/api/auth/logout'),
          headers: _headers,
        );
      }
    } finally {
      _accessToken = null;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      if (_accessToken == null) return null;

      final response = await client.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        throw NotFoundException(message: 'User profile not found');
      }
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw NotFoundException(message: 'User profile not found');
    }
  }

  @override
  Future<UserModel> updateProfile({String? fullName, String? phone, String? dwelling}) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (phone != null) body['phone'] = phone;
      if (dwelling != null) body['dwelling'] = dwelling;

      final response = await client.put(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw AppAuthException(
          message: error['detail'] ?? 'Error al actualizar perfil',
          code: 'UPDATE_ERROR',
        );
      }
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException(
        message: 'Error al actualizar perfil: ${e.toString()}',
        code: 'UPDATE_ERROR',
      );
    }
  }

  @override
  Future<void> requestProfileChange({required String field, required String currentValue, required String requestedValue, String? title, String? description}) async {
    // Enviar solicitud de cambio al admin (crea una notificación/incidencia interna)
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/incidents/'),
        headers: _headers,
        body: jsonEncode({
          'title': title ?? 'Solicitud de cambio de datos: $field',
          'description': description ?? 'El usuario solicita cambiar "$field" de "$currentValue" a "$requestedValue".',
          'priority': 'low',
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppAuthException(
          message: 'Error al enviar solicitud de cambio',
          code: 'REQUEST_ERROR',
        );
      }
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException(
        message: 'Error al enviar solicitud: ${e.toString()}',
        code: 'REQUEST_ERROR',
      );
    }
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/auth/change-password'),
        headers: _headers,
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw AppAuthException(
          message: error['detail'] ?? 'Invalid password',
          code: 'VALIDATION_ERROR',
        );
      } else if (response.statusCode == 401) {
        throw AppAuthException(
          message: 'Current password is incorrect',
          code: 'INVALID_CREDENTIALS',
        );
      } else {
        final error = jsonDecode(response.body);
        throw AppAuthException(
          message: error['detail'] ?? 'Error changing password',
          code: 'CHANGE_PASSWORD_ERROR',
        );
      }
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException(
        message: 'Error changing password: ${e.toString()}',
        code: 'CHANGE_PASSWORD_ERROR',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        return data;
      } else {
        throw AppAuthException(
          message: 'Session expired, please login again',
          code: 'REFRESH_FAILED',
        );
      }
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException(
        message: 'Error refreshing session: ${e.toString()}',
        code: 'REFRESH_ERROR',
      );
    }
  }
}
