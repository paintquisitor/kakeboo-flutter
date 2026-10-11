import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import '../data/backup_codec.dart';
import 'app_settings_controller.dart';
import 'kakebo_shell.dart';
import 'kakebo_theme.dart';

class KakeboApp extends StatefulWidget {
  const KakeboApp({super.key, this.settings});

  final AppSettingsController? settings;

  @override
  State<KakeboApp> createState() => _KakeboAppState();
}

class _KakeboAppState extends State<KakeboApp> {
  late final AppSettingsController _settings =
      widget.settings ??
      AppSettingsController(
        const BackupSettings(language: 'pl', currency: 'PLN', theme: 'SYSTEM'),
      );

  @override
  void dispose() {
    if (widget.settings == null) _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _settings,
    builder: (context, _) {
      final settings = _settings.settings;
      return MaterialApp(
        title: 'Kakebo',
        debugShowCheckedModeBanner: false,
        locale: Locale(settings.language ?? 'pl'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: kakeboTheme(Brightness.light),
        darkTheme: kakeboTheme(Brightness.dark),
        themeMode: switch (settings.theme) {
          'LIGHT' => ThemeMode.light,
          'DARK' => ThemeMode.dark,
          _ => ThemeMode.system,
        },
        home: KakeboShell(settings: _settings),
      );
    },
  );
}
