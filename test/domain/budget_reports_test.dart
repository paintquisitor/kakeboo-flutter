import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/domain/budget_reports.dart';
import 'package:kakebo/domain/expense_catalog.dart';
import 'package:kakebo/domain/expense_category.dart';
import 'package:kakebo/domain/models.dart';

import 'fixtures.dart';

void main() {
  final clock = TestDateSource('2026-09-30');
  final reports = BudgetReports(clock);
  test(
    'Monthly categories equal variable spending and exclude linked bills',
    () {
      final result = reports.monthlyReport(plan(savings: 50000), [
        expense(10000, subcategory: ExpenseSubcategory.books),
        expense(2000, subcategory: null),
        expense(110000, bill: 2),
        expense(9999, month: '2026-10'),
        Entry(amountGrosz: 8888, type: EntryType.income, dateEpochDay: 20724),
      ]);
      expect(result.balance.fixedExpenses, 110000);
      expect(result.balance.spent, 12000);
      expect(result.categoryTotals, {
        ExpenseCategory.hobby.key: 10000,
        null: 2000,
      });
      expect(result.totalExpenses, 122000);
      expect(result.leftFromIncome, 178000);
      expect(result.balance.remaining, 128000);
    },
  );
  test(
    'Savings goal compares actual remainder, not remainder minus goal again',
    () {
      for (final (spent, outcome) in [
        (149999, SavingsResult.reached),
        (150000, SavingsResult.reached),
        (150001, SavingsResult.partial),
        (199999, SavingsResult.partial),
        (200000, SavingsResult.notReached),
        (210000, SavingsResult.notReached),
      ]) {
        final result = reports.monthlyReport(plan(savings: 50000), [
          expense(spent),
        ]);
        expect(result.savingsResult, outcome);
        expect(result.leftFromIncome, 200000 - spent);
      }
      expect(
        reports.monthlyReport(MonthlyPlanWithItems.empty(ym('2026-09')), [
          expense(1000),
        ]).savingsResult,
        SavingsResult.noIncome,
      );
      expect(
        reports.monthlyReport(plan(savings: 0), []).savingsResult,
        SavingsResult.noGoal,
      );
      expect(
        reports.budgetBalance(MonthlyPlanWithItems.empty(ym('2026-09')), [
          expense(1000),
        ]).remaining,
        -1000,
      );
    },
  );
  test('Daily summaries follow selected day, custom IDs and uncategorized card spending', () {
    final catalog = ExpenseCatalog([
      CustomCategoryWithSubcategories(
        const CustomCategory(
          id: 41,
          name: 'Test',
          nameKey: 'test',
          icon: 'BANK',
        ),
        [
          const CustomSubcategory(
            id: 42,
            categoryId: 41,
            name: 'Podkategoria',
            nameKey: 'podkategoria',
          ),
        ],
      ),
    ]);
    final reports = BudgetReports(clock, catalog: catalog);
    final entries = [
      expense(1000),
      expense(2000, subcategory: null, customId: 42),
      expense(3000, subcategory: null),
      expense(9999, day: 2),
      Entry(
        amountGrosz: 50000,
        type: EntryType.income,
        dateEpochDay: ym('2026-09').firstDay.epochDay,
      ),
    ];
    final day1 = reports.dayReport(CalendarDate(2026, 9, 1), entries);
    expect(day1.spent, 6000);
    expect(day1.categoryTotals, {
      ExpenseCategory.needs.key: 1000,
      const CategoryKey.custom(41): 2000,
      null: 3000,
    });
    expect(reports.dayReport(CalendarDate(2026, 9, 2), entries).spent, 9999);
    expect(
      reports.dayReport(CalendarDate(2026, 9, 3), entries).categoryTotals,
      isEmpty,
    );
    expect(catalog.custom.single.category.icon, 'BANK');
  });
  test('Weeks are 1–7 through end of month, including February and year boundaries', () {
    final reports = BudgetReports(TestDateSource('2029-01-01'));
    for (final month in [
      '2026-08',
      '2026-09',
      '2027-02',
      '2028-02',
      '2026-12',
      '2027-01',
      '2026-03',
    ]) {
      final weeks = reports.weeklyReports(plan(month: month), []);
      final days = [
        for (final week in weeks)
          for (var d = week.start.epochDay; d <= week.end.epochDay; d++) d,
      ];
      expect(days, [
        for (
          var d = ym(month).firstDay.epochDay;
          d <= ym(month).lastDay.epochDay;
          d++
        )
          d,
      ]);
      expect(
        weeks.map((w) => w.start.day).toList(),
        ym(month).lengthOfMonth == 28 ? [1, 8, 15, 22] : [1, 8, 15, 22, 29],
      );
      expect(weeks.take(4).every((w) => !w.partial), true);
    }
    expect(
      reports
          .weeklyReports(plan(month: '2026-08'), [])
          .map((w) => (w.start.day, w.end.day)),
      [(1, 7), (8, 14), (15, 21), (22, 28), (29, 31)],
    );
    expect(
      reports.weeklyReports(plan(month: '2028-02'), []).last.partial,
      true,
    );
  });
  test(
    'Week balances carry forward and overpayment affects only its interval',
    () {
      final entries = [
        expense(40000, day: 1, bill: 2),
        expense(5000, day: 3),
        expense(70000, day: 8, bill: 2),
      ];
      final weeks = reports.weeklyReports(plan(), entries);
      expect(weeks[0].spent, 45000);
      expect(weeks[0].openingBalance, 180000);
      expect(weeks[0].closingBalance, 175000);
      expect(weeks[1].openingBalance, 175000);
      expect(weeks[1].closingBalance, 165000);
      expect(weeks[0].categoryTotals, {ExpenseCategory.needs.key: 45000});
      for (var i = 1; i < weeks.length; i++) {
        expect(weeks[i].openingBalance, weeks[i - 1].closingBalance);
      }
      expect(
        weeks.last.closingBalance,
        reports.budgetBalance(plan(), entries).remaining,
      );
    },
  );
  test('Weeks ignore income and adjacent months; all category amounts equal entries', () {
    final entries = [
      expense(1000, subcategory: null),
      expense(2000, month: '2026-08', day: 31),
      expense(3000, month: '2026-10'),
      Entry(
        amountGrosz: 100000,
        type: EntryType.income,
        dateEpochDay: ym('2026-09').firstDay.epochDay,
      ),
    ];
    final weeks = reports.weeklyReports(plan(), entries);
    expect(weeks.fold(0, (sum, w) => sum + w.spent), 1000);
    expect(weeks.first.categoryTotals, {null: 1000});
    expect(weeks.last.closingBalance, 179000);
  });
  test('Annual totals, categories and extremes match Kotlin fixtures', () {
    final result = reports.yearlyReport(
      2026,
      [
        plan(month: '2026-01', income: 300000, fixed: 100000, savings: 50000),
        plan(month: '2026-02', income: 200000, fixed: 50000, savings: 20000),
      ],
      [
        expense(20000, month: '2026-01', day: 10),
        expense(
          40000,
          month: '2026-02',
          day: 10,
          subcategory: ExpenseSubcategory.dining,
        ),
      ],
    );
    expect(result.months.length, 12);
    expect(result.income, 500000);
    expect(result.fixedExpenseTotal, 150000);
    expect(result.diaryExpenses, 60000);
    expect(result.totalExpenses, 210000);
    expect(result.savings, 290000);
    expect(result.savingsGoal, 70000);
    expect(result.savingsResult, SavingsResult.reached);
    expect(result.categoryTotals, {
      ExpenseCategory.needs.key: 20000,
      ExpenseCategory.optional.key: 40000,
    });
    expect(result.mostExpensiveMonth!.month, ym('2026-01'));
    expect(result.leastExpensiveMonth!.month, ym('2026-02'));
    expect(result.fixedExpenses.single.title, 'Czynsz');
    expect(result.fixedExpenses.single.total, 150000);
    expect(result.fixedExpenses.single.occurrences, 2);
  });
  test('Every future balance is zero even with saved plans and transactions; inputs survive', () {
    final future = plan(month: '2026-10');
    final entries = [expense(1000, month: '2026-10')];
    final plans = [plan(), future];
    final year = reports.yearlyReport(2026, plans, entries);
    expect(year.income, 300000);
    expect(year.fixedExpenseTotal, 100000);
    expect(year.months[9].report.balance.remaining, 0);
    expect(year.months[9].report.totalExpenses, 0);
    expect(year.months[9].report.balance.savings, 0);
    expect(year.months[9].report.categoryTotals, isEmpty);
    expect(year.months[9].report.savingsResult, SavingsResult.noIncome);
    expect(reports.budgetBalance(future, entries).income, 0);
    expect(reports.monthlyReport(future, entries).leftFromIncome, 0);
    expect(
      reports
          .weeklyReports(future, entries)
          .every(
            (w) =>
                w.spent == 0 &&
                w.openingBalance == 0 &&
                w.closingBalance == 0 &&
                w.categoryTotals.isEmpty,
          ),
      true,
    );
    expect(reports.yearlyReport(2027, [plan(month: '2027-01')], []).savings, 0);
    expect(plans.length, 2);
    expect(future.items.length, 2);
    expect(entries.single.amountGrosz, 1000);
    // A fresh snapshot after month start can include existing records; old one is stable.
    final octoberReports = BudgetReports(TestDateSource('2026-10-01'));
    expect(
      octoberReports.monthlyReport(future, entries).balance.remaining,
      179000,
    );
    expect(year.months[9].report.balance.remaining, 0);
  });
  test('Annual bill totals include actual overpayment consistently with monthly totals', () {
    final year = reports.yearlyReport(
      2026,
      [plan()],
      [expense(110000, bill: 2)],
    );
    expect(year.fixedExpenseTotal, 110000);
    expect(year.fixedExpenses.single.total, 110000);
    expect(year.diaryExpenses, 0);
  });
}
