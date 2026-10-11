import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/app/kakebo_app.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Starts in $brightness with large text on a small screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await tester.pumpWidget(const KakeboApp());
      await tester.pumpAndSettle();

      expect(find.text('kakebo'), findsOneWidget);
      expect(find.text('Plan miesiąca'), findsOneWidget);
      expect(find.text('Wersja deweloperska'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.text('kakebo'))).brightness,
        brightness,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
