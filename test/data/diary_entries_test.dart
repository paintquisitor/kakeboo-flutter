import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/data/kakebo_data_store.dart';
import 'package:kakebo/domain/budget_reports.dart';
import 'package:kakebo/domain/expense_category.dart';
import 'package:kakebo/domain/models.dart';

import '../domain/fixtures.dart';

void main() {
  late Directory temp;
  late KakeboDataStore store;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('kakebo-f08-');
    store = await KakeboDataStore.openAt(temp);
  });
  tearDown(() async {
    await store.close();
    await temp.delete(recursive: true);
  });

  test('expense create, edit and delete update day and monthly balance after reopen', () async {
    final db = store.database;
    final reports = BudgetReports(TestDateSource('2026-09-30'));
    final planValue = plan();
    final firstDay = CalendarDate.parse('2026-09-12');
    final nextDay = CalendarDate.parse('2026-09-13');
    final id = await db.saveEntry(
      Entry(
        amountGrosz: 2550,
        type: EntryType.expense,
        dateEpochDay: firstDay.epochDay,
        note: 'Sklep',
        subcategory: ExpenseSubcategory.food,
      ),
    );
    var saved = (await db.allEntries()).single;
    expect(saved.id, id);
    expect(reports.dayReport(firstDay, [saved]).spent, 2550);
    expect(reports.monthlyReport(planValue, [saved]).balance.remaining, 177450);

    await db.saveEntry(
      Entry(
        id: id,
        amountGrosz: 4000,
        type: EntryType.expense,
        dateEpochDay: nextDay.epochDay,
        note: 'Sklep po korekcie',
        subcategory: ExpenseSubcategory.transport,
      ),
    );
    await store.close();
    store = await KakeboDataStore.openAt(temp);
    saved = (await store.database.allEntries()).single;
    expect(saved.id, id);
    expect(saved.note, 'Sklep po korekcie');
    expect(reports.dayReport(firstDay, [saved]).spent, 0);
    expect(reports.dayReport(nextDay, [saved]).spent, 4000);
    expect(reports.monthlyReport(planValue, [saved]).balance.remaining, 176000);

    await store.database.deleteEntry(id);
    expect(await store.database.allEntries(), isEmpty);
    expect(reports.monthlyReport(planValue, []).balance.remaining, 180000);
  });

  test(
    'editing a linked fixed payment preserves its ID and avoids double charge',
    () async {
      final db = store.database;
      final month = ym('2026-09');
      await db.savePlan(MonthlyPlan(month: month));
      final fixedId = await db.savePlannedItem(item(id: 0, amount: 100000));
      final savedPlan = (await db.findMonth(month))!;
      final id = await db.saveEntry(
        Entry(
          amountGrosz: 100000,
          type: EntryType.expense,
          dateEpochDay: month.atDay(1).epochDay,
          plannedItemId: fixedId,
          note: 'Czynsz',
        ),
      );
      final before = BudgetReports(TestDateSource('2026-09-30'))
          .monthlyReport(savedPlan, await db.allEntries());
      expect(before.balance.fixedExpenses + before.balance.spent, 100000);
      await db.saveEntry(
        Entry(
          id: id,
          amountGrosz: 100000,
          type: EntryType.expense,
          dateEpochDay: month.atDay(1).epochDay,
          plannedItemId: fixedId,
          note: 'Czynsz opłacony',
        ),
      );
      final after = BudgetReports(TestDateSource('2026-09-30'))
          .monthlyReport(savedPlan, await db.allEntries());
      expect(after.balance.fixedExpenses + after.balance.spent, 100000);
      expect((await db.allEntries()).single.id, id);
    },
  );
}
