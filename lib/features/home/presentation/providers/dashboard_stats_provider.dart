import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Modelo de estadísticas del dashboard
class DashboardStats {
  final int bookingsCount;
  final int incidentsCount;
  final int documentsCount;
  final int postsCount;
  final int pendingInvitations;

  DashboardStats({
    required this.bookingsCount,
    required this.incidentsCount,
    required this.documentsCount,
    required this.postsCount,
    required this.pendingInvitations,
  });

  factory DashboardStats.empty() => DashboardStats(
        bookingsCount: 0,
        incidentsCount: 0,
        documentsCount: 0,
        postsCount: 0,
        pendingInvitations: 0,
      );

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      bookingsCount: json['bookings_count'] ?? 0,
      incidentsCount: json['incidents_count'] ?? 0,
      documentsCount: json['documents_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      pendingInvitations: json['pending_invitations'] ?? 0,
    );
  }
}

/// Provider para las estadísticas del dashboard
final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final headers = ref.watch(authHeadersProvider);
  final client = ref.watch(httpClientProvider);
  
  if (!authState.isAuthenticated) {
    return DashboardStats.empty();
  }
  
  try {
    final response = await client.get(
      Uri.parse('${EnvConfig.apiBaseUrl}/api/stats/dashboard'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DashboardStats.fromJson(data);
    }
    
    return DashboardStats.empty();
  } catch (e) {
    return DashboardStats.empty();
  }
});

/// Provider para refrescar estadísticas manualmente
final refreshStatsProvider = Provider<void Function()>((ref) {
  return () => ref.invalidate(dashboardStatsProvider);
});
