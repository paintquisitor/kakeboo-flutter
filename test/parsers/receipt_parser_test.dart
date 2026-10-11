import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/domain/receipt_parser.dart';

void main() {
  test('uses the Polish total instead of VAT, cash or change', () {
    final result = parseReceipt('''
Sklep Spożywczy
ul. Polna 15
NIP 1234567890
2026-09-28 12:35
PARAGON FISKALNY
Chleb 1 x 4,50 4,50A
SUMA PTU 3,50
SUMA PLN 37,49
GOTÓWKA 100,00
RESZTA 62,51
''');
    expect(result.amountGrosz, 3749);
    expect(result.date, CalendarDate(2026, 9, 28));
    expect(result.merchant, 'Sklep Spożywczy');
  });

  test('accepts a split total, thousands and local date', () {
    final result = parseReceipt('''
Księgarnia
28.09.2026
PARAGON FISKALNY
DO ZAPŁATY
1 234,56 PLN
''');
    expect(result.amountGrosz, 123456);
    expect(result.date, CalendarDate(2026, 9, 28));
  });

  test('prefers amount due and accepts short names with digits', () {
    for (final name in ['4F', 'H&M', 'Sklep 24/7', 'Biedronka 1234']) {
      final result = parseReceipt(
        '$name\nPARAGON FISKALNY\nSUMA 20.00\nRabat 2.00\nDo zapłaty 18.00',
      );
      expect(result.merchant, name);
      expect(result.amountGrosz, 1800);
    }
  });

  test('skips metadata before a shop name', () {
    expect(
      parseReceipt(
        'NIP 1234567890\nul. Polna\n00-001 Warszawa\n'
        '2026-09-28 12:35 KASA\nSklep 24\nPARAGON FISKALNY',
      ).merchant,
      'Sklep 24',
    );
    expect(
      parseReceipt(
        'NIP 1234567890\nul. Polna\n00-001 Warszawa\n'
        'PARAGON FISKALNY',
      ).merchant,
      isNull,
    );
  });

  test('ambiguous or malformed recognition leaves uncertain fields empty', () {
    expect(parseReceipt('SUMA PLN 12,00\nSUMA PLN 13,00').amountGrosz, isNull);
    expect(
      parseReceipt('SUMA VAT 3,00\nGOTÓWKA 100,00\nRESZTA 70,00').amountGrosz,
      isNull,
    );
    expect(parseReceipt('TOTAL EUR 12.50').amountGrosz, isNull);
    expect(parseReceipt('SUMA PLN -12,50').amountGrosz, isNull);
    expect(parseReceipt('SUMA PLN 0,00').amountGrosz, isNull);
    expect(parseReceipt('31.02.2026').date, isNull);
    expect(parseReceipt('28.09.2026\n29.09.2026').date, isNull);
    expect(parseReceipt('').hasValues, isFalse);
  });
}
