import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../core/time/calendar_date.dart';
import '../domain/expense_category.dart';

const backupTables = [
  'monthly_plans',
  'custom_categories',
  'planned_items',
  'custom_subcategories',
  'entries',
  'monthly_reflections',
];
const _receiptPattern = r'^receipts/[a-f0-9-]{36}\.img$';
const maxBackupBytes = 260 * 1024 * 1024;

final class BackupSettings {
  const BackupSettings({
    this.bookName = '',
    this.startTab = 0,
    this.reminderEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.language,
    this.currency,
    this.theme,
    this.splash,
    this.appLock,
  });
  final String bookName;
  final int startTab;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  // Null means that format 1 never stored this choice. Do not infer it.
  final String? language, currency, theme, splash;
  final bool? appLock;

  BackupSettings copyWith({
    String? language,
    String? currency,
    String? theme,
    String? bookName,
  }) => BackupSettings(
    bookName: bookName ?? this.bookName,
    startTab: startTab,
    reminderEnabled: reminderEnabled,
    reminderHour: reminderHour,
    reminderMinute: reminderMinute,
    language: language ?? this.language,
    currency: currency ?? this.currency,
    theme: theme ?? this.theme,
    splash: splash,
    appLock: appLock,
  );

  List<String> get missingChoices => [
    if (language == null) 'language',
    if (currency == null) 'currency',
    if (theme == null) 'theme',
    if (splash == null) 'splash',
    if (appLock == null) 'appLock',
  ];

  Map<String, Object?> toJson() => {
    'bookName': bookName,
    'startTab': startTab,
    'reminderEnabled': reminderEnabled,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'language': language,
    'currency': currency,
    'theme': theme,
    'splash': splash,
    'appLock': appLock,
  };

  factory BackupSettings.fromJson(Object? value, int format) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Missing profile settings');
    }
    T field<T>(String key, T legacyDefault) {
      if (!value.containsKey(key) && format == 1) return legacyDefault;
      final result = value[key];
      if (result is! T) throw FormatException('Invalid setting $key');
      return result;
    }

    String? choice(String key, bool Function(String) valid) {
      if (format == 1 && value[key] == null) return null;
      final result = value[key];
      if (result is! String || !valid(result)) {
        throw FormatException('Invalid setting $key');
      }
      return result;
    }

    final settings = BackupSettings(
      bookName: field('bookName', ''),
      startTab: field('startTab', 0),
      reminderEnabled: field('reminderEnabled', false),
      reminderHour: field('reminderHour', 20),
      reminderMinute: field('reminderMinute', 0),
      language: choice('language', (v) => v == 'pl' || v == 'en'),
      currency: choice('currency', (v) => RegExp(r'^[A-Z]{3}$').hasMatch(v)),
      theme: choice('theme', (v) => ['LIGHT', 'DARK', 'SYSTEM'].contains(v)),
      splash: choice('splash', (v) => ['INK', 'SUN'].contains(v)),
      appLock: format == 1 && value['appLock'] == null
          ? null
          : field<bool>('appLock', false),
    );
    if (settings.bookName.length > 40 ||
        settings.startTab < 0 ||
        settings.startTab > 4 ||
        settings.reminderHour < 0 ||
        settings.reminderHour > 23 ||
        settings.reminderMinute < 0 ||
        settings.reminderMinute > 59) {
      throw const FormatException('Invalid profile settings');
    }
    return settings;
  }
}

final class ValidatedBackup {
  const ValidatedBackup(this.format, this.tables, this.receipts, this.settings);
  final int format;
  final Map<String, List<Map<String, Object?>>> tables;
  final Map<String, Uint8List> receipts;
  final BackupSettings settings;
}

