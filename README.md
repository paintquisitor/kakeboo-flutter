# Kakebo Flutter

Aplikacja do prowadzenia domowego budżetu na Androida i iOS. Dane i załączniki są przechowywane lokalnie na urządzeniu. To rozwijana wersja Flutter istniejącej aplikacji Kotlin; migracja funkcji nie jest jeszcze zakończona.

## Uruchomienie

Wymagany jest Flutter 3.47.6 (Dart 3.13.5). Zależności są zapisane w `pubspec.lock`, a wersja SDK w `.flutter-version`.

```sh
flutter pub get
flutter run
```

Projekt iOS otwiera się w Xcode przez `ios/Runner.xcworkspace`. Na fizycznym iPhonie trzeba skonfigurować podpis aplikacji. Wersja rozwojowa ma identyfikator `pl.kakebo.dev`, więc nie zastępuje zainstalowanej aplikacji Kotlin `pl.kakebo` ani nie przejmuje jej danych.

```sh
flutter analyze
flutter test
```
