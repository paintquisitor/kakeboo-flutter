import '../core/time/calendar_date.dart';
import 'expense_catalog.dart';
import 'expense_category.dart';
import 'expense_reconciliation.dart';
import 'models.dart';

int _sum(Iterable<int> amounts) => amounts.fold(0, (a, b) => a + b);

final class PlanTotals {
  const PlanTotals(this.income, this.fixedExpenses, this.savings);
  final int income;
  final int fixedExpenses;
  final int savings;
  int get available => income - fixedExpenses - savings;
}

PlanTotals planTotals(MonthlyPlanWithItems plan) => PlanTotals(
  _sum(
    plan.items
        .where((i) => i.type == EntryType.income && i.isDueIn())
        .map((i) => i.amountGrosz),
  ),
  _sum(
    plan.items
        .where((i) => i.type == EntryType.expense && i.isDueIn())
        .map((i) => i.amountGrosz),
  ),
  plan.plan.savingsGrosz,
);

final class BudgetBalance {
  const BudgetBalance({
    this.income = 0,
    this.savings = 0,
    this.spent = 0,
    this.fixedExpenses = 0,
  });
  final int income;
  final int savings;
  final int spent;
  final int fixedExpenses;
  int get remaining => income - savings - fixedExpenses - spent;
}

enum SavingsResult { noIncome, noGoal, reached, partial, notReached }

SavingsResult _savingsResult(bool hasIncome, int goal, int remaining) {
  if (!hasIncome) return SavingsResult.noIncome;
  if (goal == 0) return SavingsResult.noGoal;
  if (remaining >= goal) return SavingsResult.reached;
  return remaining > 0 ? SavingsResult.partial : SavingsResult.notReached;
}

final class MonthlyReport {
  MonthlyReport(
    this.balance,
    Map<CategoryKey?, int> categoryTotals,
    this.hasIncome,
    Iterable<FixedExpenseReview> reviews,
  ) : categoryTotals = Map.unmodifiable(categoryTotals),
      reviews = List.unmodifiable(reviews);
  final BudgetBalance balance;
  final Map<CategoryKey?, int> categoryTotals;
  final bool hasIncome;
  final List<FixedExpenseReview> reviews;
  int get totalExpenses => balance.fixedExpenses + balance.spent;
  int get leftFromIncome => balance.income - totalExpenses;
  SavingsResult get savingsResult =>
      _savingsResult(hasIncome, balance.savings, leftFromIncome);
}

final class DayReport {
  DayReport(this.date, Iterable<Entry> entries, ExpenseCatalog catalog)
    : entries = List.unmodifiable(entries),
      categoryTotals = catalog.totals(entries);
  final CalendarDate date;
  final List<Entry> entries;
  final Map<CategoryKey?, int> categoryTotals;
  int get spent => _sum(entries.map((e) => e.amountGrosz));
}

final class WeekReport {
  WeekReport({
    required this.start,
    required this.end,
    required Iterable<Entry> entries,
    required this.openingBalance,
    required this.closingBalance,
    required ExpenseCatalog catalog,
  }) : entries = List.unmodifiable(entries),
       categoryTotals = catalog.totals(entries);
  final CalendarDate start;
  final CalendarDate end;
  final List<Entry> entries;
  final Map<CategoryKey?, int> categoryTotals;
  final int openingBalance;
  final int closingBalance;
  int get spent => _sum(entries.map((e) => e.amountGrosz));
  bool get partial => end.epochDay - start.epochDay + 1 < 7;
}

final class YearMonthBalance {
  const YearMonthBalance(this.month, this.report);
  final YearMonth month;
  final MonthlyReport report;
}

final class AnnualFixedExpense {
  const AnnualFixedExpense(this.title, this.total, this.occurrences);
  final String title;
  final int total;
  final int occurrences;
}

final class YearlyReport {
  YearlyReport(
    this.year,
    Iterable<YearMonthBalance> months,
    Iterable<AnnualFixedExpense> fixedExpenses,
  ) : months = List.unmodifiable(months),
      fixedExpenses = List.unmodifiable(fixedExpenses);
  final int year;
  final List<YearMonthBalance> months;
  final List<AnnualFixedExpense> fixedExpenses;
  int get income => _sum(months.map((m) => m.report.balance.income));
  int get diaryExpenses => _sum(months.map((m) => m.report.balance.spent));
  int get fixedExpenseTotal =>
      _sum(months.map((m) => m.report.balance.fixedExpenses));
  int get totalExpenses => fixedExpenseTotal + diaryExpenses;
  int get savingsGoal => _sum(months.map((m) => m.report.balance.savings));
  int get savings => income - totalExpenses;
  SavingsResult get savingsResult =>
      _savingsResult(income > 0, savingsGoal, savings);
  Map<CategoryKey?, int> get categoryTotals {
    final totals = <CategoryKey?, int>{};
    for (final month in months) {
      for (final entry in month.report.categoryTotals.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
      }
    }
    return Map.unmodifiable(totals);
  }

  List<YearMonthBalance> get monthsWithExpenses =>
      months.where((m) => m.report.totalExpenses > 0).toList();
  YearMonthBalance? get mostExpensiveMonth => _extreme(true);
  YearMonthBalance? get leastExpensiveMonth => _extreme(false);
  YearMonthBalance? _extreme(bool highest) {
    YearMonthBalance? best;
    for (final month in monthsWithExpenses) {
      if (best == null ||
          (highest
              ? month.report.totalExpenses > best.report.totalExpenses
              : month.report.totalExpenses < best.report.totalExpenses)) {
        best = month;
      }
    }
    return best;
  }
}

