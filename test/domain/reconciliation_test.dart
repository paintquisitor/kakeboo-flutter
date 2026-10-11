import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/domain/budget_reports.dart';
import 'package:kakebo/domain/expense_reconciliation.dart';
import 'package:kakebo/domain/models.dart';

import 'fixtures.dart';

void main() {
  final reports = BudgetReports(TestDateSource('2026-09-30'));
  test(
    'Unsaved templates cannot share a payment through placeholder ID zero',
    () {
      final draft = MonthlyPlanWithItems(plan().plan, [
        plan().items.first,
        item(id: 0),
        item(id: 0, title: 'Prąd', amount: 40000),
      ]);
      final payment = expense(100000, subcategory: null, note: 'CZYNSZ');
      expect(reconcileExpenses(draft, [payment]).assignments, isEmpty);
      expect(reports.budgetBalance(draft, [payment]).remaining, 40000);
      expect(
        () => MonthlyPlanWithItems(plan().plan, [item(id: 2), item(id: 2)]),
        throwsArgumentError,
      );
    },
  );
  test(
    'Explicit links sum installments; only overpayment exceeds fixed reserve',
    () {
      final entries = [expense(40000, bill: 2), expense(5000)];
      expect(reports.budgetBalance(plan(), entries).remaining, 175000);
      entries.add(expense(60000, bill: 2));
      expect(reports.budgetBalance(plan(), entries).remaining, 175000);
      entries.add(expense(10000, bill: 2));
      final balance = reports.budgetBalance(plan(), entries);
      expect(balance.fixedExpenses, 110000);
      expect(balance.spent, 5000);
      expect(balance.remaining, 165000);
    },
  );
  test('Unique normalized title can match a variable bill, even with a different amount', () {
    final p = plan(fixedTitle: 'Prąd', fixed: 40000);
    final payment = expense(
      43500,
      day: 12,
      subcategory: null,
      note: 'OPŁATA ZA PRAD 09/2026',
    );
    final result = reconcileExpenses(p, [payment]);
    expect(result.assignments[payment], 2);
    expect(result.reviews, isEmpty);
    expect(reports.budgetBalance(p, [payment]).remaining, 236500);
    expect(reports.budgetBalance(p, [payment]).spent, 0);
    final rent = expense(100000, subcategory: null, note: 'PRZELEW CZYNSZ');
    expect(reports.monthlyReport(plan(), [rent]).categoryTotals, isEmpty);
    expect(reports.budgetBalance(plan(), [rent]).remaining, 180000);
  });
  test('Amount alone and categorized or attached receipts remain separate spending', () {
    for (final e in [
      expense(100000),
      expense(100000, subcategory: null, note: 'ORLEN STACJA PALIW'),
      expense(
        100000,
        subcategory: null,
        note: 'CZYNSZ',
        receipt: 'receipt.img',
      ),
    ]) {
      final result = reports.budgetBalance(plan(), [e]);
      expect(result.spent, 100000);
      expect(result.remaining, 80000);
    }
    final e = expense(100000, subcategory: null, note: 'ORLEN');
    final review = reconcileExpenses(plan(), [e]).reviews.single;
    expect(review.reason, MatchReviewReason.amountOnly);
    expect(review.candidateItemIds, [2]);
  });
  test(
    'Two same-title planned bills require a choice, never first-match guessing',
    () {
      final p = MonthlyPlanWithItems(plan().plan, [
        plan().items.first,
        item(id: 2, amount: 100000),
        item(id: 3, amount: 50000),
      ]);
      final e = expense(100000, subcategory: null, note: 'PRZELEW CZYNSZ');
      final result = reconcileExpenses(p, [e]);
      expect(result.assignments, isEmpty);
      expect(result.variable, [e]);
      expect(result.reviews.single.candidateItemIds, [2, 3]);
      expect(result.reviews.single.reason, MatchReviewReason.ambiguousTitle);
      expect(reports.budgetBalance(p, [e]).remaining, 30000);
      // User confirmation persists the selected relationship, not an amount guess.
      final confirmed = expense(
        100000,
        subcategory: null,
        note: 'PRZELEW CZYNSZ',
        bill: 2,
      );
      expect(reports.budgetBalance(p, [confirmed]).remaining, 130000);
    },
  );
  test(
    'Two real identical payments stay distinct and unresolved until linked',
    () {
      final entries = [
        expense(100000, id: 101, day: 3, subcategory: null, note: 'CZYNSZ'),
        expense(100000, id: 102, day: 8, subcategory: null, note: 'CZYNSZ'),
      ];
      final result = reconcileExpenses(plan(), entries);
      expect(result.variable.map((e) => e.id), [101, 102]);
      expect(result.reviews.length, 2);
      expect(result.assignments, isEmpty);
      expect(reports.budgetBalance(plan(), entries).spent, 200000);
      final weeks = reports.weeklyReports(plan(), entries);
      expect(weeks[0].closingBalance, 80000);
      expect(weeks[1].closingBalance, -20000);
      expect(weeks[1].openingBalance, 80000);
    },
  );
  test(
    'Existing links have priority; a new similar transaction needs review',
    () {
      final linked = expense(40000, bill: 2);
      final imported = expense(60000, subcategory: null, note: 'CZYNSZ');
      final result = reconcileExpenses(plan(), [linked, imported]);
      expect(result.assignments[linked], 2);
      expect(result.variable, [imported]);
      expect(result.reviews.single.reason, MatchReviewReason.alreadyLinked);
    },
  );
  test('Removing or reducing a plan never erases actual payments', () {
    final paid = expense(90000, bill: 2);
    expect(reports.budgetBalance(plan(fixed: 80000), [paid]).remaining, 190000);
    expect(reports.budgetBalance(plan(fixed: 0), [paid]).remaining, 190000);
    expect(reconcileExpenses(plan(fixed: 0), [paid]).variable, [paid]);
  });
}
