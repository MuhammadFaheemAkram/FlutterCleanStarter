import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/accessibility.dart';
import '../helpers/app_harness.dart';

// Every screen, in light and dark, with text at 200%: no layout overflows,
// tap targets of at least 48 × 48, a label on everything tappable, and
// readable text contrast. A new screen, or a new state of one, gets a case
// in its feature's tour (the Tasks sample's is
// `tasks_accessibility_tour_test.dart`).
void main() {
  tearDown(getIt.reset);

  for (final brightness in Brightness.values) {
    group('${brightness.name} theme, text at 200%', () {
      testWidgets('Settings', (tester) async {
        await openForTour(tester, brightness: brightness, at: '/settings');
        await expectAccessible(tester);
      });

      testWidgets('Settings: Android 12+, with dynamic color', (tester) async {
        await openForTour(
          tester,
          brightness: brightness,
          at: '/settings',
          wallpaperColor: 0xFF8E3B46,
        );
        expect(find.text('Dynamic color'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('Page not found', (tester) async {
        await openForTour(tester, brightness: brightness, at: '/nowhere');
        await expectAccessible(tester);
      });
    });
  }

  testWidgets('the tab labels keep their size at any text setting (a long '
      'press shows them)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pumpStarter(tester);

    final label = destination('Settings');
    final inBar = tester.element(label);
    expect(MediaQuery.textScalerOf(inBar).scale(10), 10);

    final before = find.text('Settings').evaluate().length;
    await tester.longPress(label);
    await tester.pumpAndSettle();
    // One more: the tooltip over the bar.
    expect(find.text('Settings'), findsNWidgets(before + 1));
  });
}