/// A report is an immutable snapshot at the injected current civil date.
/// Reports perform no writes and never delete stored future data.
final class BudgetReports {
  BudgetReports(this.dates, {ExpenseCatalog? catalog})
    : catalog = catalog ?? ExpenseCatalog();
  final DateSource dates;
  final ExpenseCatalog catalog;

  BudgetBalance budgetBalance(
    MonthlyPlanWithItems plan,
    Iterable<Entry> entries,
  ) {
    if (plan.plan.month.compareTo(dates.today().yearMonth) > 0) {
      return const BudgetBalance();
    }
    return _balance(plan, reconcileExpenses(plan, entries));
  }

  MonthlyReport monthlyReport(
    MonthlyPlanWithItems plan,
    Iterable<Entry> entries,
  ) => _monthly(plan, entries, dates.today().yearMonth);

  MonthlyReport _monthly(
    MonthlyPlanWithItems plan,
    Iterable<Entry> entries,
    YearMonth now,
  ) {
    if (plan.plan.month.compareTo(now) > 0) {
      return MonthlyReport(const BudgetBalance(), const {}, false, const []);
    }
    final reconciled = reconcileExpenses(plan, entries);
    return MonthlyReport(
      _balance(plan, reconciled),
      catalog.totals(reconciled.variable),
      plan.items.any((i) => i.type == EntryType.income && i.isDueIn()),
      reconciled.reviews,
    );
  }

  DayReport dayReport(CalendarDate date, Iterable<Entry> entries) => DayReport(
    date,
    entries.where(
      (e) => e.type == EntryType.expense && e.dateEpochDay == date.epochDay,
    ),
    catalog,
  );

  List<WeekReport> weeklyReports(
    MonthlyPlanWithItems plan,
    Iterable<Entry> entries,
  ) {
    final month = plan.plan.month;
    final future = month.compareTo(dates.today().yearMonth) > 0;
    final reconciled = reconcileExpenses(plan, future ? const [] : entries);
    final weeks = <WeekReport>[];
    for (var startDay = 1; startDay <= month.lengthOfMonth; startDay += 7) {
      final start = month.atDay(startDay);
      final end = month.atDay(
        startDay + 6 > month.lengthOfMonth ? month.lengthOfMonth : startDay + 6,
      );
      weeks.add(
        WeekReport(
          start: start,
          end: end,
          entries: reconciled.all.where(
            (e) =>
                e.dateEpochDay >= start.epochDay &&
                e.dateEpochDay <= end.epochDay,
          ),
          openingBalance: future
              ? 0
              : _balance(
                  plan,
                  reconciled,
                  throughDay: start.epochDay - 1,
                ).remaining,
          closingBalance: future
              ? 0
              : _balance(plan, reconciled, throughDay: end.epochDay).remaining,
          catalog: catalog,
        ),
      );
    }
    return List.unmodifiable(weeks);
  }

  YearlyReport yearlyReport(
    int year,
    Iterable<MonthlyPlanWithItems> plans,
    Iterable<Entry> entries,
  ) {
    final now = dates.today().yearMonth;
    final byMonth = {for (final plan in plans) plan.plan.month: plan};
    final months = <YearMonthBalance>[];
    final fixedTotals = <String, int>{};
    final occurrences = <String, int>{};
    for (var number = 1; number <= 12; number++) {
      final month = YearMonth(year, number);
      final plan = byMonth[month] ?? MonthlyPlanWithItems.empty(month);
      months.add(YearMonthBalance(month, _monthly(plan, entries, now)));
      if (month.compareTo(now) > 0) continue;
      final actual = reconcileExpenses(plan, entries).fixedActualById;
      for (final item in plan.items.where(
        (i) => i.type == EntryType.expense && i.isDueIn(),
      )) {
        final title = item.title.trim();
        fixedTotals[title] =
            (fixedTotals[title] ?? 0) + _fixedAmount(item, actual);
        occurrences[title] = (occurrences[title] ?? 0) + 1;
      }
    }
    final fixed =
        fixedTotals.entries
            .map((e) => AnnualFixedExpense(e.key, e.value, occurrences[e.key]!))
            .toList()
          ..sort((a, b) => b.total.compareTo(a.total));
    return YearlyReport(year, months, fixed);
  }
}

int _fixedAmount(PlannedItem item, Map<int, int> actual) {
  final paid = actual[item.id] ?? 0;
  return paid > item.amountGrosz ? paid : item.amountGrosz;
}

BudgetBalance _balance(
  MonthlyPlanWithItems plan,
  ReconciledExpenses reconciled, {
  int? throughDay,
}) {
  final included = reconciled.all.where(
    (e) => throughDay == null || e.dateEpochDay <= throughDay,
  );
  final actual = <int, int>{};
  var spent = 0;
  for (final e in included) {
    final fixedId = reconciled.assignments[e];
    if (fixedId == null) {
      spent += e.amountGrosz;
    } else {
      actual[fixedId] = (actual[fixedId] ?? 0) + e.amountGrosz;
    }
  }
  return BudgetBalance(
    income: planTotals(plan).income,
    savings: plan.plan.savingsGrosz,
    spent: spent,
    fixedExpenses: _sum(
      plan.items
          .where((i) => i.type == EntryType.expense && i.isDueIn())
          .map((i) => _fixedAmount(i, actual)),
    ),
  );
}
