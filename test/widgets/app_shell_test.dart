import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/app/app_settings_controller.dart';
import 'package:kakebo/app/hero_icon.dart';
import 'package:kakebo/app/kakebo_app.dart';
import 'package:kakebo/core/format/kakebo_format.dart';
import 'package:kakebo/data/backup_codec.dart';

void main() {
  testWidgets(
    'five tabs retain icons and labels on a small screen with keyboard and large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.viewPadding = const FakeViewPadding(bottom: 24);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await tester.pumpWidget(const KakeboApp());
      await tester.pumpAndSettle();
      for (var index = 0; index < 5; index++) {
        expect(find.byKey(Key('tab_$index')), findsOneWidget);
      }
      expect(find.byType(HeroIcon), findsAtLeastNWidgets(6));
      await tester.tap(find.byKey(const Key('tab_4')));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pumpAndSettle();
      for (var index = 0; index < 5; index++) {
        final tab = find.byKey(Key('tab_$index'));
        expect(tab, findsOneWidget);
        expect(tester.getBottomRight(tab).dy, lessThanOrEqualTo(568));
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'PL/EN, theme and currency respond to settings without converting amount',
    (tester) async {
      final settings = AppSettingsController(
        const BackupSettings(language: 'pl', currency: 'PLN', theme: 'LIGHT'),
      );
      addTearDown(settings.dispose);
      await tester.pumpWidget(KakeboApp(settings: settings));
      await tester.pumpAndSettle();
      expect(find.text('Plan miesiąca'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.text('kakebo'))).brightness,
        Brightness.light,
      );
      await tester.tap(find.byKey(const Key('tab_4')));
      await tester.pumpAndSettle();
      final plAmount = tester
          .widget<Text>(find.byKey(const Key('formatted_amount')))
          .data!;
      expect(plAmount, contains('1 234,56'));

      await settings.update(language: 'en', currency: 'USD', theme: 'DARK');
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsWidgets);
      expect(
        Theme.of(tester.element(find.text('kakebo'))).brightness,
        Brightness.dark,
      );
      final enAmount = tester
          .widget<Text>(find.byKey(const Key('formatted_amount')))
          .data!;
      expect(enAmount, contains('1,234.56'));
      expect(enAmount, contains(r'$'));
      expect(enAmount, isNot(plAmount));
      expect(
        formatMoney(123456, currencyCode: 'USD', locale: const Locale('en')),
        contains('1,234.56'),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
