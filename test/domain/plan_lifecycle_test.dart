import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/domain/budget_reports.dart';
import 'package:kakebo/domain/models.dart';
import 'package:kakebo/domain/plan_lifecycle.dart';

import 'fixtures.dart';

// Transactional in-memory contract implementation; production SQLite is F04.
final class MemoryPlans implements MonthlyPlanStore {
  MemoryPlans(Iterable<MonthlyPlanWithItems> initial)
    : data = {for (final p in initial) p.plan.month: p};
  final Map<YearMonth, MonthlyPlanWithItems> data;
  int writes = 0;
  int nextId = 1000;
  void Function()? afterPreviousLookup;
  @override
  Future<MonthlyPlanWithItems?> findMonth(YearMonth month) async => data[month];
  @override
  Future<MonthlyPlanWithItems?> findPreviousMonth(YearMonth month) async {
    final previous = data.keys.where((m) => m.compareTo(month) < 0).toList()
      ..sort();
    afterPreviousLookup?.call();
    return previous.isEmpty ? null : data[previous.last];
  }

  @override
  Future<bool> createIfAbsent(MonthlyPlanWithItems draft) async {
    if (data.containsKey(draft.plan.month)) return false;
    final assigned = draft.items.map(
      (i) => PlannedItem(
        id: nextId++,
        month: i.month,
        type: i.type,
        title: i.title,
        amountGrosz: i.amountGrosz,
        dateEpochDay: i.dateEpochDay,
        recurrence: i.recurrence,
        recurrenceAnchorMonth: i.recurrenceAnchorMonth,
        icon: i.icon,
      ),
    );
    data[draft.plan.month] = MonthlyPlanWithItems(draft.plan, assigned);
    writes++;
    return true;
  }
}

