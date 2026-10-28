import 'package:flutter_clean_starter/app/starter_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'pump_app.dart';
import 'test_dependencies.dart';

/// Starts the whole app on the real DI graph (with the swaps of
/// [configureTestDependencies]), optionally on a deep link. Pair it with
/// `tearDown(getIt.reset)`.
Future<void> pumpStarter(
  WidgetTester tester, {
  String? initialLocation,
  Map<String, Object> preferences = const {},
}) async {
  await configureTestDependencies(preferences: preferences);
  tester.usePhoneSurface();
  await tester.pumpWidget(StarterApp(initialLocation: initialLocation));
  await tester.pumpAndSettle();
}

/// The bottom bar's destination labelled [label] (a tab).
Finder destination(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// The app bar showing [title]: which screen is on top.
Finder appBarTitled(String title) => find.widgetWithText(AppBar, title);

extension AppHarness on WidgetTester {
  /// The index of the selected tab.
  int get selectedTab =>
      widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}
