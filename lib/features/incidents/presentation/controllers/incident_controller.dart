import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/services/org_selector_service.dart';
import '../../data/datasources/incident_remote_datasource.dart';
import '../../data/repositories/incident_repository_impl.dart';
import '../../domain/entities/incident_entity.dart';
import '../../domain/repositories/incident_repository.dart';
import '../../../../core/utils/paginated_state.dart';

// Repository provider
final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authDataSource = ref.watch(authRemoteDataSourceProvider);
  
  final activeOrgId = ref.watch(activeOrgIdProvider);
  final remoteDataSource = IncidentRemoteDataSourceImpl(
    client: httpClient,
    getToken: () => authDataSource.accessToken ?? '',
    getOrgId: () => activeOrgId,
  );

  return IncidentRepositoryImpl(remoteDataSource: remoteDataSource);
});

// State class
class IncidentState with PaginatedState {
  final List<IncidentEntity> incidents;
  final bool isLoading;
  final String? error;
  final bool isCreating;
  @override
  final bool isLoadingMore;
  @override
  final bool hasMore;
  @override
  final int currentSkip;

  IncidentState({
    this.incidents = const [],
    this.isLoading = false,
    this.error,
    this.isCreating = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentSkip = 0,
  });

  IncidentState copyWith({
    List<IncidentEntity>? incidents,
    bool? isLoading,
    String? error,
    bool? isCreating,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentSkip,
  }) {
    return IncidentState(
      incidents: incidents ?? this.incidents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCreating: isCreating ?? this.isCreating,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
    );
  }
}

// Controller
class IncidentController extends Notifier<IncidentState> {
  late IncidentRepository repository;
  String? _statusFilter;
  String? _priorityFilter;
  bool _myOnly = false;

  @override
  IncidentState build() {
    repository = ref.watch(incidentRepositoryProvider);
    return IncidentState();
  }

  Future<void> loadIncidents({String? statusFilter, String? priorityFilter, bool? myOnly}) async {
    _statusFilter = statusFilter;
    _priorityFilter = priorityFilter;
    _myOnly = myOnly ?? false;
    state = state.copyWith(isLoading: true, error: null, currentSkip: 0, hasMore: true);
    try {
      final incidents = await repository.getIncidents(
        skip: 0, limit: kDefaultPageSize,
        statusFilter: _statusFilter,
        priorityFilter: _priorityFilter,
        myOnly: _myOnly,
      );
      state = state.copyWith(
        incidents: incidents,
        isLoading: false,
        currentSkip: incidents.length,
        hasMore: incidents.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final newIncidents = await repository.getIncidents(
        skip: state.currentSkip,
        limit: kDefaultPageSize,
        statusFilter: _statusFilter,
        priorityFilter: _priorityFilter,
        myOnly: _myOnly,
      );
      state = state.copyWith(
        incidents: [...state.incidents, ...newIncidents],
        isLoadingMore: false,
        currentSkip: state.currentSkip + newIncidents.length,
        hasMore: newIncidents.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createIncident({
    required String title,
    required String description,
    required String priority,
    String? location,
  }) async {
    state = state.copyWith(isCreating: true, error: null);
    try {
      final newIncident = await repository.createIncident(
        title: title,
        description: description,
        priority: priority,
        location: location,
      );
      state = state.copyWith(
        incidents: [newIncident, ...state.incidents],
        isCreating: false,
        currentSkip: state.currentSkip + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateIncidentStatus(String incidentId, String newStatus) async {
    try {
      final updatedIncident = await repository.updateIncidentStatus(
        incidentId: incidentId,
        status: newStatus,
      );
      state = state.copyWith(
        incidents: state.incidents.map((i) {
          return i.id == incidentId ? updatedIncident : i;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteIncident(String incidentId) async {
    try {
      await repository.deleteIncident(incidentId);
      state = state.copyWith(
        incidents: state.incidents.where((i) => i.id != incidentId).toList(),
        currentSkip: state.currentSkip > 0 ? state.currentSkip - 1 : 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Controller provider
final incidentControllerProvider =
    NotifierProvider<IncidentController, IncidentState>(
  () => IncidentController(),
);
