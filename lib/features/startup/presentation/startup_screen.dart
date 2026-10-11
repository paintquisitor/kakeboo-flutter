import 'package:flutter/material.dart';

/// Temporary entry point while the existing Kakebo features are migrated.
class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Kakebo', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    'Księga domowych rachunków',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Wersja deweloperska',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Przygotowujemy wspólną aplikację na Androida i iOS. '
                    'Twoje dane pozostają w dotychczasowej aplikacji.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
