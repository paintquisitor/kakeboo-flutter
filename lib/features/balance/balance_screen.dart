import 'package:flutter/material.dart';

import '../../core/format/kakebo_format.dart';
import '../../core/time/calendar_date.dart';
import '../../data/kakebo_database.dart';
import '../../domain/budget_reports.dart';
import '../../domain/expense_catalog.dart';
import '../../domain/expense_reconciliation.dart';
import '../../domain/models.dart';
import '../diary/diary_categories.dart';
import 'report_scope.dart';
import 'report_widgets.dart';

enum _Detail { fixed, diary }

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({
    super.key,
    required this.month,
    required this.database,
    required this.currency,
    required this.yearMode,
    required this.onYearMode,
    required this.onSelectMonth,
  });
  final YearMonth month;
  final KakeboDatabase database;
  final String currency;
  final bool yearMode;
  final ValueChanged<bool> onYearMode;
  final ValueChanged<YearMonth> onSelectMonth;

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  _Detail? detail;

  @override
  void didUpdateWidget(covariant BalanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month ||
        oldWidget.yearMode != widget.yearMode) {
      detail = null;
    }
  }

  @override
  Widget build(BuildContext context) => ReportScope(
    database: widget.database,
    year: widget.month.year,
    builder: (context, data) {
      final reports = BudgetReports(
        const SystemDateSource(),
        catalog: data.catalog,
      );
      final plan = data.plans[widget.month.month - 1];
      final monthReport = reports.monthlyReport(plan, data.entries);
      final yearReport = reports.yearlyReport(
        widget.month.year,
        data.plans,
        data.entries,
      );
      return ListView(
        key: const Key('balance_report'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(diaryText(context, 'Miesiąc', 'Month')),
              ),
              ButtonSegment(
                value: true,
                label: Text(diaryText(context, 'Rok', 'Year')),
              ),
            ],
            selected: {widget.yearMode},
            onSelectionChanged: (value) => widget.onYearMode(value.first),
          ),
          const SizedBox(height: 14),
          if (widget.yearMode)
            _annual(context, yearReport, data.catalog)
          else if (detail != null)
            _details(context, plan, data.entries, detail!)
          else
            _monthly(context, plan, monthReport, data),
        ],
      );
    },
  );

  Widget _monthly(
    BuildContext context,
    MonthlyPlanWithItems plan,
    MonthlyReport report,
    ReportData data,
  ) {
    final balance = report.balance;
    final weeks = BudgetReports(
      const SystemDateSource(),
      catalog: data.catalog,
    ).weeklyReports(plan, data.entries);
    final future =
        widget.month.compareTo(const SystemDateSource().today().yearMonth) > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportCard(
          tint: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diaryText(context, 'Bilans miesiąca', 'Monthly balance'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                reportMoney(context, report.leftFromIncome, widget.currency),
                key: const Key('monthly_remaining'),
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ReportAmount(
                label: diaryText(context, 'Wpływy', 'Income'),
                amount: balance.income,
                currency: widget.currency,
                color: Theme.of(context).colorScheme.primary,
              ),
              ReportAmount(
                label: diaryText(context, 'Oszczędności', 'Savings goal'),
                amount: balance.savings,
                currency: widget.currency,
              ),
            ],
          ),
        ),
        ReportCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diaryText(context, 'Wydatki', 'Expenses'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              ReportAmount(
                keyName: 'open_fixed_expenses',
                label: diaryText(context, 'Stałe wydatki', 'Fixed expenses'),
                amount: balance.fixedExpenses,
                currency: widget.currency,
                onTap: () => setState(() => detail = _Detail.fixed),
              ),
              const Divider(),
              ReportAmount(
                keyName: 'open_diary_expenses',
                label: diaryText(context, 'Z dziennika', 'From diary'),
                amount: balance.spent,
                currency: widget.currency,
                onTap: () => setState(() => detail = _Detail.diary),
              ),
            ],
          ),
        ),
        ReportCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diaryText(context, 'Tydzień po tygodniu', 'Week by week'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final week in weeks)
                ReportAmount(
                  label: '${week.start.day}–${week.end.day}',
                  amount: week.spent,
                  currency: widget.currency,
                ),
            ],
          ),
        ),
        ReportCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diaryText(
                  context,
                  'Wydatki według kategorii',
                  'Expenses by category',
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              CategoryBreakdown(
                totals: report.categoryTotals,
                catalog: data.catalog,
                currency: widget.currency,
              ),
            ],
          ),
        ),
        if (!future) _reflection(context),
      ],
    );
  }

  Widget _details(
    BuildContext context,
    MonthlyPlanWithItems plan,
    List<Entry> allEntries,
    _Detail kind,
  ) {
    final future =
        widget.month.compareTo(const SystemDateSource().today().yearMonth) > 0;
    final reconciled = reconcileExpenses(plan, future ? const [] : allEntries);
    final fixed = future
        ? <PlannedItem>[]
        : plan.items
              .where((item) => item.type == EntryType.expense && item.isDueIn())
              .toList();
    final variable = reconciled.variable.toList()
      ..sort((a, b) => b.dateEpochDay.compareTo(a.dateEpochDay));
    final title = kind == _Detail.fixed
        ? diaryText(context, 'Stałe wydatki', 'Fixed expenses')
        : diaryText(context, 'Z dziennika', 'From diary');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => detail = null),
          icon: const Icon(Icons.arrow_back, size: 17),
          label: Text(diaryText(context, 'Bilans miesiąca', 'Monthly balance')),
        ),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (kind == _Detail.fixed)
          for (final item in fixed)
            ReportCard(
              child: ReportAmount(
                label: item.title,
                amount:
                    (reconciled.fixedActualById[item.id] ?? 0) >
                        item.amountGrosz
                    ? reconciled.fixedActualById[item.id]!
                    : item.amountGrosz,
                currency: widget.currency,
              ),
            )
        else
          for (final entry in variable)
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.note.isEmpty
                        ? diaryText(context, 'Wydatek', 'Expense')
                        : entry.note,
                  ),
                  ReportAmount(
                    label: CalendarDate.fromEpochDay(entry.dateEpochDay)
                        .toString(),
                    amount: entry.amountGrosz,
                    currency: widget.currency,
                  ),
                ],
              ),
            ),
        if ((kind == _Detail.fixed ? fixed.isEmpty : variable.isEmpty))
          ReportCard(
            child: Text(diaryText(context, 'Brak wydatków', 'No expenses')),
          ),
      ],
    );
  }

  Widget _annual(
    BuildContext context,
    YearlyReport report,
    ExpenseCatalog catalog,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportCard(
          tint: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diaryText(context, 'Bilans roku', 'Annual balance'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                reportMoney(context, report.savings, widget.currency),
                key: const Key('annual_savings'),
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              ReportAmount(
                label: diaryText(context, 'Wpływy', 'Income'),
                amount: report.income,
                currency: widget.currency,
              ),
              ReportAmount(
                label: diaryText(context, 'Wydatki', 'Expenses'),
                amount: report.totalExpenses,
                currency: widget.currency,
              ),
            ],
          ),
        ),
        ReportCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diaryText(context, 'Miesiąc po miesiącu', 'Month by month'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              _AnnualBars(
                report: report,
                currency: widget.currency,
                onMonthSelected: (month) {
                  widget.onSelectMonth(month);
                  widget.onYearMode(false);
                },
              ),
              for (final item in report.months)
                ReportAmount(
                  keyName: 'annual_month_${item.month.month}',
                  label: formatMonth(
                    DateTime(item.month.year, item.month.month),
                    Localizations.localeOf(context),
                  ),
                  amount: item.report.leftFromIncome,
                  currency: widget.currency,
                  onTap: () {
                    widget.onSelectMonth(item.month);
                    widget.onYearMode(false);
                  },
                ),
            ],
          ),
        ),
        ReportCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diaryText(
                  context,
                  'Wydatki według kategorii',
                  'Expenses by category',
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              CategoryBreakdown(
                totals: report.categoryTotals,
                catalog: catalog,
                currency: widget.currency,
              ),
            ],
          ),
        ),
        ReportCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diaryText(context, 'Stałe wydatki', 'Fixed expenses'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final item in report.fixedExpenses)
                ReportAmount(
                  label: item.title,
                  amount: item.total,
                  currency: widget.currency,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reflection(BuildContext context) => StreamBuilder(
    stream: widget.database.watchReflection(widget.month),
    builder: (context, snapshot) {
      final row = snapshot.data;
      return ReportCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    diaryText(
                      context,
                      'Refleksja miesiąca',
                      'Monthly reflection',
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  key: const Key('edit_reflection'),
                  tooltip: diaryText(context, 'Edytuj', 'Edit'),
                  onPressed: () => _editReflection(context, row),
                  icon: const Icon(Icons.edit_outlined, size: 19),
                ),
              ],
            ),
            if (row == null)
              Text(
                diaryText(
                  context,
                  'Co się udało? Co zmienić w przyszłym miesiącu?',
                  'What went well? What would you change next month?',
                ),
              ),
            if (row != null) ...[
              if (row.successes.isNotEmpty) Text(row.successes),
              if (row.improvements.isNotEmpty) Text(row.improvements),
              if (row.nextMonth.isNotEmpty) Text(row.nextMonth),
            ],
          ],
        ),
      );
    },
  );

  Future<void> _editReflection(
    BuildContext context,
    MonthlyReflectionRow? row,
  ) async {
    final result = await showDialog<MonthlyReflection>(
      context: context,
      builder: (context) => _ReflectionDialog(month: widget.month, row: row),
    );
    if (result != null) await widget.database.saveReflection(result);
  }
}

