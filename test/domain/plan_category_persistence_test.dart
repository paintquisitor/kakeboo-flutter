import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/data/kakebo_data_store.dart';
import 'package:kakebo/domain/models.dart';
import 'package:kakebo/domain/plan_lifecycle.dart';

import 'fixtures.dart';

void main() {
  late Directory temp;
  late KakeboDataStore store;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('kakebo-f07-');
    store = await KakeboDataStore.openAt(temp);
  });
  tearDown(() async {
    await store.close();
    await temp.delete(recursive: true);
  });

  test(
    'plan persists and carries only when the next month has started',
    () async {
      final db = store.database;
      await db.savePlan(
        MonthlyPlan(
          month: ym('2026-09'),
          savingsGrosz: 25000,
          resolutions: 'Odkładam na rower',
        ),
      );
      await db.savePlannedItem(
        item(
          id: 0,
          month: '2026-09',
          title: 'Czynsz',
          amount: 120000,
          day: 30,
          icon: 'HOME',
        ),
      );
      await db.savePlannedItem(
        item(
          id: 0,
          month: '2026-09',
          type: EntryType.income,
          title: 'Pensja',
          amount: 400000,
          day: 5,
          icon: 'CASH',
        ),
      );
      final dates = TestDateSource('2026-09-30');
      final lifecycle = PlanLifecycle(db, dates);
      expect((await lifecycle.readMonth(ym('2026-10'))).items, isEmpty);
      expect(await db.findMonth(ym('2026-10')), isNull);

      dates.value = CalendarDate.parse('2026-10-01');
      expect(await lifecycle.activateCurrentMonth(), true);
      expect(await lifecycle.activateCurrentMonth(), false);
      final carried = (await db.findMonth(ym('2026-10')))!;
      expect(carried.items.length, 2);
      expect(
        carried.items.singleWhere((i) => i.title == 'Czynsz').dateEpochDay,
        ym('2026-10').atDay(30).epochDay,
      );
      expect(
        carried.items.every((i) => i.recurrence == PlanRecurrence.monthly),
        true,
      );
      expect(carried.plan.savingsGrosz, 25000);
      expect(await db.findMonth(ym('2026-11')), isNull);

      await store.close();
      store = await KakeboDataStore.openAt(temp);
      final reopened = (await store.database.findMonth(ym('2026-10')))!;
      expect(reopened.items.length, 2);
      expect(reopened.plan.resolutions, 'Odkładam na rower');
    },
  );

  test(
    'category edits retain entry ID; deletion protects historical expense',
    () async {
      final db = store.database;
      final categoryId = await db.saveCategory(
        const CustomCategory(
          id: 0,
          name: 'Ogród',
          nameKey: 'ogród',
          icon: 'HOME',
        ),
      );
      final subId = await db.saveSubcategory(
        CustomSubcategory(
          id: 0,
          categoryId: categoryId,
          name: 'Rośliny',
          nameKey: 'rośliny',
        ),
      );
      await db.saveEntry(
        Entry(
          amountGrosz: 2999,
          type: EntryType.expense,
          dateEpochDay: ym('2026-09').atDay(12).epochDay,
          customSubcategoryId: subId,
        ),
      );
      await db.saveCategory(
        CustomCategory(
          id: categoryId,
          name: 'Dom i ogród',
          nameKey: 'dom i ogród',
          icon: 'SPARKLES',
        ),
      );
      await db.saveSubcategory(
        CustomSubcategory(
          id: subId,
          categoryId: categoryId,
          name: 'Kwiaty',
          nameKey: 'kwiaty',
        ),
      );

      await expectLater(db.deleteSubcategory(subId), throwsStateError);
      await expectLater(db.deleteCategory(categoryId), throwsStateError);
      await store.close();
      store = await KakeboDataStore.openAt(temp);
      expect(
        (await store.database.allEntries()).single.customSubcategoryId,
        subId,
      );
      expect(
        (await store.database.select(store.database.customCategories).get())
            .single
            .name,
        'Dom i ogród',
      );
      expect(
        (await store.database.select(store.database.customSubcategories).get())
            .single
            .name,
        'Kwiaty',
      );
    },
  );

  test('duplicate category name cannot replace another category', () async {
    final db = store.database;
    await db.saveCategory(
      const CustomCategory(
        id: 0,
        name: 'Ogród',
        nameKey: 'ogród',
        icon: 'HOME',
      ),
    );
    await expectLater(
      db.saveCategory(
        const CustomCategory(
          id: 0,
          name: 'OGŁOSZENIE',
          nameKey: 'ogród',
          icon: 'CASH',
        ),
      ),
      throwsA(isA<Exception>()),
    );
    final rows = await db.select(db.customCategories).get();
    expect(rows.length, 1);
    expect(rows.single.name, 'Ogród');
    expect(rows.single.icon, 'HOME');
  });

  test('deleting a fixed expense cannot orphan a recorded payment', () async {
    final db = store.database;
    await db.savePlan(MonthlyPlan(month: ym('2026-09')));
    final itemId = await db.savePlannedItem(
      item(id: 0, month: '2026-09', title: 'Czynsz', amount: 120000, day: 5),
    );
    await db.saveEntry(
      Entry(
        amountGrosz: 120000,
        type: EntryType.expense,
        dateEpochDay: ym('2026-09').atDay(5).epochDay,
        plannedItemId: itemId,
      ),
    );

    await expectLater(db.deletePlannedItem(itemId), throwsStateError);
    expect((await db.findMonth(ym('2026-09')))!.items.single.id, itemId);
    expect((await db.allEntries()).single.plannedItemId, itemId);
  });
}
