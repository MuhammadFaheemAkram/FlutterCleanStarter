import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'app_harness.dart';

// The accessibility tour's two steps, shared by the app's tour and each
// feature's: open a screen at 200 % text in a theme, then check it.

/// Starts the app on [at] in [brightness], with text at 200 %, on a phone's
/// width but tall enough to lay out every item of a long list (the checks
/// see only what is built). The other options are [pumpStarter]'s.
Future<void> openForTour(
  WidgetTester tester, {
  required Brightness brightness,
  required String at,
  Future<void> Function()? beforeLaunch,
  bool offline = false,
  Map<String, Object> preferences = const {},
  int? wallpaperColor,
}) async {
  tester.platformDispatcher
    ..textScaleFactorTestValue = 2
    ..platformBrightnessTestValue = brightness;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await pumpStarter(
    tester,
    initialLocation: at,
    beforeLaunch: beforeLaunch,
    offline: offline,
    preferences: preferences,
    wallpaperColor: wallpaperColor,
  );
  tester.view.physicalSize = const Size(390 * 3, 6000 * 3);
  await tester.settle();
  final context = tester.element(find.byType(Scaffold).last);
  expect(MediaQuery.textScalerOf(context).scale(10), 20);
  expect(Theme.of(context).brightness, brightness);
}

/// No layout overflows (an overflow already failed the test), tap targets
/// of at least 48 × 48 ([tapTargets]), a label on everything tappable, and
/// readable text contrast.
Future<void> expectAccessible(
  WidgetTester tester, {
  bool tapTargets = true,
}) async {
  final handle = tester.ensureSemantics();
  if (tapTargets) {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  }
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}
