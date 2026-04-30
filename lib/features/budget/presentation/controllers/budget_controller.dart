import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/org_selector_service.dart';
import '../../data/datasources/budget_remote_datasource.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';

// ── Repository provider ─────────────────────────────────────────────────────

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authDataSource = ref.watch(authRemoteDataSourceProvider);
  final activeOrgId = ref.watch(activeOrgIdProvider);

  return BudgetRepositoryImpl(
    remoteDataSource: BudgetRemoteDataSourceImpl(
      client: httpClient,
      getToken: () => authDataSource.accessToken ?? '',
      getOrgId: () => activeOrgId,
    ),
  );
});

// ── State ───────────────────────────────────────────────────────────────────

class BudgetState {
  final BudgetSummaryEntity? summary;
  final List<BudgetEntryEntity> entries;
  final bool isLoadingSummary;
  final bool isLoadingEntries;
  final bool isUploading;
  final String? error;
  final int? selectedYear;

  const BudgetState({
    this.summary,
    this.entries = const [],
    this.isLoadingSummary = false,
    this.isLoadingEntries = false,
    this.isUploading = false,
    this.error,
    this.selectedYear,
  });

  BudgetState copyWith({
    BudgetSummaryEntity? summary,
    List<BudgetEntryEntity>? entries,
    bool? isLoadingSummary,
    bool? isLoadingEntries,
    bool? isUploading,
    String? error,
    int? selectedYear,
    bool clearError = false,
  }) {
    return BudgetState(
      summary: summary ?? this.summary,
      entries: entries ?? this.entries,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      isLoadingEntries: isLoadingEntries ?? this.isLoadingEntries,
      isUploading: isUploading ?? this.isUploading,
      error: clearError ? null : (error ?? this.error),
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

// ── Controller ──────────────────────────────────────────────────────────────

class BudgetController extends Notifier<BudgetState> {
  late BudgetRepository _repo;

  @override
  BudgetState build() {
    _repo = ref.watch(budgetRepositoryProvider);
    return const BudgetState();
  }

  Future<void> loadSummary({int? year}) async {
    state = state.copyWith(isLoadingSummary: true, clearError: true);
    try {
      final summary = await _repo.getSummary(year: year);
      state = state.copyWith(
        summary: summary,
        isLoadingSummary: false,
        selectedYear: year ?? summary.year,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoadingSummary: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoadingSummary: false, error: e.toString());
    }
  }

  Future<void> loadEntries({int? year, String? entryType, String? category}) async {
    state = state.copyWith(isLoadingEntries: true);
    try {
      final entries = await _repo.getEntries(
        year: year ?? state.selectedYear,
        entryType: entryType,
        category: category,
        skip: 0,
        limit: 100,
      );
      state = state.copyWith(entries: entries, isLoadingEntries: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoadingEntries: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoadingEntries: false, error: e.toString());
    }
  }

  Future<void> loadAll({int? year}) async {
    final y = year ?? state.selectedYear;
    await Future.wait([loadSummary(year: y), loadEntries(year: y)]);
  }

  Future<Map<String, dynamic>?> uploadCsv(List<int> fileBytes, String fileName) async {
    state = state.copyWith(isUploading: true, clearError: true);
    try {
      final result = await _repo.uploadCsv(fileBytes, fileName);
      state = state.copyWith(isUploading: false);
      // Reload data after upload
      await loadAll(year: state.selectedYear);
      return result;
    } on AppException catch (e) {
      state = state.copyWith(isUploading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> deleteEntry(String entryId) async {
    try {
      await _repo.deleteEntry(entryId);
      state = state.copyWith(
        entries: state.entries.where((e) => e.id != entryId).toList(),
      );
      await loadSummary(year: state.selectedYear);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void selectYear(int year) {
    if (year == state.selectedYear) return;
    state = state.copyWith(selectedYear: year);
    loadAll(year: year);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// Provider
final budgetControllerProvider =
    NotifierProvider<BudgetController, BudgetState>(BudgetController.new);
