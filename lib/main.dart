import 'package:flutter/material.dart';

import 'app/kakebo_app.dart';
import 'app/app_settings_controller.dart';
import 'data/legacy_android_migration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final store = await LegacyAndroidMigration().openAndMigrate();
    runApp(
      KakeboApp(settings: AppSettingsController(store.settings, store: store)),
    );
  } catch (_) {
    // Never launch an apparently empty ledger after a failed upgrade.
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Nie udało się bezpiecznie przenieść danych. '
                'Twoje dane w starej bazie pozostają nienaruszone. '
                'Uruchom aplikację ponownie lub przywróć kopię zapasową.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
