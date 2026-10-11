const maxAmountGrosz = 99999999999;

/// The legacy scale is always 100, including currencies such as JPY.
int? parseGrosz(String text) {
  final value = text
      .trim()
      .replaceAll(RegExp('[ \u00a0]'), '')
      .replaceAll(',', '.');
  if (!RegExp(r'^[0-9]+(?:\.[0-9]{1,2})?$').hasMatch(value)) return null;
  final parts = value.split('.');
  final minor =
      BigInt.parse(parts[0]) * BigInt.from(100) +
      BigInt.parse(parts.length == 1 ? '0' : parts[1].padRight(2, '0'));
  return minor > BigInt.from(maxAmountGrosz) ? null : minor.toInt();
}

String amountInput(int grosz, {String languageCode = 'pl'}) {
  final absolute = BigInt.from(grosz).abs();
  final separator = languageCode.split(RegExp('[-_]')).first == 'pl'
      ? ','
      : '.';
  return '${grosz < 0 ? '-' : ''}${absolute ~/ BigInt.from(100)}$separator'
      '${(absolute % BigInt.from(100)).toString().padLeft(2, '0')}';
}

/// Exact, currency-labelled output without floating point conversion.
/// Localized currency symbols/grouping belong to the presentation layer.
String formatMoney(
  int grosz, {
  required String currencyCode,
  String languageCode = 'pl',
}) {
  if (!RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
    throw ArgumentError.value(currencyCode, 'currencyCode');
  }
  return '${amountInput(grosz, languageCode: languageCode)} $currencyCode';
}
