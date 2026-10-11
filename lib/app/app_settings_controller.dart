import 'package:flutter/foundation.dart';

import '../data/backup_codec.dart';
import '../data/kakebo_data_store.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController(this._settings, {this.store});

  BackupSettings _settings;
  final KakeboDataStore? store;
  bool _saving = false;

  BackupSettings get settings => _settings;
  bool get saving => _saving;

  Future<void> update({
    String? language,
    String? currency,
    String? theme,
    String? bookName,
  }) async {
    if (_saving) return;
    final next = _settings.copyWith(
      language: language,
      currency: currency,
      theme: theme,
      bookName: bookName,
    );
    _saving = true;
    notifyListeners();
    try {
      await store?.saveSettings(next);
      _settings = next;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