class _AnnualBars extends StatelessWidget {
  const _AnnualBars({
    required this.report,
    required this.currency,
    required this.onMonthSelected,
  });

  final YearlyReport report;
  final String currency;
  final ValueChanged<YearMonth> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final amounts = report.months.map((m) => m.report.leftFromIncome).toList();
    final positive = amounts.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final negative = amounts.fold<int>(
      0,
      (max, value) => -value > max ? -value : max,
    );
    final range = positive + negative == 0 ? 1 : positive + negative;
    const chartHeight = 80.0;
    final baseline = chartHeight * positive / range;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          for (var i = 0; i < report.months.length; i++)
            Expanded(
              child: Semantics(
                label:
                    '${i + 1}: ${reportMoney(context, amounts[i], currency)}',
                button: true,
                child: InkWell(
                  key: Key('annual_bar_${i + 1}'),
                  onTap: () => onMonthSelected(report.months[i].month),
                  child: Column(
                    children: [
                      SizedBox(
                        height: chartHeight,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final value = amounts[i];
                            final barHeight = chartHeight * value.abs() / range;
                            return Stack(
                              children: [
                                Positioned(
                                  top: baseline,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 1,
                                    color: colors.outlineVariant,
                                  ),
                                ),
                                if (value != 0)
                                  Positioned(
                                    top: value > 0
                                        ? baseline - barHeight
                                        : baseline,
                                    left: constraints.maxWidth * .18,
                                    right: constraints.maxWidth * .18,
                                    child: Container(
                                      height: barHeight,
                                      decoration: BoxDecoration(
                                        color: value > 0
                                            ? colors.primary
                                            : colors.error,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${i + 1}'.padLeft(2, '0'),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReflectionDialog extends StatefulWidget {
  const _ReflectionDialog({required this.month, required this.row});
  final YearMonth month;
  final MonthlyReflectionRow? row;

  @override
  State<_ReflectionDialog> createState() => _ReflectionDialogState();
}

class _ReflectionDialogState extends State<_ReflectionDialog> {
  late final successes = TextEditingController(
    text: widget.row?.successes ?? '',
  );
  late final improvements = TextEditingController(
    text: widget.row?.improvements ?? '',
  );
  late final nextMonth = TextEditingController(
    text: widget.row?.nextMonth ?? '',
  );

  @override
  void dispose() {
    successes.dispose();
    improvements.dispose();
    nextMonth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(diaryText(context, 'Refleksja miesiąca', 'Monthly reflection')),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('reflection_successes'),
            controller: successes,
            decoration: InputDecoration(
              labelText: diaryText(context, 'Co się udało?', 'What went well?'),
            ),
          ),
          TextField(
            controller: improvements,
            decoration: InputDecoration(
              labelText: diaryText(
                context,
                'Co można poprawić?',
                'What could improve?',
              ),
            ),
          ),
          TextField(
            controller: nextMonth,
            decoration: InputDecoration(
              labelText: diaryText(
                context,
                'Plan na kolejny miesiąc',
                'Next month’s plan',
              ),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(diaryText(context, 'Anuluj', 'Cancel')),
      ),
      FilledButton(
        key: const Key('save_reflection'),
        onPressed: () => Navigator.pop(
          context,
          MonthlyReflection(
            month: widget.month,
            successes: successes.text.trim(),
            improvements: improvements.text.trim(),
            nextMonth: nextMonth.text.trim(),
          ),
        ),
        child: Text(diaryText(context, 'Zapisz', 'Save')),
      ),
    ],
  );
}