/// Reject archive metadata before decompressing any entry. Receipt names are
/// legacy `.img` identifiers; their actual image format is checked separately.
ValidatedBackup decodeBackup(Uint8List bytes) {
  if (bytes.length > maxBackupBytes) {
    throw const FormatException('Backup too large');
  }
  // ZipDecoder may expand symbolic links while building Archive. Check the
  // central directory first, before it can allocate untrusted entry contents.
  final directory = ZipDirectory()..read(InputMemoryStream(bytes));
  final headers = directory.fileHeaders;
  if (headers.isEmpty ||
      headers.length > 10000 ||
      headers.length != directory.totalCentralDirectoryEntries ||
      headers.map((h) => h.filename).toSet().length != headers.length) {
    throw const FormatException('Invalid archive entries');
  }
  var total = 0;
  for (final header in headers) {
    final name = header.filename;
    final max = name == 'kakebo.json' ? 20 * 1024 * 1024 : 25 * 1024 * 1024;
    if (name != 'kakebo.json' && !RegExp(_receiptPattern).hasMatch(name)) {
      throw const FormatException('Unsafe archive path');
    }
    final unixMode = (header.externalFileAttributes >> 16) & 0xf000;
    if (name.endsWith('/') ||
        (header.versionMadeBy >> 8 == 3 && unixMode == 0xa000) ||
        header.generalPurposeBitFlag & 1 != 0 ||
        (header.compressionMethod != 0 && header.compressionMethod != 8)) {
      throw const FormatException('Unsafe archive entry');
    }
    if (header.file == null ||
        header.file!.uncompressedSize < 0 ||
        header.file!.uncompressedSize > max ||
        header.file!.compressedSize < 0 ||
        header.file!.compressedSize > maxBackupBytes) {
      throw const FormatException('Archive limit exceeded');
    }
    total += header.file!.uncompressedSize;
    if (total > 250 * 1024 * 1024) {
      throw const FormatException('Archive limit exceeded');
    }
  }

  final archive = ZipDecoder().decodeBytes(bytes);
  final approvedNames = headers.map((h) => h.filename).toSet();
  if (archive.length != headers.length ||
      archive.any((entry) => !approvedNames.contains(entry.name))) {
    throw const FormatException('Invalid archive entries');
  }

  Map<String, dynamic>? root;
  final receipts = <String, Uint8List>{};
  for (final entry in archive) {
    if (!entry.isFile || entry.isSymbolicLink) {
      throw const FormatException('Unsafe archive entry');
    }
    final content = entry.readBytes();
    if (content == null ||
        content.length != entry.size ||
        getCrc32(content) != entry.crc32) {
      throw const FormatException('Corrupt archive entry');
    }
    if (entry.name == 'kakebo.json') {
      final decoded = jsonDecode(utf8.decode(content));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid manifest');
      }
      root = decoded;
    } else {
      if (!_imageMimeValid(content)) {
        throw const FormatException('Invalid receipt image');
      }
      receipts[entry.name.substring('receipts/'.length)] = content;
    }
  }
  if (root == null || (root['format'] != 1 && root['format'] != 2)) {
    throw const FormatException('Unsupported backup format');
  }
  final format = root['format'] as int;
  final rawTables = root['tables'];
  if (rawTables is! Map<String, dynamic> ||
      rawTables.keys.toSet().difference(backupTables.toSet()).isNotEmpty) {
    throw const FormatException('Invalid backup tables');
  }
  final tables = <String, List<Map<String, Object?>>>{};
  for (final table in backupTables) {
    final rows = rawTables[table];
    if (rows is! List || rows.length > 100000) {
      throw FormatException('Invalid table $table');
    }
    tables[table] = rows.map((row) {
      if (row is! Map<String, dynamic>) {
        throw FormatException('Invalid row $table');
      }
      return Map<String, Object?>.from(row);
    }).toList();
  }
  final settings = BackupSettings.fromJson(root['profileSettings'], format);
  _validateRows(tables, receipts);
  return ValidatedBackup(format, tables, receipts, settings);
}

Uint8List encodeBackup(ValidatedBackup backup) {
  if (backup.settings.missingChoices.isNotEmpty) {
    throw StateError(
      'Choose missing legacy settings before exporting format 2',
    );
  }
  _validateRows(backup.tables, backup.receipts);
  final archive = Archive();
  final manifest = utf8.encode(
    jsonEncode({
      'format': 2,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'tables': backup.tables,
      'profileSettings': backup.settings.toJson(),
    }),
  );
  archive.addFile(ArchiveFile.bytes('kakebo.json', manifest));
  for (final receipt in backup.receipts.entries) {
    archive.addFile(
      ArchiveFile.bytes('receipts/${receipt.key}', receipt.value),
    );
  }
  return ZipEncoder().encodeBytes(archive);
}

