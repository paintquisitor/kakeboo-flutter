import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/documents/local_document_reader.dart';

import 'support/legacy_backup_probe.dart';

void main() {
  test('normalization preserves operation boundaries and Polish text', () {
    expect(
      normalizeDocumentText(
        ' Data\toperacji\u00a0OSZCZĘDZANIE  \r\n'
        '\r\n −1\u202f250,00 PLN\rTytuł: Żywność ',
      ),
      'Data operacji OSZCZĘDZANIE\n-1 250,00 PLN\nTytuł: Żywność',
    );
  });

  test(
    'old backup preserves money, IDs, dates, relations and receipt bytes',
    () {
      final backup = readLegacyFixture(
        File('test/fixtures/legacy_v1.zip').readAsBytesSync(),
      );
      final tables = backup.manifest['tables'] as Map<String, dynamic>;
      expect(tables.keys.toSet(), {
        'monthly_plans',
        'planned_items',
        'entries',
        'custom_categories',
        'custom_subcategories',
        'monthly_reflections',
      });
      final entries = tables['entries'] as List;
      expect(entries.map((e) => e['id']), [101, 102]);
      expect(entries.map((e) => e['amountGrosz']), [2000, 125000]);
      expect(entries.first['dateEpochDay'], 20724);
      expect(
        entries.first['customSubcategoryId'],
        tables['custom_subcategories'][0]['id'],
      );
      expect(entries.last['plannedItemId'], tables['planned_items'][0]['id']);
      expect(
        backup.receipts[entries.first['receiptName']],
        File('test/fixtures/receipt.png').readAsBytesSync(),
      );
      expect(backup.manifest['profileSettings']['bookName'], 'Księga testowa');
      expect(
        backup.manifest['profileSettings'].containsKey('currency'),
        isFalse,
      );
    },
  );
}
