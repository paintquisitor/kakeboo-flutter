import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/domain/expense_category.dart';
import 'package:kakebo/domain/models.dart';
import 'package:kakebo/domain/money.dart';

import 'fixtures.dart';

void main() {
  test('Polish/English input is exact at scale 100 and bounded', () {
    expect(parseGrosz('1 234,56'), 123456);
    expect(parseGrosz('1\u00a0234.56'), 123456);
    expect(parseGrosz('0,1'), 10);
    expect(parseGrosz('0'), 0);
    expect(parseGrosz('999999999,99'), 99999999999);
    for (final value in [
      '',
      '-10',
      '1,234',
      '1.234,56',
      'NaN',
      '1e2',
      '1000000000',
      '99999999999999999999999',
    ]) {
      expect(parseGrosz(value), isNull, reason: value);
    }
  });
  test('Changing currency or language never rescales stored money', () {
    expect(amountInput(123456), '1234,56');
    expect(amountInput(123456, languageCode: 'en-US'), '1234.56');
    expect(amountInput(-1), '-0,01');
    expect(
      amountInput(-9223372036854775808, languageCode: 'en'),
      '-92233720368547758.08',
    );
    expect(formatMoney(123456, currencyCode: 'PLN'), '1234,56 PLN');
    expect(
      formatMoney(123456, currencyCode: 'JPY', languageCode: 'en'),
      '1234.56 JPY',
    );
    expect(formatMoney(123456, currencyCode: 'KWD'), '1234,56 KWD');
  });
  test('Java epoch days retain civil dates across years and time zones', () {
    expect(CalendarDate(1970, 1, 1).epochDay, 0);
    expect(CalendarDate(1969, 12, 31).epochDay, -1);
    expect(CalendarDate.fromEpochDay(20724).toString(), '2026-09-28');
    expect(CalendarDate(2026, 12, 31).plusDays(1).toString(), '2027-01-01');
    // Fields intentionally used without toUtc(), which would move late local days.
    expect(
      CalendarDate.fromCalendarFields(DateTime(2026, 9, 28, 23, 59)).epochDay,
      20724,
    );
    expect(
      CalendarDate.fromCalendarFields(DateTime.utc(2026, 9, 28)).epochDay,
      20724,
    );
    expect(
      CalendarDate.fromEpochDay(20724).plusDays(1).toString(),
      '2026-09-29',
    );
    expect(CalendarDate(2026, 3, 29).plusDays(1).toString(), '2026-03-30');
    expect(CalendarDate(2026, 10, 25).plusDays(1).toString(), '2026-10-26');
  });
  test('Leap February and invalid dates cannot silently normalize', () {
    expect(ym('2028-02').lengthOfMonth, 29);
    expect(ym('2027-02').lengthOfMonth, 28);
    expect(ym('2000-02').lengthOfMonth, 29);
    expect(ym('1900-02').lengthOfMonth, 28);
    expect(ym('2026-12').plusMonths(1), ym('2027-01'));
    expect(ym('2027-01').plusMonths(-1), ym('2026-12'));
    expect(CalendarDate(2028, 2, 28).plusDays(1).toString(), '2028-02-29');
    expect(() => CalendarDate.parse('2027-02-29'), throwsRangeError);
    expect(() => CalendarDate.parse('2026-13-01'), throwsRangeError);
    expect(
      () => CalendarDate.parse('2026-09-28T00:00:00Z'),
      throwsFormatException,
    );
    expect(() => CalendarDate.fromEpochDay(2932897), throwsRangeError);
  });
  test('Entry identifiers and relationships remain exact and validated', () {
    final e = expense(
      125000,
      id: 102,
      customId: 42,
      subcategory: null,
      bill: 12,
      receipt: '00000000-0000-4000-8000-000000000001.img',
      day: 28,
    );
    expect(
      [
        e.id,
        e.amountGrosz,
        e.dateEpochDay,
        e.plannedItemId,
        e.customSubcategoryId,
      ],
      [102, 125000, 20724, 12, 42],
    );
    expect(e.receiptName, '00000000-0000-4000-8000-000000000001.img');
    expect(
      ExpenseSubcategory.fromStorageKey('HOBBY_ACTIVITIES').category,
      ExpenseCategory.hobby,
    );
    expect(ExpenseSubcategory.fromStorageKey('FOOD').icon, 'CART');
    expect(
      () => ExpenseSubcategory.fromStorageKey('unknown'),
      throwsFormatException,
    );
    expect(() => expense(0), throwsArgumentError);
    expect(() => expense(100, customId: 42), throwsArgumentError);
    expect(
      () => Entry(
        amountGrosz: 100,
        type: EntryType.income,
        dateEpochDay: 20724,
        receiptName: 'receipt.img',
      ),
      throwsArgumentError,
    );
    expect(
      () => PlannedItem(
        month: ym('2026-02'),
        type: EntryType.income,
        title: 'Pensja',
        amountGrosz: 100,
        dateEpochDay: CalendarDate(2026, 3, 1).epochDay,
      ),
      throwsArgumentError,
    );
  });
}