bool _imageMimeValid(Uint8List b) {
  if (b.length < 12) return false;
  bool prefix(List<int> magic) =>
      List.generate(magic.length, (i) => b[i] == magic[i]).every((v) => v);
  if (prefix([0xFF, 0xD8, 0xFF]) ||
      prefix([0x89, 0x50, 0x4E, 0x47]) ||
      prefix([0x47, 0x49, 0x46, 0x38])) {
    return true;
  }
  if (ascii.decode(b.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
      ascii.decode(b.sublist(8, 12), allowInvalid: true) == 'WEBP') {
    return true;
  }
  return ascii.decode(b.sublist(4, 8), allowInvalid: true) == 'ftyp' &&
      [
        'heic',
        'heix',
        'mif1',
        'hevc',
      ].contains(ascii.decode(b.sublist(8, 12), allowInvalid: true));
}

void _validateRows(
  Map<String, List<Map<String, Object?>>> tables,
  Map<String, Uint8List> receipts,
) {
  int number(Map<String, Object?> row, String key, {bool positive = false}) {
    final n = row[key];
    if (n is! int || (positive && n <= 0)) {
      throw FormatException('Invalid $key');
    }
    return n;
  }

  String string(Map<String, Object?> row, String key, {bool nonempty = false}) {
    final s = row[key];
    if (s is! String || s.length > 10000 || (nonempty && s.trim().isEmpty)) {
      throw FormatException('Invalid $key');
    }
    return s;
  }

  int? optionalId(Map<String, Object?> row, String key) =>
      row[key] == null ? null : number(row, key, positive: true);
  final months = <String>{},
      categoryIds = <int>{},
      subcategoryIds = <int>{},
      itemIds = <int>{},
      entryIds = <int>{};
  final categoryNames = <String>{}, subcategoryNames = <String>{};
  for (final row in tables['monthly_plans']!) {
    final month = string(row, 'month');
    YearMonth.parse(month);
    if (!months.add(month) || number(row, 'savingsGrosz') < 0) {
      throw const FormatException('Duplicate/invalid month');
    }
    string(row, 'resolutions');
  }
  for (final row in tables['custom_categories']!) {
    final id = number(row, 'id', positive: true);
    final key = string(row, 'nameKey', nonempty: true);
    if (!categoryIds.add(id) || !categoryNames.add(key)) {
      throw const FormatException('Duplicate category');
    }
    string(row, 'name', nonempty: true);
    string(row, 'icon');
  }
  for (final row in tables['planned_items']!) {
    final id = number(row, 'id', positive: true), month = string(row, 'month');
    final date = CalendarDate.fromEpochDay(number(row, 'dateEpochDay'));
    if (!itemIds.add(id) ||
        !months.contains(month) ||
        date.yearMonth.toString() != month) {
      throw const FormatException('Invalid planned item relation/date');
    }
    number(row, 'amountGrosz', positive: true);
    string(row, 'title', nonempty: true);
    if (!['INCOME', 'EXPENSE'].contains(row['type'])) {
      throw const FormatException('Invalid item type');
    }
    final recurrence = row['recurrence'] ?? 'MONTHLY';
    if (!['MONTHLY', 'QUARTERLY', 'YEARLY'].contains(recurrence)) {
      throw const FormatException('Invalid recurrence');
    }
    final anchor = row['recurrenceAnchorMonth'] ?? '';
    if (anchor is! String) throw const FormatException('Invalid anchor');
    if (anchor.isNotEmpty) YearMonth.parse(anchor);
    if (row['icon'] != null) string(row, 'icon');
  }
  for (final row in tables['custom_subcategories']!) {
    final id = number(row, 'id', positive: true),
        parent = number(row, 'categoryId', positive: true);
    final key = string(row, 'nameKey', nonempty: true);
    if (!subcategoryIds.add(id) ||
        !categoryIds.contains(parent) ||
        !subcategoryNames.add('$parent/$key')) {
      throw const FormatException('Invalid subcategory relation/name');
    }
    string(row, 'name', nonempty: true);
  }
  for (final row in tables['entries']!) {
    final id = number(row, 'id', positive: true), type = string(row, 'type');
    if (!entryIds.add(id) || !['INCOME', 'EXPENSE'].contains(type)) {
      throw const FormatException('Invalid entry');
    }
    number(row, 'amountGrosz', positive: true);
    CalendarDate.fromEpochDay(number(row, 'dateEpochDay'));
    string(row, 'note');
    final item = optionalId(row, 'plannedItemId'),
        sub = optionalId(row, 'customSubcategoryId');
    if (item != null && !itemIds.contains(item) ||
        sub != null && !subcategoryIds.contains(sub)) {
      throw const FormatException('Broken entry relation');
    }
    final builtIn = row['subcategory'];
    if (builtIn != null) {
      if (builtIn is! String) {
        throw const FormatException('Invalid subcategory');
      }
      ExpenseSubcategory.fromStorageKey(builtIn);
    }
    if (builtIn != null && sub != null ||
        type == 'INCOME' &&
            (builtIn != null ||
                sub != null ||
                item != null ||
                row['receiptName'] != null)) {
      throw const FormatException('Invalid entry category');
    }
    final name = row['receiptName'];
    if (name != null &&
        (name is! String ||
            !RegExp(r'^[a-f0-9-]{36}\.img$').hasMatch(name) ||
            !receipts.containsKey(name))) {
      throw const FormatException('Missing receipt');
    }
  }
  final reflections = <String>{};
  for (final row in tables['monthly_reflections']!) {
    final month = string(row, 'month');
    YearMonth.parse(month);
    if (!reflections.add(month)) {
      throw const FormatException('Duplicate reflection');
    }
    string(row, 'successes');
    string(row, 'improvements');
    string(row, 'nextMonth');
  }
}
