import '../../domain/entities/budget_entity.dart';

/// Safely parse a value that may be num or String (Pydantic serialises Decimal as String).
double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class BudgetCategoryStatsModel {
  final String category;
  final double total;
  final int count;
  final double percentage;

  const BudgetCategoryStatsModel({
    required this.category,
    required this.total,
    required this.count,
    required this.percentage,
  });

  factory BudgetCategoryStatsModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryStatsModel(
      category: json['category'] as String,
      total: _toDouble(json['total']),
      count: _toInt(json['count']),
      percentage: _toDouble(json['percentage']),
    );
  }

  BudgetCategoryStats toEntity() => BudgetCategoryStats(
        category: category,
        total: total,
        count: count,
        percentage: percentage,
      );
}

class MonthlyStatsModel {
  final int month;
  final String monthLabel;
  final double income;
  final double expense;
  final double balance;

  const MonthlyStatsModel({
    required this.month,
    required this.monthLabel,
    required this.income,
    required this.expense,
    required this.balance,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsModel(
      month: _toInt(json['month']),
      monthLabel: json['month_label'] as String,
      income: _toDouble(json['income']),
      expense: _toDouble(json['expense']),
      balance: _toDouble(json['balance']),
    );
  }

  MonthlyStats toEntity() => MonthlyStats(
        month: month,
        monthLabel: monthLabel,
        income: income,
        expense: expense,
        balance: balance,
      );
}

class BudgetSummaryModel {
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int entriesCount;
  final List<BudgetCategoryStatsModel> byCategoryExpense;
  final List<BudgetCategoryStatsModel> byCategoryIncome;
  final List<MonthlyStatsModel> monthlyBreakdown;
  final List<int> availableYears;

  const BudgetSummaryModel({
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.entriesCount,
    required this.byCategoryExpense,
    required this.byCategoryIncome,
    required this.monthlyBreakdown,
    required this.availableYears,
  });

  factory BudgetSummaryModel.fromJson(Map<String, dynamic> json) {
    return BudgetSummaryModel(
      year: _toInt(json['year']),
      totalIncome: _toDouble(json['total_income']),
      totalExpense: _toDouble(json['total_expense']),
      balance: _toDouble(json['balance']),
      entriesCount: _toInt(json['entries_count']),
      byCategoryExpense: (json['by_category_expense'] as List<dynamic>)
          .map((e) => BudgetCategoryStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      byCategoryIncome: (json['by_category_income'] as List<dynamic>)
          .map((e) => BudgetCategoryStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyBreakdown: (json['monthly_breakdown'] as List<dynamic>)
          .map((e) => MonthlyStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableYears: (json['available_years'] as List<dynamic>)
          .map((e) => _toInt(e))
          .toList(),
    );
  }

  BudgetSummaryEntity toEntity() => BudgetSummaryEntity(
        year: year,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: balance,
        entriesCount: entriesCount,
        byCategoryExpense: byCategoryExpense.map((e) => e.toEntity()).toList(),
        byCategoryIncome: byCategoryIncome.map((e) => e.toEntity()).toList(),
        monthlyBreakdown: monthlyBreakdown.map((e) => e.toEntity()).toList(),
        availableYears: availableYears,
      );
}

class BudgetEntryModel {
  final String id;
  final String organizationId;
  final String entryDate;
  final String category;
  final String concept;
  final double amount;
  final String entryType;
  final String? provider;
  final String? detail;
  final String? uploadedByName;
  final String createdAt;

  const BudgetEntryModel({
    required this.id,
    required this.organizationId,
    required this.entryDate,
    required this.category,
    required this.concept,
    required this.amount,
    required this.entryType,
    this.provider,
    this.detail,
    this.uploadedByName,
    required this.createdAt,
  });

  factory BudgetEntryModel.fromJson(Map<String, dynamic> json) {
    return BudgetEntryModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      entryDate: json['entry_date'] as String,
      category: json['category'] as String,
      concept: json['concept'] as String,
      amount: _toDouble(json['amount']),
      entryType: json['entry_type'] as String,
      provider: json['provider'] as String?,
      detail: json['detail'] as String?,
      uploadedByName: json['uploaded_by_name'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  BudgetEntryEntity toEntity() => BudgetEntryEntity(
        id: id,
        organizationId: organizationId,
        entryDate: DateTime.parse(entryDate),
        category: category,
        concept: concept,
        amount: amount,
        entryType: entryType,
        provider: provider,
        detail: detail,
        uploadedByName: uploadedByName,
        createdAt: DateTime.parse(createdAt),
      );
}
