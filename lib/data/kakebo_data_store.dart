import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'backup_codec.dart';
import 'kakebo_database.dart';

const _columns = <String, List<String>>{
  'monthly_plans': ['month', 'savingsGrosz', 'resolutions'],
  'custom_categories': ['id', 'name', 'nameKey', 'icon'],
  'planned_items': [
    'id',
    'month',
    'type',
    'title',
    'amountGrosz',
    'dateEpochDay',
    'recurrence',
    'recurrenceAnchorMonth',
    'icon',
  ],
  'custom_subcategories': ['id', 'categoryId', 'name', 'nameKey'],
  'entries': [
    'id',
    'amountGrosz',
    'type',
    'dateEpochDay',
    'note',
    'subcategory',
    'plannedItemId',
    'receiptName',
    'customSubcategoryId',
  ],
  'monthly_reflections': ['month', 'successes', 'improvements', 'nextMonth'],
};

/// A complete snapshot is one directory: SQLite, settings and receipts. Only
/// the small active-pointer file changes during activation, via atomic rename.
/// Old bundles are retained so an interrupted import never destroys them.
final class KakeboDataStore {
  KakeboDataStore._(this.root, this._bundleName, this.database, this.settings);

  final Directory root;
  String _bundleName;
  KakeboDatabase database;
  BackupSettings settings;
  bool _busy = false;

  Directory get activeBundle => Directory('${root.path}/$_bundleName');
  Directory get receiptsDirectory => Directory('${activeBundle.path}/receipts');
  bool get hasLegacyMigrationMarker =>
      File('${activeBundle.path}/legacy-android.json').existsSync();

  Future<void> saveSettings(BackupSettings next) async {
    if (_busy) throw StateError('Another backup operation is active');
    final file = File('${activeBundle.path}/settings.json');
    final existing = jsonDecode(await file.readAsString());
    if (existing is! Map<String, dynamic>) {
      throw const FormatException('Invalid settings file');
    }
    final temp = File(
      '${activeBundle.path}/.settings-${DateTime.now().microsecondsSinceEpoch}',
    );
    try {
      await temp.writeAsString(
        jsonEncode({...existing, ...next.toJson()}),
        flush: true,
      );
      await temp.rename(file.path);
      settings = next;
    } finally {
      if (await temp.exists()) await temp.delete();
    }
  }

