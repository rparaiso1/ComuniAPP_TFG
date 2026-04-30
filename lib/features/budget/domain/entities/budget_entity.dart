import 'package:flutter/foundation.dart';

@immutable
class BudgetEntryEntity {
  final String id;
  final String organizationId;
  final DateTime entryDate;
  final String category;
  final String concept;
  final double amount;
  final String entryType; // "income" | "expense"
  final String? provider;
  final String? detail;
  final String? uploadedByName;
  final DateTime createdAt;

  const BudgetEntryEntity({
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

  bool get isExpense => entryType == 'expense';
  bool get isIncome => entryType == 'income';
}

@immutable
class BudgetCategoryStats {
  final String category;
  final double total;
  final int count;
  final double percentage;

  const BudgetCategoryStats({
    required this.category,
    required this.total,
    required this.count,
    required this.percentage,
  });
}

@immutable
class MonthlyStats {
  final int month;
  final String monthLabel;
  final double income;
  final double expense;
  final double balance;

  const MonthlyStats({
    required this.month,
    required this.monthLabel,
    required this.income,
    required this.expense,
    required this.balance,
  });
}

@immutable
class BudgetSummaryEntity {
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int entriesCount;
  final List<BudgetCategoryStats> byCategoryExpense;
  final List<BudgetCategoryStats> byCategoryIncome;
  final List<MonthlyStats> monthlyBreakdown;
  final List<int> availableYears;

  const BudgetSummaryEntity({
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
}
