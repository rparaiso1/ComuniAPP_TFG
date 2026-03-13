import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/budget_controller.dart';
import '../../domain/entities/budget_entity.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  int? _touchedPieIndex;
  String? _selectedEntryType; // null = all, 'income', 'expense'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetControllerProvider.notifier).loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isLeader = authState.user?.role.isAdminOrPresident ?? false;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.colors.backgroundGradient),
        child: SafeArea(
          child: ContentConstraint(
            child: RefreshIndicator(
            onRefresh: () =>
                ref.read(budgetControllerProvider.notifier).loadAll(year: budgetState.selectedYear),
            child: CustomScrollView(
              slivers: [
                // ── Header ────────────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 140,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: context.colors.onGradient),
                      tooltip: context.l.goBack,
                      onPressed: () => context.canPop() ? context.pop() : context.goNamed('home'),
                    ),
                  ),
                  actions: [
                    if (budgetState.summary != null &&
                        budgetState.summary!.availableYears.isNotEmpty)
                      _YearSelector(
                        years: budgetState.summary!.availableYears,
                        selected: budgetState.selectedYear ??
                            budgetState.summary!.year,
                        onChanged: budgetState.isLoadingSummary
                            ? (_) {}
                            : (y) => ref
                                .read(budgetControllerProvider.notifier)
                                .selectYear(y),
                      ),
                    if (isLeader) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: _UploadButton(isUploading: budgetState.isUploading),
                      ),
                    ],
                  ],
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(
                          context.l.budgetTitle,
                          style: TextStyle(
                            color: context.colors.onGradient,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Error ──────────────────────────────────────────────────────
                if (budgetState.error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                budgetState.error!,
                                style: const TextStyle(
                                    color: AppColors.error, fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 16, color: AppColors.error),
                              tooltip: context.l.dismissError,
                              onPressed: () => ref
                                  .read(budgetControllerProvider.notifier)
                                  .clearError(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Loading ────────────────────────────────────────────────────
                if (budgetState.isLoadingSummary)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )

                else if (budgetState.summary == null)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        context.l.budgetNoData,
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ),
                  )

                else
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── KPI Cards ────────────────────────────────────────
                        _KpiRow(summary: budgetState.summary!),
                        const SizedBox(height: 24),

                        // ── Pie Chart ─────────────────────────────────────────
                        if (budgetState.summary!.byCategoryExpense.isNotEmpty) ...[
                          _SectionTitle(context.l.budgetPieTitle),
                          const SizedBox(height: 12),
                          _ExpensePieChart(
                            categories: budgetState.summary!.byCategoryExpense,
                            touchedIndex: _touchedPieIndex,
                            onTouch: (i) => setState(() => _touchedPieIndex = i),
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          _SectionTitle(context.l.budgetPieTitle),
                          const SizedBox(height: 12),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(context.l.budgetNoPieData,
                                  style: TextStyle(
                                      color: context.colors.textSecondary)),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // ── Bar Chart ─────────────────────────────────────────
                        _SectionTitle(context.l.budgetBarTitle),
                        const SizedBox(height: 12),
                        _MonthlyBarChart(
                          monthly: budgetState.summary!.monthlyBreakdown,
                        ),
                        const SizedBox(height: 24),

                        // ── Entries List ────────────────────────────────────
                        _SectionTitle(context.l.budgetAllEntries),
                        const SizedBox(height: 8),
                        // Entry type filter chips
                        Row(
                          children: [
                            _EntryTypeChip(
                              label: context.l.budgetFilterAll,
                              selected: _selectedEntryType == null,
                              onTap: () {
                                setState(() => _selectedEntryType = null);
                                ref.read(budgetControllerProvider.notifier).loadEntries(
                                  year: budgetState.selectedYear,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _EntryTypeChip(
                              label: context.l.budgetFilterIncome,
                              selected: _selectedEntryType == 'income',
                              color: AppColors.success,
                              onTap: () {
                                setState(() => _selectedEntryType = 'income');
                                ref.read(budgetControllerProvider.notifier).loadEntries(
                                  year: budgetState.selectedYear,
                                  entryType: 'income',
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _EntryTypeChip(
                              label: context.l.budgetFilterExpense,
                              selected: _selectedEntryType == 'expense',
                              color: AppColors.error,
                              onTap: () {
                                setState(() => _selectedEntryType = 'expense');
                                ref.read(budgetControllerProvider.notifier).loadEntries(
                                  year: budgetState.selectedYear,
                                  entryType: 'expense',
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (budgetState.isLoadingEntries)
                          const Center(child: CircularProgressIndicator())
                        else
                          _EntriesList(
                            entries: budgetState.entries,
                            isLeader: isLeader,
                          ),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

// ── KPI Row ──────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final BudgetSummaryEntity summary;
  const _KpiRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
    final isPositive = summary.balance >= 0;

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: context.l.budgetTotalIncome,
            value: fmt.format(summary.totalIncome),
            icon: Icons.trending_up,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: context.l.budgetTotalExpense,
            value: fmt.format(summary.totalExpense),
            icon: Icons.trending_down,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: context.l.budgetBalance,
            value: fmt.format(summary.balance),
            icon: isPositive ? Icons.account_balance_wallet : Icons.warning_amber,
            color: isPositive ? AppColors.success : AppColors.error,
            highlighted: true,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlighted;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? color.withValues(alpha: 0.12)
            : context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: context.colors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pie Chart ─────────────────────────────────────────────────────────────────

const _kPieColors = [
  Color(0xFF2563EB), Color(0xFFDC2626), Color(0xFF059669), Color(0xFFF59E0B),
  Color(0xFF7C3AED), Color(0xFF0EA5E9), Color(0xFFEC4899), Color(0xFF14B8A6),
  Color(0xFFF97316), Color(0xFF6366F1),
];

class _ExpensePieChart extends StatelessWidget {
  final List<BudgetCategoryStats> categories;
  final int? touchedIndex;
  final ValueChanged<int?> onTouch;

  const _ExpensePieChart({
    required this.categories,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 0);
    final sections = categories.asMap().entries.map((e) {
      final i = e.key;
      final cat = e.value;
      final isTouched = touchedIndex == i;
      final radius = isTouched ? 90.0 : 75.0;
      final color = _kPieColors[i % _kPieColors.length];
      return PieChartSectionData(
        value: cat.total,
        color: color,
        radius: radius,
        title: isTouched ? '${cat.percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8),
                  ],
                ),
                child: Text(
                  '${cat.category}\n${fmt.format(cat.total)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 0.95,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  if (event is FlTapUpEvent || event is FlLongPressEnd) {
                    onTouch(null);
                    return;
                  }
                  if (pieTouchResponse?.touchedSection != null) {
                    onTouch(pieTouchResponse!.touchedSection!.touchedSectionIndex);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: categories.asMap().entries.map((e) {
            final color = _kPieColors[e.key % _kPieColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(
                  e.value.category,
                  style: TextStyle(
                    fontSize: 12, color: context.colors.textSecondary),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Bar Chart ─────────────────────────────────────────────────────────────────

class _MonthlyBarChart extends StatefulWidget {
  final List<MonthlyStats> monthly;
  const _MonthlyBarChart({required this.monthly});

  @override
  State<_MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<_MonthlyBarChart> {
  int? _touchedGroupIndex;

  @override
  Widget build(BuildContext context) {
    final hasData = widget.monthly.any((m) => m.income > 0 || m.expense > 0);
    if (!hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.l.budgetNoData,
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ),
      );
    }

    final maxVal = widget.monthly.fold(
      0.0,
      (prev, m) => [prev, m.income, m.expense].reduce((a, b) => a > b ? a : b),
    );
    final fmt = NumberFormat.compact(locale: 'es_ES');

    final groups = widget.monthly.asMap().entries.map((e) {
      final i = e.key;
      final m = e.value;
      final isTouched = _touchedGroupIndex == i;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: m.income,
            color: AppColors.success,
            width: isTouched ? 10 : 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: m.expense,
            color: AppColors.error,
            width: isTouched ? 10 : 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0, 1] : [],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.softShadow,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: groups,
                maxY: maxVal * 1.2,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.colors.textSecondary.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (val, meta) => Text(
                        fmt.format(val),
                        style: TextStyle(
                          fontSize: 10,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final m = widget.monthly[val.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            m.monthLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => context.colors.card,
                    tooltipBorder: BorderSide(
                      color: context.colors.textSecondary.withValues(alpha: 0.2),
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0
                          ? context.l.budgetIncome
                          : context.l.budgetExpense;
                      final fmtCur = NumberFormat.currency(
                          locale: 'es_ES', symbol: '€', decimalDigits: 0);
                      return BarTooltipItem(
                        '$label\n${fmtCur.format(rod.toY)}',
                        TextStyle(
                          color: rod.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent || event is FlLongPressEnd) {
                      setState(() => _touchedGroupIndex = null);
                      return;
                    }
                    if (response?.spot != null) {
                      setState(
                          () => _touchedGroupIndex = response!.spot!.touchedBarGroupIndex);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.success, label: context.l.budgetIncome),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.error, label: context.l.budgetExpense),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
      ],
    );
  }
}

// ── Entries List ──────────────────────────────────────────────────────────────

class _EntriesList extends ConsumerWidget {
  final List<BudgetEntryEntity> entries;
  final bool isLeader;
  const _EntriesList({required this.entries, required this.isLeader});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.l.budgetNoData,
              style: TextStyle(color: context.colors.textSecondary)),
        ),
      );
    }

    final fmt = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.softShadow,
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          final isLast = idx == entries.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (entry.isExpense ? AppColors.error : AppColors.success)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    entry.isExpense
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: entry.isExpense ? AppColors.error : AppColors.success,
                    size: 20,
                  ),
                ),
                title: Text(
                  entry.concept,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.category} · ${dateFmt.format(entry.entryDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    if (entry.detail != null && entry.detail!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          entry.detail!,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt.format(entry.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: entry.isExpense ? AppColors.error : AppColors.success,
                      ),
                    ),
                    if (isLeader) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.error),
                        onPressed: () => _confirmDelete(context, ref, entry),
                        tooltip: context.l.budgetDeleteEntry,
                      ),
                    ],
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, color: context.colors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, BudgetEntryEntity entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l.budgetDeleteEntry),
        content: Text('${context.l.budgetDeleteConfirm}\n\n"${entry.concept}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l.delete),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(budgetControllerProvider.notifier).deleteEntry(entry.id);
    }
  }
}

// ── Upload Button ─────────────────────────────────────────────────────────────

class _UploadButton extends ConsumerWidget {
  final bool isUploading;
  const _UploadButton({required this.isUploading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.mediumShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUploading ? null : () => _pickAndUpload(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: isUploading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, valueColor: AlwaysStoppedAnimation(context.colors.onGradient)),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_file, color: context.colors.onGradient, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        context.l.budgetUploadCsv,
                        style: TextStyle(
                            color: context.colors.onGradient,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    final uploadResult = await ref
        .read(budgetControllerProvider.notifier)
        .uploadCsv(file.bytes!.toList(), file.name);

    if (!context.mounted) return;

    if (uploadResult != null) {
      final imported = uploadResult['imported'] as int? ?? 0;
      final totalRows = uploadResult['total_rows'] as int? ?? 0;
      final errors = (uploadResult['errors'] as List<dynamic>?)?.length ?? 0;

      if (errors > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.budgetUploadErrors(imported, totalRows, errors)),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.budgetUploadSuccess(imported)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

// ── Year Selector ─────────────────────────────────────────────────────────────

class _YearSelector extends StatelessWidget {
  final List<int> years;
  final int selected;
  final ValueChanged<int> onChanged;

  const _YearSelector({
    required this.years,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the dropdown value matches an available year
    final effectiveSelected = years.contains(selected) ? selected : years.last;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(10),
        boxShadow: context.colors.softShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: effectiveSelected,
          isDense: true,
          items: years
              .map((y) => DropdownMenuItem(
                    value: y,
                    child: Text(y.toString(),
                        style: TextStyle(
                            color: context.colors.textPrimary, fontSize: 14)),
                  ))
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: context.colors.textPrimary,
      ),
    );
  }
}

// ── Entry Type Filter Chip ────────────────────────────────────────────────────

class _EntryTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _EntryTypeChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? chipColor.withValues(alpha: 0.15) : context.colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? chipColor : context.colors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? chipColor : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