  Future<bool> get hasAnyFinancialData async {
    for (final table in backupTables) {
      if ((await database.customSelect('SELECT 1 FROM $table LIMIT 1').get())
          .isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  static Future<KakeboDataStore> open() async {
    final base = await getApplicationSupportDirectory();
    return openAt(Directory('${base.path}/kakebo'));
  }

  static Future<KakeboDataStore> openAt(Directory root) async {
    await root.create(recursive: true);
    final pointer = File('${root.path}/active.txt');
    String name;
    if (await pointer.exists()) {
      name = (await pointer.readAsString()).trim();
      if (!RegExp(r'^bundle-[a-zA-Z0-9-]+$').hasMatch(name)) {
        throw const FormatException('Invalid active bundle pointer');
      }
    } else {
      name = 'bundle-initial';
      final initial = Directory('${root.path}/$name');
      await initial.create(recursive: true);
      await Directory('${initial.path}/receipts').create();
      await File('${initial.path}/settings.json').writeAsString(
        jsonEncode(
          const BackupSettings(
            language: 'pl',
            currency: 'PLN',
            theme: 'SYSTEM',
            splash: 'INK',
            appLock: false,
          ).toJson(),
        ),
        flush: true,
      );
      final initialDb = KakeboDatabase(
        NativeDatabase(File('${initial.path}/kakebo.sqlite')),
      );
      await initialDb.customSelect('SELECT 1').get();
      await initialDb.close();
      final pointerTemp = File('${root.path}/.active-initial');
      await pointerTemp.writeAsString(name, flush: true);
      await pointerTemp.rename(pointer.path);
    }
    final bundle = Directory('${root.path}/$name');
    if (!await bundle.exists()) {
      throw const FormatException('Missing active bundle');
    }
    final settingsFile = File('${bundle.path}/settings.json');
    final decoded = jsonDecode(await settingsFile.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid settings file');
    }
    final settings = BackupSettings.fromJson(
      decoded,
      decoded['backupFormat'] == 1 ? 1 : 2,
    );
    final dbFile = File('${bundle.path}/kakebo.sqlite');
    if (!await dbFile.exists()) {
      throw const FormatException('Missing active database');
    }
    final db = KakeboDatabase(NativeDatabase(dbFile));
    await db.customSelect('SELECT 1').get();
    return KakeboDataStore._(root, name, db, settings);
  }

  File receiptFile(String name) {
    if (!RegExp(r'^[a-f0-9-]{36}\.img$').hasMatch(name)) {
      throw const FormatException('Invalid receipt filename');
    }
    return File('${receiptsDirectory.path}/$name');
  }

  Future<Uint8List> exportBackup() async {
    if (_busy) throw StateError('Another backup operation is active');
    _busy = true;
    try {
      final tables = <String, List<Map<String, Object?>>>{};
      await database.transaction(() async {
        for (final name in backupTables) {
          tables[name] =
              (await database.customSelect('SELECT * FROM $name').get())
                  .map((row) => Map<String, Object?>.from(row.data))
                  .toList();
        }
      });
      final receipts = <String, Uint8List>{};
      if (await receiptsDirectory.exists()) {
        await for (final item in receiptsDirectory.list()) {
          if (item is File) {
            receipts[item.uri.pathSegments.last] = await item.readAsBytes();
          }
        }
      }
      return encodeBackup(ValidatedBackup(2, tables, receipts, settings));
    } finally {
      _busy = false;
    }
  }

  Future<void> restoreFile(
    File file, {
    Future<void> Function()? beforeActivation,
    Map<String, Object?>? legacyMigrationMarker,
  }) async {
    if (await file.length() > maxBackupBytes) {
      throw const FormatException('Backup too large');
    }
    await restoreBytes(
      await file.readAsBytes(),
      beforeActivation: beforeActivation,
      legacyMigrationMarker: legacyMigrationMarker,
    );
  }

  Future<void> restoreBytes(
    Uint8List bytes, {
    Future<void> Function()? beforeActivation,
    Map<String, Object?>? legacyMigrationMarker,
  }) async {
    if (_busy) throw StateError('Another backup operation is active');
    _busy = true;
    Directory? stage;
    try {
      final backup = decodeBackup(bytes);
      final suffix =
          '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
      stage = Directory('${root.path}/.stage-$suffix');
      await stage.create();
      final receiptDir = Directory('${stage.path}/receipts');
      await receiptDir.create();
      for (final receipt in backup.receipts.entries) {
        await File('${receiptDir.path}/${receipt.key}')
            .writeAsBytes(receipt.value, flush: true);
      }
      await File('${stage.path}/settings.json').writeAsString(
        jsonEncode({
          ...backup.settings.toJson(),
          'backupFormat': backup.format,
        }),
        flush: true,
      );
      if (legacyMigrationMarker != null) {
        await File('${stage.path}/legacy-android.json')
            .writeAsString(jsonEncode(legacyMigrationMarker), flush: true);
      }
      final stagedDb = KakeboDatabase(
        NativeDatabase(File('${stage.path}/kakebo.sqlite')),
      );
      try {
        await stagedDb.transaction(() async {
          for (final name in backupTables) {
            final cols = _columns[name]!;
            for (final row in backup.tables[name]!) {
              final values = cols.map((column) {
                if (column == 'recurrence' && row[column] == null) {
                  return 'MONTHLY';
                }
                if (column == 'recurrenceAnchorMonth' &&
                    (row[column] == null || row[column] == '')) {
                  return row['month'];
                }
                if (column == 'icon' && row[column] == null) {
                  return name == 'custom_categories' ? 'WALLET' : '';
                }
                return row[column];
              }).toList();
              await stagedDb.customStatement(
                'INSERT INTO $name (${cols.join(',')}) VALUES (${List.filled(cols.length, '?').join(',')})',
                values,
              );
            }
          }
        });
        final integrity = await stagedDb
            .customSelect('PRAGMA integrity_check')
            .getSingle();
        if (integrity.data.values.single != 'ok') {
          throw const FormatException('SQLite integrity failure');
        }
        final keys = await stagedDb
            .customSelect('PRAGMA foreign_key_check')
            .get();
        if (keys.isNotEmpty) {
          throw const FormatException('SQLite relation failure');
        }
      } finally {
        await stagedDb.close();
      }
      if (beforeActivation != null) await beforeActivation();
      final name = 'bundle-$suffix';
      final published = await stage.rename('${root.path}/$name');
      stage = null;
      final pointerTemp = File('${root.path}/.active-$suffix');
      await pointerTemp.writeAsString(name, flush: true);
      // The destination is inside the same directory/filesystem.
      await pointerTemp.rename('${root.path}/active.txt');
      final next = KakeboDatabase(
        NativeDatabase(File('${published.path}/kakebo.sqlite')),
      );
      await next.customSelect('SELECT 1').get();
      final previous = database;
      database = next;
      settings = backup.settings;
      _bundleName = name;
      await previous.close();
    } finally {
      if (stage != null && await stage.exists()) {
        await stage.delete(recursive: true);
      }
      _busy = false;
    }
  }

  Future<void> close() => database.close();
}
