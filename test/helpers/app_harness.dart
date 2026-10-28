import 'package:flutter_clean_starter/app/starter_app.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/network/network_simulator.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'pump_app.dart';
import 'test_dependencies.dart';

/// Starts the whole app on the real DI graph (with the swaps of
/// [configureTestDependencies]), optionally on a deep link, and waits until
/// no loading screen is left. Pair it with `tearDown(getIt.reset)`.
///
/// - [beforeLaunch] runs once the graph exists and before the first frame,
///   on the real event loop (to store data the app should start with).
/// - [offline]: every request to the fake server fails, from the first
///   frame.
/// - [preferences] adds saved settings (raw keys).
/// - [wallpaperColor]: an Android 12+ device with that wallpaper color.
Future<void> pumpStarter(
  WidgetTester tester, {
  String? initialLocation,
  Future<void> Function()? beforeLaunch,
  bool offline = false,
  Map<String, Object> preferences = const {},
  int? wallpaperColor,
}) async {
  await configureTestDependencies(
    preferences: preferences,
    wallpaperColor: wallpaperColor,
  );
  if (beforeLaunch != null) {
    // On the real event loop: before the first pump nothing advances the
    // widget test's fake time, and the database works on the real loop
    // (conventions §11.44).
    await tester.runAsync(beforeLaunch);
  }
  getIt<NetworkSimulator>().failRequests = offline;
  tester.usePhoneSurface();
  await tester.pumpWidget(StarterApp(initialLocation: initialLocation));
  await tester.settle();
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
    await settle();
  }

  /// `pumpAndSettle` that also waits out a loading screen: a screen that
  /// opens (Tasks) reads the database on the real event loop, and its
  /// spinner would never let `pumpAndSettle` finish.
  Future<void> settle() => settleUntilGone(find.byType(LoadingView));

  /// Taps [finder], then lets the database work it started finish.
  Future<void> tapAndSettleData(Finder finder) async {
    await tap(finder);
    await settleRealAsync();
  }

  /// Lets work that runs on the real event loop finish (a database write
  /// started by a tap), then settles.
  Future<void> settleRealAsync() async {
    await runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await settle();
  }

  /// Settles real-loop work in slices until [finder] finds something (a
  /// flow that alternates fake-time pumps and database work needs several,
  /// conventions §11.54), failing after [attempts] slices instead of
  /// hanging.
  Future<void> pumpUntilFound(Finder finder, {int attempts = 30}) async {
    for (var i = 0; i < attempts; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await settleRealAsync();
    }
    expect(finder, findsWidgets, reason: 'never appeared');
  }

  /// Pumps frame by frame, giving the real event loop (the database) time
  /// while [finder] finds something, until it finds nothing and no frame is
  /// scheduled (animations done). Not `pumpAndSettle`: what is waited out
  /// is often a spinner, which never settles.
  Future<void> settleUntilGone(Finder finder, {int attempts = 100}) async {
    for (var i = 0; i < attempts; i++) {
      await pump(const Duration(milliseconds: 100));
      final present = finder.evaluate().isNotEmpty;
      if (!present && !binding.hasScheduledFrame) return;
      if (present) {
        await runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
      }
    }
    expect(finder, findsNothing, reason: 'never went away');
  }
}
