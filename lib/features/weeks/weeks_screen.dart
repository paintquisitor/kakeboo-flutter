import 'package:flutter/material.dart';

import '../../core/time/calendar_date.dart';
import '../../data/kakebo_database.dart';
import '../../domain/budget_reports.dart';
import '../../domain/expense_catalog.dart';
import '../balance/report_scope.dart';
import '../balance/report_widgets.dart';
import '../diary/diary_categories.dart';

class WeeksScreen extends StatefulWidget {
  const WeeksScreen({
    super.key,
    required this.month,
    required this.database,
    required this.currency,
  });
  final YearMonth month;
  final KakeboDatabase database;
  final String currency;

  @override
  State<WeeksScreen> createState() => _WeeksScreenState();
}

class _WeeksScreenState extends State<WeeksScreen> {
  int selectedWeek = 0;

  @override
  void didUpdateWidget(covariant WeeksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) selectedWeek = 0;
  }

  @override
  Widget build(BuildContext context) => ReportScope(
    database: widget.database,
    year: widget.month.year,
    builder: (context, data) {
      final plan = data.plans[widget.month.month - 1];
      final reports = BudgetReports(
        const SystemDateSource(),
        catalog: data.catalog,
      );
      final weeks = reports.weeklyReports(plan, data.entries);
      final week = weeks[selectedWeek.clamp(0, weeks.length - 1)];
      final monthly = reports.monthlyReport(plan, data.entries);
      final available = planTotals(plan).available;
      final remaining = week.closingBalance;
      final fraction = available <= 0
          ? 0.0
          : (remaining / available).clamp(0.0, 1.0);
      final now = const SystemDateSource().today().yearMonth;
      final future = widget.month.compareTo(now) > 0;
      return ListView(
        key: const Key('weeks_report'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            diaryText(context, 'Tydzień po tygodniu', 'Week by week'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < weeks.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      key: Key('week_$i'),
                      selected: i == selectedWeek,
                      onSelected: (_) => setState(() => selectedWeek = i),
                      label: Text('${weeks[i].start.day}–${weeks[i].end.day}'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ReportCard(
            tint: true,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diaryText(
                          context,
                          'Wydatki w tym tygodniu',
                          'This week’s expenses',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reportMoney(context, week.spent, widget.currency),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        diaryText(
                          context,
                          'Pozostało w miesiącu',
                          'Remaining this month',
                        ),
                      ),
                      Text(reportMoney(context, remaining, widget.currency)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: fraction,
                        strokeWidth: 6,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .outlineVariant,
                      ),
                      Text(
                        '${(fraction * 100).round()}%',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diaryText(context, 'Wydatki dzienne', 'Daily expenses'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _DailyBars(week: week, catalog: data.catalog),
              ],
            ),
          ),
          ReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diaryText(context, 'Według kategorii', 'By category'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                CategoryBreakdown(
                  totals: week.categoryTotals,
                  catalog: data.catalog,
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
                  diaryText(context, 'Dzień po dniu', 'Day by day'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (var day = week.start.day; day <= week.end.day; day++)
                  ReportAmount(
                    label: '$day.${widget.month.month}',
                    amount: week.entries
                        .where(
                          (e) =>
                              CalendarDate.fromEpochDay(e.dateEpochDay).day ==
                              day,
                        )
                        .fold(0, (int sum, e) => sum + e.amountGrosz),
                    currency: widget.currency,
                  ),
              ],
            ),
          ),
          if (!future)
            ReportCard(
              child: ReportAmount(
                label: diaryText(
                  context,
                  'Wydatki w miesiącu',
                  'Monthly expenses',
                ),
                amount: monthly.totalExpenses,
                currency: widget.currency,
              ),
            ),
        ],
      );
    },
  );
}

class _DailyBars extends StatelessWidget {
  const _DailyBars({required this.week, required this.catalog});
  final WeekReport week;
  final ExpenseCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final days = [
      for (var day = week.start.day; day <= week.end.day; day++) day,
    ];
    final totals = [
      for (final day in days)
        catalog.totals(
          week.entries.where(
            (e) => CalendarDate.fromEpochDay(e.dateEpochDay).day == day,
          ),
        ),
    ];
    final max = totals
        .map((map) => map.values.fold<int>(0, (a, b) => a + b))
        .fold<int>(1, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 128,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < days.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (final item in totals[i].entries)
                          Container(
                            key: Key(
                              'daily_bar_${days[i]}_${item.key?.hashCode ?? 0}',
                            ),
                            height: 100 * item.value / max,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: categoryColor(context, item.key),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${days[i]}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
