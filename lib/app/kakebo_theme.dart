import 'package:flutter/material.dart';

const kakeboSpacing = 16.0;

final _lightColors = const ColorScheme.light().copyWith(
  primary: const Color(0xFF247D68),
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFDFF3E9),
  onPrimaryContainer: const Color(0xFF173E33),
  secondary: const Color(0xFF52766B),
  onSecondary: Colors.white,
  secondaryContainer: const Color(0xFFE7F0EB),
  onSecondaryContainer: const Color(0xFF314C44),
  tertiary: const Color(0xFF8B6A3D),
  onTertiary: Colors.white,
  tertiaryContainer: const Color(0xFFF5E8D2),
  onTertiaryContainer: const Color(0xFF59411F),
  surface: Colors.white,
  onSurface: const Color(0xFF1F2A27),
  surfaceContainerLowest: Colors.white,
  surfaceContainerLow: const Color(0xFFFCFDF9),
  surfaceContainer: const Color(0xFFF2F5F1),
  surfaceContainerHigh: const Color(0xFFEBF0EC),
  surfaceContainerHighest: const Color(0xFFE3EAE5),
  onSurfaceVariant: const Color(0xFF63736C),
  outline: const Color(0xFF8A9992),
  outlineVariant: const Color(0xFFE2E8E2),
  error: const Color(0xFFBA514C),
  onError: Colors.white,
  errorContainer: const Color(0xFFFCE8E5),
  onErrorContainer: const Color(0xFF702D2A),
  inverseSurface: const Color(0xFF29322F),
  onInverseSurface: const Color(0xFFF0F3EF),
  inversePrimary: const Color(0xFF98D8BE),
  scrim: const Color(0xFF101713),
);

final _darkColors = const ColorScheme.dark().copyWith(
  primary: const Color(0xFF98D8BE),
  onPrimary: const Color(0xFF133A2F),
  primaryContainer: const Color(0xFFA8DBC7),
  onPrimaryContainer: const Color(0xFF17382D),
  secondary: const Color(0xFFB8CCC4),
  onSecondary: const Color(0xFF233833),
  secondaryContainer: const Color(0xFF30413E),
  onSecondaryContainer: const Color(0xFFD7E8E1),
  tertiary: const Color(0xFFD3B27C),
  onTertiary: const Color(0xFF433218),
  tertiaryContainer: const Color(0xFF51442E),
  onTertiaryContainer: const Color(0xFFF1D7A8),
  surface: const Color(0xFF202A2D),
  onSurface: const Color(0xFFF0F3EE),
  surfaceContainerLowest: const Color(0xFF101719),
  surfaceContainerLow: const Color(0xFF1B2427),
  surfaceContainer: const Color(0xFF202A2D),
  surfaceContainerHigh: const Color(0xFF293538),
  surfaceContainerHighest: const Color(0xFF314044),
  onSurfaceVariant: const Color(0xFFADBDB6),
  outline: const Color(0xFF7E918A),
  outlineVariant: const Color(0xFF344145),
  error: const Color(0xFFF09C91),
  onError: const Color(0xFF591714),
  errorContainer: const Color(0xFF5A2927),
  onErrorContainer: const Color(0xFFFFDAD5),
  inverseSurface: const Color(0xFFE3EAE5),
  onInverseSurface: const Color(0xFF25302D),
  inversePrimary: const Color(0xFF247D68),
  scrim: Colors.black,
);

ThemeData kakeboTheme(Brightness brightness) {
  final scheme = brightness == Brightness.dark ? _darkColors : _lightColors;
  const typography = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.8,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    titleLarge: TextStyle(
      fontSize: 19,
      height: 25 / 19,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 21 / 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 22 / 16),
    bodyMedium: TextStyle(fontSize: 14, height: 19 / 14),
    bodySmall: TextStyle(fontSize: 12, height: 16 / 12),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
    ),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF141B1D)
        : const Color(0xFFF7F8F4),
    textTheme: typography,
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  );
}
