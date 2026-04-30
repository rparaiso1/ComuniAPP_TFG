import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<BudgetSummaryEntity> getSummary({int? year});
  Future<List<BudgetEntryEntity>> getEntries({
    int? year,
    String? entryType,
    String? category,
    int skip = 0,
    int limit = 50,
  });
  Future<Map<String, dynamic>> uploadCsv(List<int> fileBytes, String fileName);
  Future<void> deleteEntry(String entryId);
}
