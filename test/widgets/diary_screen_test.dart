import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/data/kakebo_database.dart';
import 'package:kakebo/domain/expense_catalog.dart';
import 'package:kakebo/domain/expense_category.dart';
import 'package:kakebo/domain/models.dart';
import 'package:kakebo/features/diary/diary_screen.dart';
import 'package:kakebo/features/diary/expense_editor.dart';
import 'package:kakebo/l10n/app_localizations.dart';

void main() {
  late KakeboDatabase database;
  setUp(() => database = KakeboDatabase.memory());
  tearDown(() => database.close());

  Widget app(Widget child, {String language = 'pl'}) => MaterialApp(
    locale: Locale(language),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );

  testWidgets(
    'day navigation updates transactions, sum and category totals together',
    (tester) async {
      await database.saveEntry(
        Entry(
          amountGrosz: 1000,
          type: EntryType.expense,
          dateEpochDay: CalendarDate.parse('2026-09-12').epochDay,
          note: 'Sklep',
          subcategory: ExpenseSubcategory.food,
        ),
      );
      await database.saveEntry(
        Entry(
          amountGrosz: 2500,
          type: EntryType.expense,
          dateEpochDay: CalendarDate.parse('2026-09-13').epochDay,
          note: 'Gra',
          subcategory: ExpenseSubcategory.games,
        ),
      );
      var date = CalendarDate.parse('2026-09-12');
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) => DiaryScreen(
              database: database,
              selectedDate: date,
              onSelectDate: (value) => setState(() => date = value),
              currency: 'PLN',
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      await tester.tap(find.text('W tym dniu'));
      await tester.pumpAndSettle();
      expect(find.text('Sklep'), findsOneWidget);
      expect(find.text('Gra'), findsNothing);
      expect(find.text('Pierwszej potrzeby'), findsOneWidget);
      expect(find.byKey(const Key('diary_day_total')), findsOneWidget);
      expect(find.textContaining('10,00'), findsWidgets);

      await tester.tap(find.byKey(const Key('next_day')));
      await tester.pumpAndSettle();
      expect(date, CalendarDate.parse('2026-09-13'));
      expect(find.text('Sklep'), findsNothing);
      expect(find.text('Gra'), findsOneWidget);
      await tester.tap(find.text('W tym dniu'));
      await tester.pumpAndSettle();
      expect(find.text('Kultura i czas wolny'), findsWidgets);
      expect(find.textContaining('25,00'), findsWidgets);
      expect(find.textContaining('10,00'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'category opens icon subcategory modal and selected icon replaces grid',
    (tester) async {
      await tester.pumpWidget(
        app(
          ExpenseEditor(
            database: database,
            catalog: ExpenseCatalog(),
            initialDate: CalendarDate.parse('2026-09-12'),
            currency: 'PLN',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category_NEEDS')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('subcategory_grid')), findsOneWidget);
      expect(find.byKey(const Key('subcategory_FOOD')), findsOneWidget);
      await tester.tap(find.byKey(const Key('subcategory_FOOD')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('selected_subcategory')), findsOneWidget);
      expect(find.byKey(const Key('category_NEEDS')), findsNothing);
      await tester.enterText(find.byKey(const Key('expense_amount')), '12,50');
      await tester.enterText(find.byKey(const Key('expense_note')), 'Sklep');
      await tester.tap(find.byKey(const Key('save_expense')));
      await tester.pumpAndSettle();
      final saved = (await database.allEntries()).single;
      expect(saved.amountGrosz, 1250);
      expect(saved.subcategory, ExpenseSubcategory.food);
      expect(saved.dateEpochDay, CalendarDate.parse('2026-09-12').epochDay);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('editing and deleting a journal expense changes stored entries', (
    tester,
  ) async {
    final date = CalendarDate.parse('2026-09-12');
    final id = await database.saveEntry(
      Entry(
        amountGrosz: 1250,
        type: EntryType.expense,
        dateEpochDay: date.epochDay,
        note: 'Sklep',
        subcategory: ExpenseSubcategory.food,
      ),
    );
    await tester.pumpWidget(
      app(
        DiaryScreen(
          database: database,
          selectedDate: date,
          onSelectDate: (_) {},
          currency: 'PLN',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('expense_$id')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('expense_amount')), '20,00');
    await tester.tap(find.byKey(const Key('save_expense')));
    await tester.pumpAndSettle();
    expect((await database.allEntries()).single.amountGrosz, 2000);
    expect(find.textContaining('20,00'), findsWidgets);

    await tester.tap(find.byKey(Key('delete_expense_$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_expense_delete')));
    await tester.pumpAndSettle();
    expect(await database.allEntries(), isEmpty);
    expect(find.byKey(Key('expense_$id')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'receipt stays on title line, trash on subcategory line and row stays compact',
    (tester) async {
      final entry = Entry(
        id: 11,
        amountGrosz: 1250,
        type: EntryType.expense,
        dateEpochDay: CalendarDate.parse('2026-09-12').epochDay,
        note: 'Sklep',
        subcategory: ExpenseSubcategory.food,
        receiptName: 'synthetic.img',
      );
      Widget row(Entry value, {ValueChanged<String>? receipt}) => app(
        Center(
          child: DiaryTransactionRow(
            entry: value,
            catalog: ExpenseCatalog(),
            currency: 'PLN',
            onEdit: () {},
            onDelete: () {},
            onOpenReceipt: receipt,
          ),
        ),
      );
      await tester.pumpWidget(row(entry, receipt: (_) {}));
      final height = tester.getSize(find.byKey(const Key('expense_11'))).height;
      final titleY = tester.getCenter(find.text('Sklep')).dy;
      final categoryY = tester
          .getCenter(find.textContaining('Pierwszej potrzeby'))
          .dy;
      expect(
        (tester.getCenter(find.byKey(const Key('receipt_11'))).dy - titleY)
            .abs(),
        lessThan(8),
      );
      expect(
        (tester.getCenter(find.byKey(const Key('delete_expense_11'))).dy -
                categoryY)
            .abs(),
        lessThan(8),
      );
      expect(height, lessThanOrEqualTo(75));
      await tester.pumpWidget(
        row(
          Entry(
            id: 11,
            amountGrosz: 1250,
            type: EntryType.expense,
            dateEpochDay: entry.dateEpochDay,
            note: 'Sklep',
            subcategory: ExpenseSubcategory.food,
          ),
          receipt: (_) {},
        ),
      );
      expect(find.byKey(const Key('receipt_11')), findsNothing);
      expect(
        tester.getSize(find.byKey(const Key('expense_11'))).height,
        height,
      );
    },
  );

  testWidgets(
    'uncategorized historical entry is labelled Card expenses in both languages',
    (tester) async {
      final entry = Entry(
        id: 15,
        amountGrosz: 1250,
        type: EntryType.expense,
        dateEpochDay: CalendarDate.parse('2026-09-12').epochDay,
      );
      Widget row(String language) => app(
        DiaryTransactionRow(
          entry: entry,
          catalog: ExpenseCatalog(),
          currency: 'PLN',
          onEdit: () {},
          onDelete: () {},
        ),
        language: language,
      );
      await tester.pumpWidget(row('pl'));
      expect(find.text('Wydatki z karty'), findsWidgets);
      await tester.pumpWidget(row('en'));
      expect(find.text('Card expenses'), findsWidgets);
    },
  );
}
