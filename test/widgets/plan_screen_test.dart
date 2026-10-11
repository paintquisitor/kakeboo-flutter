import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/data/kakebo_database.dart';
import 'package:kakebo/features/categories/category_manager_screen.dart';
import 'package:kakebo/features/plan/plan_screen.dart';
import 'package:kakebo/l10n/app_localizations.dart';

void main() {
  late KakeboDatabase database;
  setUp(() => database = KakeboDatabase.memory());
  tearDown(() => database.close());

  testWidgets('preset and amount create a monthly fixed expense in SQLite', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: PlanScreen(
            month: YearMonth(2026, 9),
            database: database,
            currency: 'PLN',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Dodaj').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mieszkanie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Czynsz administracyjny'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '250,00');
    await tester.tap(find.text('Zapisz'));
    await tester.pumpAndSettle();

    final plan = await database.findMonth(YearMonth(2026, 9));
    expect(plan!.items.single.title, 'Czynsz administracyjny');
    expect(plan.items.single.amountGrosz, 25000);
    expect(plan.items.single.icon, 'HOME');
    expect(plan.items.single.recurrence.storageKey, 'MONTHLY');
    expect(find.text('Czynsz administracyjny'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('category and subcategory can be added through dialogs', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: CategoryManagerScreen(database: database),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dodaj kategorię'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ogród');
    await tester.tap(find.text('Wybierz ikonę'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Zwierzęta');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zwierzęta').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zapisz'));
    await tester.pumpAndSettle();
    expect(find.text('Ogród'), findsOneWidget);
    expect(
      (await database.select(database.customCategories).get()).single.icon,
      'ANIMALS',
    );
    await tester.tap(find.text('Dodaj podkategorię'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Rośliny');
    await tester.tap(find.text('Zapisz'));
    await tester.pumpAndSettle();
    expect(find.text('Rośliny'), findsOneWidget);
    expect(
      (await database.select(database.customSubcategories).get()).single.name,
      'Rośliny',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('custom fixed expense keeps its name, icon and frequency', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: PlanScreen(
            month: YearMonth(2026, 9),
            database: database,
            currency: 'PLN',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Dodaj').first);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(GridView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inne'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Własny wydatek'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Podatek');
    await tester.enterText(find.byType(TextField).at(1), '120');
    await tester.tap(find.text('Kwartał'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wybierz ikonę'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Dom');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dom').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zapisz'));
    await tester.pumpAndSettle();

    final saved = (await database.findMonth(YearMonth(2026, 9)))!.items.single;
    expect(saved.title, 'Podatek');
    expect(saved.amountGrosz, 12000);
    expect(saved.icon, 'HOME');
    expect(saved.recurrence.storageKey, 'QUARTERLY');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('opening a future month leaves the plan empty and read-only', (
    tester,
  ) async {
    final now = DateTime.now();
    final future = YearMonth(now.year, now.month + 1);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: PlanScreen(month: future, database: database, currency: 'PLN'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(
      find.text('Plan pojawi się po rozpoczęciu tego miesiąca.'),
      findsOneWidget,
    );
    expect(await database.findMonth(future), isNull);
    expect(
      tester
          .widget<IconButton>(
            find
                .ancestor(
                  of: find.byTooltip('Dodaj').first,
                  matching: find.byType(IconButton),
                )
                .first,
          )
          .onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
