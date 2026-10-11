import 'dart:io';

import 'package:flutter/services.dart';

import 'kakebo_data_store.dart';

/// The old package data directory survives an APK update with the same ID and
/// signing key. Native code creates a consistent local snapshot; Dart validates
/// it and switches the active bundle only after a complete restore.
final class LegacyAndroidMigration {
  LegacyAndroidMigration({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('pl.kakebo/legacy_upgrade');

  final MethodChannel _channel;

  Future<KakeboDataStore> openAndMigrate() async {
    final store = await KakeboDataStore.open();
    try {
      await migrate(store);
      return store;
    } catch (_) {
      await store.close();
      rethrow;
    }
  }

  Future<void> migrate(KakeboDataStore store) async {
    if (!Platform.isAndroid || store.hasLegacyMigrationMarker) return;
    final hasSource = await _channel.invokeMethod<bool>('hasLegacyDatabase');
    if (hasSource != true) return;
    // A pre-existing Flutter bundle must never be overwritten by a delayed
    // migration. It may already contain entries entered after first launch.
    if (await store.hasAnyFinancialData) {
      throw StateError('Existing Flutter data requires a manual backup first');
    }
    final result = await _channel.invokeMapMethod<String, Object?>(
      'createLegacySnapshot',
    );
    if (result == null || result['path'] is! String) {
      throw const FormatException('Legacy snapshot is unavailable');
    }
    final file = File(result['path']! as String);
    try {
      await store.restoreFile(
        file,
        legacyMigrationMarker: {
          'source': 'android-room',
          'schemaVersion': result['schemaVersion'],
          'migratedAt': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } finally {
      if (await file.exists()) await file.delete();
    }
  }
}
