import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/app/app_settings_controller.dart';
import 'package:kakebo/data/kakebo_data_store.dart';

void main() {
  test('settings persist in the active local bundle and reopen without touching financial data', () async {
    final root = await Directory.systemTemp.createTemp('kakebo-settings-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final store = await KakeboDataStore.openAt(root);
    final controller = AppSettingsController(store.settings, store: store);
    await controller.update(language: 'en', currency: 'USD', theme: 'DARK');
    expect(store.settings.language, 'en');
    await store.close();
    controller.dispose();

    final reopened = await KakeboDataStore.openAt(root);
    addTearDown(reopened.close);
    expect(reopened.settings.language, 'en');
    expect(reopened.settings.currency, 'USD');
    expect(reopened.settings.theme, 'DARK');
    expect(await reopened.hasAnyFinancialData, isFalse);
  });
}
