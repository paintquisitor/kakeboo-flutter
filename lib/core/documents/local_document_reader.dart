import 'package:flutter/services.dart';

/// Local files only: bundled ML Kit on Android, system Vision on iOS.
class LocalDocumentReader {
  static const _channel = MethodChannel('pl.kakebo/local_documents');

  Future<String> readReceipt(String path) async {
    final result = await _channel.invokeListMethod<Object?>('readReceipt', {
      'path': path,
    });
    final lines =
        (result ?? []).map((value) {
          final line = Map<String, Object?>.from(value! as Map);
          return (
            text: line['text']! as String,
            left: (line['left']! as num).toDouble(),
            top: (line['top']! as num).toDouble(),
            height: (line['height']! as num).toDouble(),
          );
        }).toList()..sort(
          (a, b) => (a.top + a.height / 2).compareTo(b.top + b.height / 2),
        );
    // Recognizers can return amounts in separate blocks. Rejoin visual rows.
    final rows =
        <List<({String text, double left, double top, double height})>>[];
    for (final line in lines) {
      final row = rows.isEmpty ? null : rows.last;
      final anchor = row?.first;
      if (anchor != null &&
          (anchor.top + anchor.height / 2 - line.top - line.height / 2).abs() <
              (anchor.height < line.height ? anchor.height : line.height) / 2) {
        row!.add(line);
      } else {
        rows.add([line]);
      }
    }
    return normalizeDocumentText(
      rows
          .map((row) {
            row.sort((a, b) => a.left.compareTo(b.left));
            return row.map((line) => line.text).join(' ');
          })
          .join('\n'),
    );
  }

  /// Text-layer PDFs only. No OCR of scanned bank statements or network calls.
  Future<String> readPdf(String path) async {
    final pages = await _channel.invokeListMethod<String>('readPdf', {
      'path': path,
    });
    final text = normalizeDocumentText((pages ?? []).join('\n'));
    if (text.isEmpty) {
      throw const FormatException('PDF has no readable text layer');
    }
    return text;
  }
}

/// Keep line boundaries: operation types and title boundaries depend on them.
String normalizeDocumentText(String text) => text
    .replaceAll('\r\n', '\n')
    .replaceAll('\r', '\n')
    .replaceAll('\u00a0', ' ')
    .replaceAll('\u202f', ' ')
    .replaceAll('\u2212', '-')
    .split('\n')
    .map((line) => line.replaceAll(RegExp(r'[\t ]+'), ' ').trim())
    .where((line) => line.isNotEmpty)
    .join('\n');
