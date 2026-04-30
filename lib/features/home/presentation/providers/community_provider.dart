import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/env_config.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/services/org_selector_service.dart';

/// Modelo de organización del usuario
class CommunityOrg {
  final String id;
  final String name;
  final String code;
  final String role;
  final String? dwelling;
  final bool isActive;

  CommunityOrg({
    required this.id,
    required this.name,
    required this.code,
    required this.role,
    this.dwelling,
    required this.isActive,
  });

  factory CommunityOrg.fromJson(Map<String, dynamic> json) {
    return CommunityOrg(
      id: json['organization_id'] ?? '',
      name: json['organization_name'] ?? '',
      code: json['organization_code'] ?? '',
      role: json['role'] ?? 'NEIGHBOR',
      dwelling: json['dwelling'],
      isActive: json['is_active'] ?? true,
    );
  }
}

/// Estado del selector de comunidad
class CommunityState {
  final List<CommunityOrg> organizations;
  final CommunityOrg? selected;
  final bool isLoading;
  final String? error;

  CommunityState({
    this.organizations = const [],
    this.selected,
    this.isLoading = false,
    this.error,
  });

  CommunityState copyWith({
    List<CommunityOrg>? organizations,
    CommunityOrg? selected,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      organizations: organizations ?? this.organizations,
      selected: selected ?? this.selected,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Controller para la selección de comunidad
class CommunityController extends Notifier<CommunityState> {
  late final http.Client _client;
  late final String Function() _getToken;
  late final OrgSelectorService _orgSelector;

  @override
  CommunityState build() {
    _client = ref.watch(httpClientProvider);
    final authDs = ref.watch(authRemoteDataSourceProvider);
    _getToken = () => authDs.accessToken ?? '';
    _orgSelector = ref.watch(selectedOrgIdProvider.notifier);
    return CommunityState();
  }

  Future<void> loadOrganizations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/organizations/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final orgs = data.map((e) => CommunityOrg.fromJson(e)).toList();

        // Determine initial selection from persisted org or first
        final persistedId = _orgSelector.state;
        CommunityOrg? selected;
        if (persistedId != null) {
          try {
            selected = orgs.firstWhere((o) => o.id == persistedId);
          } catch (_) {
            selected = orgs.isNotEmpty ? orgs.first : null;
          }
        } else {
          selected = orgs.isNotEmpty ? orgs.first : null;
        }

        if (selected != null) {
          _orgSelector.selectOrg(selected.id);
        }

        state = state.copyWith(
          organizations: orgs,
          selected: selected,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'load_organizations_error',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectOrganization(CommunityOrg org) {
    state = state.copyWith(selected: org);
    _orgSelector.selectOrg(org.id);
  }
}

/// Provider global
final communityControllerProvider =
    NotifierProvider<CommunityController, CommunityState>(
  () => CommunityController(),
);
