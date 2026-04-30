import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../services/local_storage_service.dart';
import '../services/notifications_service.dart';
import '../services/org_selector_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';

// HTTP Client
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});

// Shared Auth Remote Data Source (singleton para compartir el token)
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSourceImpl>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authDataSource = AuthRemoteDataSourceImpl(client: httpClient);
  
  // Restaurar token si existe en local storage
  final savedToken = LocalStorageService().getUserData('session_token');
  if (savedToken != null) {
    authDataSource.setAccessToken(savedToken);
  }
  
  // Restaurar refresh token si existe
  final savedRefreshToken = LocalStorageService().getUserData('refresh_token');
  if (savedRefreshToken != null) {
    authDataSource.setRefreshToken(savedRefreshToken);
  }
  
  return authDataSource;
});

/// Provides auth headers including X-Organization-ID when an org is selected.
/// Use this in pages that do direct HTTP calls (non-Clean-Architecture).
final authHeadersProvider = Provider<Map<String, String>>((ref) {
  final authDataSource = ref.watch(authRemoteDataSourceProvider);
  final orgId = ref.watch(activeOrgIdProvider);
  final token = authDataSource.accessToken ?? '';
  return {
    'Content-Type': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    if (orgId != null && orgId.isNotEmpty) 'X-Organization-ID': orgId,
  };
});

// Local Storage Service
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Notifications Service
final notificationsProvider = Provider<NotificationsService>((ref) {
  return NotificationsService();
});

// EnvConfig: all members are static, no provider needed.