void main() {
  test('An awaited lookup crossing month boundary creates only the new current month', () async {
    final clock = TestDateSource('2026-10-31');
    final store = MemoryPlans([plan()]);
    store.afterPreviousLookup = () {
      clock.value = CalendarDate(2026, 11, 1);
    };
    expect(await PlanLifecycle(store, clock).activateCurrentMonth(), true);
    expect(store.data.containsKey(ym('2026-10')), false);
    expect(store.data.containsKey(ym('2026-11')), true);
    expect(store.writes, 1);
  });
  test('Plan reserves fixed expenses and savings once, allowing a deficit', () {
    expect(planTotals(plan(income: 395000, fixed: 124800)).available, 250200);
    expect(
      planTotals(plan(income: 395000, fixed: 124800, savings: 300000))
          .available,
      -29800,
    );
  });
  test('Monthly default and anchored quarterly/yearly recurrence survive year changes', () {
    MonthlyPlanWithItems recurring(String month) =>
        MonthlyPlanWithItems(MonthlyPlan(month: ym(month)), [
          item(id: 1, month: month, type: EntryType.income, amount: 300000),
          item(
            id: 2,
            month: month,
            amount: 120000,
            recurrence: PlanRecurrence.quarterly,
            anchor: '2026-01',
          ),
          item(
            id: 3,
            month: month,
            amount: 60000,
            recurrence: PlanRecurrence.yearly,
            anchor: '2026-01',
          ),
        ]);
    expect(planTotals(recurring('2026-01')).available, 120000);
    expect(planTotals(recurring('2026-02')).available, 300000);
    expect(planTotals(recurring('2026-04')).available, 180000);
    expect(planTotals(recurring('2027-01')).available, 120000);
    final quarterly = recurring('2026-02').items[1];
    expect(quarterly.isDueIn(ym('2025-10')), false);
    expect(quarterly.nextDueMonth(), ym('2026-04'));
    expect(quarterly.nextDueMonth(ym('2025-01')), ym('2026-01'));
    expect(item().recurrence, PlanRecurrence.monthly);
  });
  test('Navigation never creates history/future plans or deletes saved future records', () async {
    final future = plan(month: '2026-12');
    final store = MemoryPlans([plan(), future]);
    final lifecycle = PlanLifecycle(store, TestDateSource('2026-10-01'));
    expect((await lifecycle.readMonth(ym('2026-10'))).items, isEmpty);
    expect((await lifecycle.readMonth(ym('2026-08'))).items, isEmpty);
    expect((await lifecycle.readMonth(ym('2027-01'))).items, isEmpty);
    expect(await lifecycle.readMonth(ym('2026-12')), same(future));
    expect(store.writes, 0);
    expect(store.data.length, 2);
  });
  test('Only lifecycle at month start copies once, including concurrent activation', () async {
    final store = MemoryPlans([plan()]);
    final clock = TestDateSource('2026-09-30');
    final lifecycle = PlanLifecycle(store, clock);
    expect(await lifecycle.activateCurrentMonth(), false);
    expect(store.data.containsKey(ym('2026-10')), false);
    clock.value = CalendarDate(2026, 10, 1);
    final copies = await Future.wait([
      lifecycle.activateCurrentMonth(),
      PlanLifecycle(store, clock).activateCurrentMonth(),
    ]);
    expect(copies.where((v) => v).length, 1);
    expect(await lifecycle.activateCurrentMonth(), false);
    final october = store.data[ym('2026-10')]!;
    expect(october.plan.savingsGrosz, 20000);
    expect(october.plan.resolutions, 'Plan testowy');
    expect(october.items.map((i) => i.amountGrosz), [300000, 100000]);
    expect(october.items.map((i) => i.id), [1000, 1001]);
    expect(store.data[ym('2026-09')]!.items.map((i) => i.id), [1, 2]);
    expect(store.writes, 1);
  });
  test(
    'Resume after a gap creates only current month from latest past plan',
    () async {
      final store = MemoryPlans([
        plan(month: '2026-08'),
        plan(),
        plan(month: '2027-02'),
      ]);
      final lifecycle = PlanLifecycle(store, TestDateSource('2027-01-03'));
      expect(await lifecycle.activateCurrentMonth(), true);
      expect(store.data.keys.map((m) => m.toString()).toSet(), {
        '2026-08',
        '2026-09',
        '2027-01',
        '2027-02',
      });
      expect(
        store.data[ym('2027-01')]!.items.first.recurrenceAnchorMonth,
        ym('2026-09'),
      );
    },
  );
  test(
    'Copy clamps dates in February and retains non-due templates and icons',
    () async {
      for (final year in [2027, 2028]) {
        final january = '$year-01';
        final source = MonthlyPlanWithItems(MonthlyPlan(month: ym(january)), [
          item(
            month: january,
            day: 31,
            recurrence: PlanRecurrence.yearly,
            icon: 'BANK',
          ),
        ]);
        final store = MemoryPlans([source]);
        final lifecycle = PlanLifecycle(store, TestDateSource('$year-02-01'));
        await lifecycle.activateCurrentMonth();
        final february = store.data[ym('$year-02')]!;
        expect(
          CalendarDate.fromEpochDay(february.items.single.dateEpochDay).day,
          year == 2028 ? 29 : 28,
        );
        expect(february.items.single.icon, 'BANK');
        expect(february.items.single.recurrenceAnchorMonth, ym(january));
        expect(planTotals(february).fixedExpenses, 0);
        expect(february.items.single.nextDueMonth(), ym('${year + 1}-01'));
      }
    },
  );
  test('An intentionally empty existing plan stays empty; no source creates nothing', () async {
    final empty = MonthlyPlanWithItems.empty(ym('2026-10'));
    final store = MemoryPlans([plan(), empty]);
    expect(
      await PlanLifecycle(
        store,
        TestDateSource('2026-10-01'),
      ).activateCurrentMonth(),
      false,
    );
    expect(store.data[ym('2026-10')], same(empty));
    final fresh = MemoryPlans([]);
    expect(
      await PlanLifecycle(
        fresh,
        TestDateSource('2026-10-01'),
      ).activateCurrentMonth(),
      false,
    );
    expect(fresh.data, isEmpty);
  });
}
