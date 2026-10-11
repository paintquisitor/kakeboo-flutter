import '../core/time/calendar_date.dart';
import 'money.dart';

final class ReceiptSuggestion {
  const ReceiptSuggestion({this.amountGrosz, this.date, this.merchant});

  final int? amountGrosz;
  final CalendarDate? date;
  final String? merchant;

  bool get hasValues => amountGrosz != null || date != null || merchant != null;
}

/// Suggestions are conservative: cash tendered and the largest visible number
/// are never interpreted as the amount due.
ReceiptSuggestion parseReceipt(String text) {
  final lines = text
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  final normalized = lines.map(_normalize).toList();
  final money = RegExp(r'(?<![\d.,])\d+(?:[ \u00a0]\d{3})*[.,]\d{2}(?![\d.,])');
  final currency = RegExp(r'\b(EUR|USD|GBP|CHF|CZK|SEK|NOK|DKK|UAH)\b|[€£\$]');
  final dateIso = RegExp(r'(?<!\d)(20\d{2})[-./](\d{2})[-./](\d{2})(?!\d)');
  final dateLocal = RegExp(r'(?<!\d)(\d{2})[-./](\d{2})[-./](20\d{2})(?!\d)');
  final totals = <(int, int)>[];
  for (var i = 0; i < normalized.length; i++) {
    final line = normalized[i];
    final priority =
        RegExp(r'\b(PTU|VAT|NETTO|RABAT|OSZCZEDNOSCI)\b').hasMatch(line)
        ? 0
        : RegExp(r'\b(DO ZAPLATY|NALEZNOSC)\b').hasMatch(line)
        ? 3
        : RegExp(r'\bSUMA\s*(PLN|ZL)\b').hasMatch(line)
        ? 2
        : RegExp(r'\b(SUMA|RAZEM|TOTAL)\b').hasMatch(line)
        ? 1
        : 0;
    if (priority == 0) continue;
    String? valueLine;
    if (money.hasMatch(line)) {
      valueLine = line;
    } else if (i + 1 < normalized.length &&
        RegExp(r'^[\d\s.,]+(?:PLN|ZL|EUR|USD|GBP|CHF|€|£|\$)?$')
            .hasMatch(normalized[i + 1])) {
      valueLine = normalized[i + 1];
    }
    if (valueLine == null ||
        currency.hasMatch('$line $valueLine') ||
        RegExp(r'[-−]\s*\d').hasMatch(valueLine)) {
      continue;
    }
    final values = money
        .allMatches(valueLine)
        .map((match) => parseGrosz(match.group(0)!))
        .whereType<int>()
        .where((value) => value > 0)
        .toList();
    if (values.length == 1) totals.add((priority, values.single));
  }
  int? amount;
  if (totals.isNotEmpty) {
    final best = totals.map((item) => item.$1).reduce((a, b) => a > b ? a : b);
    final values = totals
        .where((item) => item.$1 == best)
        .map((item) => item.$2)
        .toSet();
    if (values.length == 1) amount = values.single;
  }

  final dates = <CalendarDate>{};
  for (final line in lines) {
    for (final match in dateIso.allMatches(line)) {
      final date = _date(match.group(1)!, match.group(2)!, match.group(3)!);
      if (date != null) dates.add(date);
    }
    for (final match in dateLocal.allMatches(line)) {
      final date = _date(match.group(3)!, match.group(2)!, match.group(1)!);
      if (date != null) dates.add(date);
    }
  }

  final header = <String>[];
  for (final line in lines) {
    if (_normalize(line).contains('PARAGON') || header.length == 5) break;
    header.add(line);
  }
  String? merchant;
  for (final line in header) {
    final value = _normalize(line);
    if (!RegExp(r'[A-Za-zĄĆĘŁŃÓŚŹŻąćęłńóśźż]').hasMatch(line) ||
        dateIso.hasMatch(line) ||
        dateLocal.hasMatch(line) ||
        money.hasMatch(line) ||
        RegExp(r'^\d{2}-\d{3}\b').hasMatch(line) ||
        RegExp(
          r'^(NIP|TEL|UL|ULICA|DATA|KASA|KASJER|WWW|HTTP|SUMA|RAZEM|TOTAL|DO ZAPLATY|GOTOWKA|RESZTA|SPRZEDAZ|PTU|VAT)\b',
        ).hasMatch(value)) {
      continue;
    }
    merchant = line.length > 100 ? line.substring(0, 100) : line;
    break;
  }
  return ReceiptSuggestion(
    amountGrosz: amount,
    date: dates.length == 1 ? dates.single : null,
    merchant: merchant,
  );
}

CalendarDate? _date(String year, String month, String day) {
  try {
    return CalendarDate(int.parse(year), int.parse(month), int.parse(day));
  } catch (_) {
    return null;
  }
}

String _normalize(String value) {
  const source = 'ąćęłńóśźżĄĆĘŁŃÓŚŹŻ';
  const target = 'acelnoszzACELNOSZZ';
  var result = value;
  for (var i = 0; i < source.length; i++) {
    result = result.replaceAll(source[i], target[i]);
  }
  return result.toUpperCase();
}
