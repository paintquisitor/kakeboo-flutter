import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../core/time/calendar_date.dart';
import '../domain/models.dart' as domain;
import '../domain/expense_category.dart';
import '../domain/plan_lifecycle.dart';

part 'kakebo_database.g.dart';

@DataClassName('MonthlyPlanRow')
class MonthlyPlans extends Table {
  @override
  String get tableName => 'monthly_plans';
  TextColumn get month => text()();
  IntColumn get savingsGrosz => integer().named('savingsGrosz')();
  TextColumn get resolutions => text()();
  @override
  Set<Column> get primaryKey => {month};
}

@DataClassName('PlannedItemRow')
class PlannedItems extends Table {
  @override
  String get tableName => 'planned_items';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get month =>
      text().references(MonthlyPlans, #month, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get title => text()();
  IntColumn get amountGrosz => integer().named('amountGrosz')();
  IntColumn get dateEpochDay => integer().named('dateEpochDay')();
  TextColumn get recurrence => text().withDefault(const Constant('MONTHLY'))();
  TextColumn get recurrenceAnchorMonth =>
      text().named('recurrenceAnchorMonth').withDefault(const Constant(''))();
  TextColumn get icon => text().withDefault(const Constant(''))();
}

@DataClassName('CustomCategoryRow')
class CustomCategories extends Table {
  @override
  String get tableName => 'custom_categories';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameKey => text().named('nameKey').unique()();
  TextColumn get icon => text().withDefault(const Constant('WALLET'))();
}

@DataClassName('CustomSubcategoryRow')
class CustomSubcategories extends Table {
  @override
  String get tableName => 'custom_subcategories';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().named('categoryId').references(CustomCategories, #id)();
  TextColumn get name => text()();
  TextColumn get nameKey => text().named('nameKey')();
  @override
  List<Set<Column>> get uniqueKeys => [
    {categoryId, nameKey},
  ];
}

@DataClassName('EntryRow')
class Entries extends Table {
  @override
  String get tableName => 'entries';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountGrosz => integer().named('amountGrosz')();
  TextColumn get type => text()();
  IntColumn get dateEpochDay => integer().named('dateEpochDay')();
  TextColumn get note => text()();
  TextColumn get subcategory => text().nullable()();
  IntColumn get plannedItemId => integer()
      .named('plannedItemId')
      .nullable()
      .references(PlannedItems, #id, onDelete: KeyAction.setNull)();
  TextColumn get receiptName => text().named('receiptName').nullable()();
  IntColumn get customSubcategoryId => integer()
      .named('customSubcategoryId')
      .nullable()
      .references(CustomSubcategories, #id)();
}

@DataClassName('MonthlyReflectionRow')
class MonthlyReflections extends Table {
  @override
  String get tableName => 'monthly_reflections';
  TextColumn get month => text()();
  TextColumn get successes => text()();
  TextColumn get improvements => text()();
  TextColumn get nextMonth => text().named('nextMonth')();
  @override
  Set<Column> get primaryKey => {month};
}

@DriftDatabase(
  tables: [
    MonthlyPlans,
    PlannedItems,
    CustomCategories,
    CustomSubcategories,
    Entries,
    MonthlyReflections,
  ],
)
class KakeboDatabase extends _$KakeboDatabase implements MonthlyPlanStore {
  KakeboDatabase(super.executor);
  KakeboDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async =>
        throw StateError('Unsupported Flutter schema $from -> $to'),
    beforeOpen: (details) async => customStatement('PRAGMA foreign_keys = ON'),
  );

  Future<int> saveEntry(domain.Entry entry) => into(entries).insert(
    EntriesCompanion.insert(
      id: entry.id == 0 ? const Value.absent() : Value(entry.id),
      amountGrosz: entry.amountGrosz,
      type: entry.type.storageKey,
      dateEpochDay: entry.dateEpochDay,
      note: entry.note,
      subcategory: Value(entry.subcategory?.storageKey),
      plannedItemId: Value(entry.plannedItemId),
      receiptName: Value(entry.receiptName),
      customSubcategoryId: Value(entry.customSubcategoryId),
    ),
    mode: InsertMode.insertOrReplace,
  );

  Stream<List<domain.Entry>> watchEntries() =>
      (select(entries)..orderBy([
            (t) => OrderingTerm.asc(t.dateEpochDay),
            (t) => OrderingTerm.asc(t.id),
          ]))
          .watch()
          .map((rows) => rows.map(_entry).toList());

  Future<List<domain.Entry>> allEntries() async =>
      (await select(entries).get()).map(_entry).toList();
  Future<void> deleteEntry(int id) async =>
      (delete(entries)..where((t) => t.id.equals(id))).go();

  domain.Entry _entry(EntryRow row) => domain.Entry(
    id: row.id,
    amountGrosz: row.amountGrosz,
    type: domain.EntryType.values.firstWhere((e) => e.storageKey == row.type),
    dateEpochDay: row.dateEpochDay,
    note: row.note,
    subcategory: row.subcategory == null
        ? null
        : ExpenseSubcategory.fromStorageKey(row.subcategory!),
    plannedItemId: row.plannedItemId,
    receiptName: row.receiptName,
    customSubcategoryId: row.customSubcategoryId,
  );

  @override
  Future<domain.MonthlyPlanWithItems?> findMonth(YearMonth month) async {
    final plan = await (select(
      monthlyPlans,
    )..where((t) => t.month.equals(month.toString()))).getSingleOrNull();
    if (plan == null) return null;
    final rows = await (select(
      plannedItems,
    )..where((t) => t.month.equals(month.toString()))).get();
    return domain.MonthlyPlanWithItems(
      domain.MonthlyPlan(
        month: month,
        savingsGrosz: plan.savingsGrosz,
        resolutions: plan.resolutions,
      ),
      rows.map(
        (r) => domain.PlannedItem(
          id: r.id,
          month: month,
          type: domain.EntryType.values.firstWhere(
            (e) => e.storageKey == r.type,
          ),
          title: r.title,
          amountGrosz: r.amountGrosz,
          dateEpochDay: r.dateEpochDay,
          recurrence: domain.PlanRecurrence.values.firstWhere(
            (e) => e.storageKey == r.recurrence,
          ),
          recurrenceAnchorMonth: r.recurrenceAnchorMonth.isEmpty
              ? month
              : YearMonth.parse(r.recurrenceAnchorMonth),
          icon: r.icon,
        ),
      ),
    );
  }

  @override
  Future<domain.MonthlyPlanWithItems?> findPreviousMonth(
    YearMonth month,
  ) async {
    final row =
        await (select(monthlyPlans)
              ..where((t) => t.month.isSmallerThanValue(month.toString()))
              ..orderBy([(t) => OrderingTerm.desc(t.month)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : findMonth(YearMonth.parse(row.month));
  }

  Stream<domain.MonthlyPlanWithItems?> watchMonth(YearMonth month) =>
      customSelect(
        'SELECT month FROM monthly_plans WHERE month = ? UNION '
        'SELECT month FROM planned_items WHERE month = ?',
        variables: [
          Variable.withString(month.toString()),
          Variable.withString(month.toString()),
        ],
        readsFrom: {monthlyPlans, plannedItems},
      ).watch().asyncMap((_) => findMonth(month));

  /// Observe a year without creating plans for months that have not started.
  Stream<List<domain.MonthlyPlanWithItems>> watchYear(int year) =>
      customSelect(
        'SELECT month FROM monthly_plans WHERE month LIKE ? UNION '
        'SELECT month FROM planned_items WHERE month LIKE ?',
        variables: [
          Variable.withString('$year-%'),
          Variable.withString('$year-%'),
        ],
        readsFrom: {monthlyPlans, plannedItems},
      ).watch().asyncMap((_) async {
        final months = [for (var m = 1; m <= 12; m++) YearMonth(year, m)];
        return Future.wait(
          months.map(
            (month) async =>
                await findMonth(month) ??
                domain.MonthlyPlanWithItems.empty(month),
          ),
        );
      });

  Future<void> savePlan(domain.MonthlyPlan plan) =>
      into(monthlyPlans).insertOnConflictUpdate(
        MonthlyPlansCompanion.insert(
          month: plan.month.toString(),
          savingsGrosz: plan.savingsGrosz,
          resolutions: plan.resolutions,
        ),
      );

  Future<int> savePlannedItem(domain.PlannedItem item) =>
      into(plannedItems).insertOnConflictUpdate(
        PlannedItemsCompanion.insert(
          id: item.id == 0 ? const Value.absent() : Value(item.id),
          month: item.month.toString(),
          type: item.type.storageKey,
          title: item.title,
          amountGrosz: item.amountGrosz,
          dateEpochDay: item.dateEpochDay,
          recurrence: Value(item.recurrence.storageKey),
          recurrenceAnchorMonth: Value(item.recurrenceAnchorMonth.toString()),
          icon: Value(item.icon),
        ),
      );

  Future<int> deletePlannedItem(int id) => transaction(() async {
    final linked =
        await (select(entries)
              ..where((t) => t.plannedItemId.equals(id))
              ..limit(1))
            .get();
    if (linked.isNotEmpty) {
      throw StateError('Planned item has historical payments');
    }
    return (delete(plannedItems)..where((t) => t.id.equals(id))).go();
  });

  Future<int> saveCategory(domain.CustomCategory category) async {
    if (category.id == 0) {
      return into(customCategories).insert(
        CustomCategoriesCompanion.insert(
          name: category.name,
          nameKey: category.nameKey,
          icon: Value(category.icon),
        ),
      );
    }
    final updated =
        await (update(
          customCategories,
        )..where((t) => t.id.equals(category.id))).write(
          CustomCategoriesCompanion(
            name: Value(category.name),
            nameKey: Value(category.nameKey),
            icon: Value(category.icon),
          ),
        );
    if (updated != 1) throw StateError('Category no longer exists');
    return category.id;
  }

  Future<int> deleteCategory(int id) => transaction(() async {
    final children = await (select(
      customSubcategories,
    )..where((t) => t.categoryId.equals(id))).get();
    for (final child in children) {
      final used =
          await (select(entries)
                ..where((t) => t.customSubcategoryId.equals(child.id))
                ..limit(1))
              .get();
      if (used.isNotEmpty) {
        throw StateError('Category has historical expenses');
      }
    }
    await (delete(
      customSubcategories,
    )..where((t) => t.categoryId.equals(id))).go();
    return (delete(customCategories)..where((t) => t.id.equals(id))).go();
  });

  Future<int> saveSubcategory(domain.CustomSubcategory subcategory) async {
    if (subcategory.id == 0) {
      return into(customSubcategories).insert(
        CustomSubcategoriesCompanion.insert(
          categoryId: subcategory.categoryId,
          name: subcategory.name,
          nameKey: subcategory.nameKey,
        ),
      );
    }
    final updated =
        await (update(
          customSubcategories,
        )..where((t) => t.id.equals(subcategory.id))).write(
          CustomSubcategoriesCompanion(
            name: Value(subcategory.name),
            nameKey: Value(subcategory.nameKey),
          ),
        );
    if (updated != 1) throw StateError('Subcategory no longer exists');
    return subcategory.id;
  }

  Future<int> deleteSubcategory(int id) => transaction(() async {
    final used =
        await (select(entries)
              ..where((t) => t.customSubcategoryId.equals(id))
              ..limit(1))
            .get();
    if (used.isNotEmpty) {
      throw StateError('Subcategory has historical expenses');
    }
    return (delete(customSubcategories)..where((t) => t.id.equals(id))).go();
  });

  Future<void> saveReflection(domain.MonthlyReflection reflection) =>
      into(monthlyReflections).insertOnConflictUpdate(
        MonthlyReflectionsCompanion.insert(
          month: reflection.month.toString(),
          successes: reflection.successes,
          improvements: reflection.improvements,
          nextMonth: reflection.nextMonth,
        ),
      );

  Stream<MonthlyReflectionRow?> watchReflection(YearMonth month) => (select(
    monthlyReflections,
  )..where((t) => t.month.equals(month.toString()))).watchSingleOrNull();

  @override
  Future<bool> createIfAbsent(domain.MonthlyPlanWithItems draft) => transaction(
    () async {
      final month = draft.plan.month.toString();
      if (await (select(
            monthlyPlans,
          )..where((t) => t.month.equals(month))).getSingleOrNull() !=
          null) {
        return false;
      }
      await into(monthlyPlans).insert(
        MonthlyPlansCompanion.insert(
          month: month,
          savingsGrosz: draft.plan.savingsGrosz,
          resolutions: draft.plan.resolutions,
        ),
      );
      for (final item in draft.items) {
        await into(plannedItems).insert(
          PlannedItemsCompanion.insert(
            month: month,
            type: item.type.storageKey,
            title: item.title,
            amountGrosz: item.amountGrosz,
            dateEpochDay: item.dateEpochDay,
            recurrence: Value(item.recurrence.storageKey),
            recurrenceAnchorMonth: Value(item.recurrenceAnchorMonth.toString()),
            icon: Value(item.icon),
          ),
        );
      }
      return true;
    },
  );

  Stream<List<CustomCategoryRow>> watchCategories() =>
      select(customCategories).watch();
  Stream<List<CustomSubcategoryRow>> watchSubcategories() =>
      select(customSubcategories).watch();
  Stream<List<MonthlyReflectionRow>> watchReflections() =>
      select(monthlyReflections).watch();
}
