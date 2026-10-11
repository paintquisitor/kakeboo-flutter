import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/data/backup_codec.dart';
import 'package:kakebo/data/kakebo_data_store.dart';
import 'package:kakebo/domain/models.dart';

void main() {
  late Directory temp;
  late KakeboDataStore store;
  late Uint8List legacy;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('kakebo-f04-');
    store = await KakeboDataStore.openAt(temp);
    legacy = File('test/fixtures/legacy_v1.zip').readAsBytesSync();
  });
  tearDown(() async {
    await store.close();
    await temp.delete(recursive: true);
  });

  test(
    'format 1 keeps IDs, dates, money, relations, categories and .img bytes',
    () async {
      await store.restoreBytes(legacy);
      final entries = await store.database.allEntries();
      expect(entries.length, 2);
      expect(entries.map((e) => e.id), containsAll([101, 102]));
      expect(entries.map((e) => e.amountGrosz), containsAll([2000, 125000]));
      expect(entries.first.dateEpochDay, 20724);
      expect(entries.first.customSubcategoryId, 42);
      expect(entries.last.plannedItemId, 12);
      final plan = await store.database.findMonth(YearMonth(2026, 9));
      expect(plan!.items.single.id, 12);
      expect(plan.items.single.icon, 'HOME');
      expect(
        (await store.database.select(store.database.customCategories).get())
            .single
            .id,
        41,
      );
      expect(
        (await store.database.select(store.database.customSubcategories).get())
            .single
            .id,
        42,
      );
      expect(
        (await store.database.select(store.database.monthlyReflections).get())
            .single
            .successes,
        'Test',
      );
      expect(
        await store.receiptFile(entries.first.receiptName!).readAsBytes(),
        File('test/fixtures/receipt.png').readAsBytesSync(),
      );
      expect(store.settings.bookName, 'Księga testowa');
      expect(
        store.settings.missingChoices,
        containsAll(['language', 'currency', 'theme', 'splash', 'appLock']),
      );
      await store.close();
      store = await KakeboDataStore.openAt(temp);
      expect(store.settings.currency, isNull);
      expect((await store.database.allEntries()).length, 2);
    },
  );

  test('format 2 roundtrip restores settings and repeated import replaces, never duplicates', () async {
    final original = decodeBackup(legacy);
    final settings = BackupSettings(
      bookName: original.settings.bookName,
      startTab: original.settings.startTab,
      language: 'en',
      currency: 'EUR',
      theme: 'DARK',
      splash: 'SUN',
      appLock: true,
    );
    final encoded = encodeBackup(
      ValidatedBackup(2, original.tables, original.receipts, settings),
    );
    await store.restoreBytes(encoded);
    await store.restoreBytes(encoded);
    expect(
      (await store.database.allEntries()).map((e) => e.id).toList()..sort(),
      [101, 102],
    );
    expect(store.settings.language, 'en');
    expect(store.settings.currency, 'EUR');
    expect(store.settings.theme, 'DARK');
    expect(store.settings.appLock, true);
    final roundtrip = decodeBackup(await store.exportBackup());
    expect(roundtrip.format, 2);
    expect(roundtrip.tables['entries']!.length, 2);
    expect(roundtrip.tables['planned_items']!.single['amountGrosz'], 125000);
    expect(
      roundtrip.receipts.values.single,
      File('test/fixtures/receipt.png').readAsBytesSync(),
    );
  });

  test(
    'corrupt ZIP, zip slip and invalid relations leave active bundle unchanged',
    () async {
      await store.restoreBytes(legacy);
      final active = store.activeBundle.path;
      Future<void> unchanged(Uint8List bytes) async {
        await expectLater(store.restoreBytes(bytes), throwsA(isA<Exception>()));
        expect(store.activeBundle.path, active);
        expect((await store.database.allEntries()).length, 2);
        expect(
          await store
              .receiptFile('00000000-0000-4000-8000-000000000001.img')
              .exists(),
          true,
        );
      }

      await unchanged(Uint8List.fromList([1, 2, 3]));
      final dangerous = Archive()
        ..addFile(
          ArchiveFile.bytes(
            'kakebo.json',
            utf8.encode(jsonEncode({'format': 1})),
          ),
        )
        ..addFile(ArchiveFile.bytes('../escape.img', [1, 2, 3]));
      await unchanged(ZipEncoder().encodeBytes(dangerous));
      final source = decodeBackup(legacy);
      source.tables['entries']!.last['plannedItemId'] = 999;
      final broken = Archive()
        ..addFile(
          ArchiveFile.bytes(
            'kakebo.json',
            utf8.encode(
              jsonEncode({
                'format': 1,
                'tables': source.tables,
                'profileSettings': source.settings.toJson(),
              }),
            ),
          ),
        );
      for (final item in source.receipts.entries) {
        broken.addFile(ArchiveFile.bytes('receipts/${item.key}', item.value));
      }
      await unchanged(ZipEncoder().encodeBytes(broken));
    },
  );

  test('entry size limit rejects compressed ZIP bomb before decompression', () {
    final archive = Archive()
      ..addFile(ArchiveFile.bytes('kakebo.json', utf8.encode('{}')))
      ..addFile(
        ArchiveFile.bytes(
          'receipts/00000000-0000-4000-8000-000000000001.img',
          Uint8List(25 * 1024 * 1024 + 1),
        ),
      );
    expect(
      () => decodeBackup(ZipEncoder().encodeBytes(archive)),
      throwsFormatException,
    );
  });

  test(
    'interruption and write failure before activation preserve old snapshot',
    () async {
      await store.restoreBytes(legacy);
      final active = store.activeBundle.path;
      await expectLater(
        store.restoreBytes(
          legacy,
          beforeActivation: () async {
            throw const FileSystemException('Simulated write failure');
          },
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(store.activeBundle.path, active);
      expect((await store.database.allEntries()).length, 2);
      await store.close();
      store = await KakeboDataStore.openAt(temp);
      expect(store.activeBundle.path, active);
      await store.restoreBytes(legacy);
      expect((await store.database.allEntries()).length, 2);
    },
  );

  test('legacy marker commits with data and protects later Flutter entries', () async {
    final original = decodeBackup(legacy);
    final encoded = encodeBackup(
      ValidatedBackup(
        2,
        original.tables,
        original.receipts,
        const BackupSettings(
          language: 'pl',
          currency: 'PLN',
          theme: 'SYSTEM',
          splash: 'INK',
          appLock: false,
        ),
      ),
    );
    await expectLater(
      store.restoreBytes(
        encoded,
        legacyMigrationMarker: const {'source': 'android-room'},
        beforeActivation: () async => throw const FileSystemException('cut'),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(store.hasLegacyMigrationMarker, false);
    expect(await store.hasAnyFinancialData, false);
    await store.restoreBytes(
      encoded,
      legacyMigrationMarker: const {'source': 'android-room'},
    );
    expect(store.hasLegacyMigrationMarker, true);
    await store.database.saveEntry(
      Entry(
        amountGrosz: 789,
        type: EntryType.expense,
        dateEpochDay: 20725,
      ),
    );
    await store.close();
    store = await KakeboDataStore.openAt(temp);
    expect(store.hasLegacyMigrationMarker, true);
    expect((await store.database.allEntries()).length, 3);
  });

  test(
    'plan createIfAbsent is atomic and entry watchers observe changes',
    () async {
      final month = YearMonth(2026, 10);
      final draft = MonthlyPlanWithItems(
        MonthlyPlan(month: month, savingsGrosz: 10000),
        [
          PlannedItem(
            month: month,
            type: EntryType.expense,
            title: 'Test',
            amountGrosz: 3000,
            dateEpochDay: month.firstDay.epochDay,
          ),
        ],
      );
      expect(await store.database.createIfAbsent(draft), true);
      expect(await store.database.createIfAbsent(draft), false);
      expect((await store.database.findMonth(month))!.items.length, 1);
      final first = store.database.watchEntries().first;
      expect(await first, isEmpty);
      await store.database.saveEntry(
        Entry(
          amountGrosz: 1234,
          type: EntryType.expense,
          dateEpochDay: month.firstDay.epochDay,
        ),
      );
      expect(
        (await store.database.watchEntries().first).single.amountGrosz,
        1234,
      );
    },
  );

  test(
    'plan, item, category and reflection mutations are observable',
    () async {
      final month = YearMonth(2026, 11);
      final plans = store.database.watchMonth(month).take(2).toList();
      await Future<void>.delayed(Duration.zero);
      await store.database.savePlan(
        MonthlyPlan(month: month, savingsGrosz: 500),
      );
      expect((await plans).last!.plan.savingsGrosz, 500);

      final items = store.database.watchMonth(month).take(2).toList();
      await Future<void>.delayed(Duration.zero);
      final id = await store.database.savePlannedItem(
        PlannedItem(
          month: month,
          type: EntryType.expense,
          title: 'Czynsz',
          amountGrosz: 30000,
          dateEpochDay: month.firstDay.epochDay,
        ),
      );
      expect((await items).last!.items.single.id, id);

      final categories = store.database.watchCategories().take(2).toList();
      await Future<void>.delayed(Duration.zero);
      final categoryId = await store.database.saveCategory(
        const CustomCategory(id: 0, name: 'Dom', nameKey: 'dom'),
      );
      expect((await categories).last.single.id, categoryId);
      final subcategoryId = await store.database.saveSubcategory(
        CustomSubcategory(
          id: 0,
          categoryId: categoryId,
          name: 'Inne',
          nameKey: 'inne',
        ),
      );
      expect(
        (await store.database.watchSubcategories().first).single.id,
        subcategoryId,
      );

      final reflections = store.database
          .watchReflection(month)
          .take(2)
          .toList();
      await Future<void>.delayed(Duration.zero);
      await store.database.saveReflection(
        MonthlyReflection(month: month, successes: 'Cel osiągnięty'),
      );
      expect((await reflections).last!.successes, 'Cel osiągnięty');
    },
  );
}
