import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_datasource.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BudgetSummaryEntity> getSummary({int? year}) async {
    final model = await remoteDataSource.getSummary(year: year);
    return model.toEntity();
  }

  @override
  Future<List<BudgetEntryEntity>> getEntries({
    int? year,
    String? entryType,
    String? category,
    int skip = 0,
    int limit = 50,
  }) async {
    final models = await remoteDataSource.getEntries(
      year: year,
      entryType: entryType,
      category: category,
      skip: skip,
      limit: limit,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> uploadCsv(List<int> fileBytes, String fileName) async {
    return remoteDataSource.uploadCsv(fileBytes, fileName);
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    await remoteDataSource.deleteEntry(entryId);
  }
}
