import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Amounts are stored in minor units with scale 100, regardless of currency.
String formatMoney(
  int minorUnits, {
  required String currencyCode,
  required Locale locale,
}) {
  final formatter = NumberFormat.currency(
    locale: locale.toLanguageTag(),
    name: currencyCode,
    symbol: NumberFormat.simpleCurrency(
      locale: locale.toLanguageTag(),
      name: currencyCode,
    ).currencySymbol,
    decimalDigits: 2,
  );
  return formatter.format(minorUnits / 100);
}

String formatMonth(DateTime month, Locale locale) {
  final text = DateFormat('LLLL yyyy', locale.toLanguageTag()).format(month);
  return text.replaceFirst(text[0], text[0].toUpperCase());
}

String formatDay(DateTime day, Locale locale) =>
    DateFormat.yMd(locale.toLanguageTag()).format(day);
