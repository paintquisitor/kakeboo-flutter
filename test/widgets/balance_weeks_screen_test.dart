import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/data/kakebo_database.dart';
import 'package:kakebo/domain/expense_category.dart';
import 'package:kakebo/domain/models.dart';
import 'package:kakebo/features/balance/balance_screen.dart';
import 'package:kakebo/features/diary/diary_categories.dart';
import 'package:kakebo/features/weeks/weeks_screen.dart';
import 'package:kakebo/l10n/app_localizations.dart';

void main() {
  late KakeboDatabase database;
  setUp(() => database = KakeboDatabase.memory());
  tearDown(() => database.close());

  Widget app(Widget child) => MaterialApp(
    locale: const Locale('pl'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );

  testWidgets(
    'annual month opens separate fixed and diary details without double counting',
    (tester) async {
      final today = CalendarDate.fromCalendarFields(DateTime.now());
      final month = today.yearMonth.plusMonths(-1);
      await database.savePlan(MonthlyPlan(month: month, savingsGrosz: 10000));
      await database.savePlannedItem(
        PlannedItem(
          month: month,
          type: EntryType.income,
          title: 'Pensja',
          amountGrosz: 100000,
          dateEpochDay: month.firstDay.epochDay,
        ),
      );
      final fixedId = await database.savePlannedItem(
        PlannedItem(
          month: month,
          type: EntryType.expense,
          title: 'Czynsz',
          amountGrosz: 30000,
          dateEpochDay: month.firstDay.epochDay,
        ),
      );
      await database.saveEntry(
        Entry(
          amountGrosz: 30000,
          type: EntryType.expense,
          dateEpochDay: month.atDay(5).epochDay,
          note: 'Czynsz',
          plannedItemId: fixedId,
        ),
      );
      await database.saveEntry(
        Entry(
          amountGrosz: 2000,
          type: EntryType.expense,
          dateEpochDay: month.atDay(7).epochDay,
          note: 'Sklep',
          subcategory: ExpenseSubcategory.food,
        ),
      );

      var selected = month;
      var annual = true;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) => BalanceScreen(
              month: selected,
              database: database,
              currency: 'PLN',
              yearMode: annual,
              onYearMode: (value) => setState(() => annual = value),
              onSelectMonth: (value) => setState(() => selected = value),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final monthRow = find.byKey(Key('annual_month_${month.month}'));
      await tester.ensureVisible(monthRow);
      await tester.pumpAndSettle();
      await tester.tap(monthRow);
      await tester.pumpAndSettle();
      expect(annual, false);
      expect(selected, month);
      expect(find.textContaining('680,00'), findsWidgets);
      final fixedRow = find.byKey(const Key('open_fixed_expenses'));
      await tester.ensureVisible(fixedRow);
      await tester.pumpAndSettle();
      await tester.tap(fixedRow);
      await tester.pumpAndSettle();
      expect(find.text('Czynsz'), findsOneWidget);
      expect(find.text('Sklep'), findsNothing);
      await tester.tap(find.text('Bilans miesiąca').first);
      await tester.pumpAndSettle();
      final diaryRow = find.byKey(const Key('open_diary_expenses'));
      await tester.ensureVisible(diaryRow);
      await tester.pumpAndSettle();
      await tester.tap(diaryRow);
      await tester.pumpAndSettle();
      expect(find.text('Sklep'), findsOneWidget);
      expect(find.text('Czynsz'), findsNothing);
      await tester.tap(find.text('Bilans miesiąca').first);
      await tester.pumpAndSettle();
      await database.saveEntry(
        Entry(
          amountGrosz: 500,
          type: EntryType.expense,
          dateEpochDay: month.atDay(8).epochDay,
          note: 'Bilet',
          subcategory: ExpenseSubcategory.transport,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('675,00'), findsWidgets);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'future month stays zero and report navigation does not create a plan',
    (tester) async {
      final future = CalendarDate.fromCalendarFields(DateTime.now()).yearMonth
          .plusMonths(2);
      await tester.pumpWidget(
        app(
          BalanceScreen(
            month: future,
            database: database,
            currency: 'PLN',
            yearMode: false,
            onYearMode: (_) {},
            onSelectMonth: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('monthly_remaining')), findsOneWidget);
      expect(find.textContaining('0,00'), findsWidgets);
      expect(await database.findMonth(future), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'week selection changes colored daily bars and calculated progress',
    (tester) async {
      final month = CalendarDate.fromCalendarFields(DateTime.now()).yearMonth
          .plusMonths(-1);
      await database.savePlan(MonthlyPlan(month: month));
      await database.savePlannedItem(
        PlannedItem(
          month: month,
          type: EntryType.income,
          title: 'Pensja',
          amountGrosz: 10000,
          dateEpochDay: month.firstDay.epochDay,
        ),
      );
      await database.saveEntry(
        Entry(
          amountGrosz: 1000,
          type: EntryType.expense,
          dateEpochDay: month.atDay(2).epochDay,
          note: 'Food',
          subcategory: ExpenseSubcategory.food,
        ),
      );
      await database.saveEntry(
        Entry(
          amountGrosz: 2000,
          type: EntryType.expense,
          dateEpochDay: month.atDay(9).epochDay,
          note: 'Game',
          subcategory: ExpenseSubcategory.games,
        ),
      );
      await tester.pumpWidget(
        app(WeeksScreen(month: month, database: database, currency: 'PLN')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .value,
        0.9,
      );
      final foodBar = find.byKey(
        Key('daily_bar_2_${ExpenseCategory.needs.key.hashCode}'),
      );
      expect(
        tester.widget<Container>(foodBar).color,
        categoryColor(tester.element(foodBar), ExpenseCategory.needs.key),
      );
      await tester.tap(find.byKey(const Key('week_1')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .value,
        0.7,
      );
      expect(find.text('Kultura i czas wolny'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('reflection is saved only for selected month', (tester) async {
    final month = CalendarDate.fromCalendarFields(DateTime.now()).yearMonth
        .plusMonths(-1);
    await tester.pumpWidget(
      app(
        BalanceScreen(
          month: month,
          database: database,
          currency: 'PLN',
          yearMode: false,
          onYearMode: (_) {},
          onSelectMonth: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final edit = find.byKey(const Key('edit_reflection'));
    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('reflection_successes')),
      'Cel',
    );
    await tester.tap(find.byKey(const Key('save_reflection')));
    await tester.pumpAndSettle();
    expect(find.text('Cel'), findsOneWidget);
    final reflections = await database
        .select(database.monthlyReflections)
        .get();
    expect(reflections.single.month, month.toString());
    expect(reflections.single.successes, 'Cel');
    final otherMonth = month.plusMonths(-1);
    await tester.pumpWidget(
      app(
        BalanceScreen(
          month: otherMonth,
          database: database,
          currency: 'PLN',
          yearMode: false,
          onYearMode: (_) {},
          onSelectMonth: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final otherEdit = find.byKey(const Key('edit_reflection'));
    await tester.ensureVisible(otherEdit);
    await tester.pumpAndSettle();
    await tester.tap(otherEdit);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('reflection_successes')),
      'Drugi cel',
    );
    await tester.tap(find.byKey(const Key('save_reflection')));
    await tester.pumpAndSettle();
    final saved = await database.select(database.monthlyReflections).get();
    expect(saved, hasLength(2));
    expect(
      {for (final reflection in saved) reflection.month: reflection.successes},
      {month.toString(): 'Cel', otherMonth.toString(): 'Drugi cel'},
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
