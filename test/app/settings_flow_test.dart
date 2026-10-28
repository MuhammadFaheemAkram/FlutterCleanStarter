import 'package:flutter_clean_starter/app/starter_app.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/storage/settings_local_data_source.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/features/shell/main_shell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_dependencies.dart';

// Settings on the real DI graph: the theme app-wide and from the first
// frame, dynamic color, About. (Reset demo data is the Tasks sample's:
// `tasks_demo_flow_test.dart`.)
void main() {
  tearDown(getIt.reset);

  const wallpaper = 0xFF8E3B46;

  /// The theme the screen on top is drawn with.
  ThemeData themeOnTop(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(AppBar).last));

  Future<void> openSettings(WidgetTester tester) =>
      tester.tapAndSettle(destination('Settings'));

  testWidgets('Dark applies to every screen at once, and is saved', (
    tester,
  ) async {
    await pumpStarter(tester);
    expect(themeOnTop(tester).brightness, Brightness.light);

    await openSettings(tester);
    await tester.tap(find.text('Dark'));
    await tester.settleRealAsync();
    expect(themeOnTop(tester).brightness, Brightness.dark);

    await tester.tapAndSettle(destination(AppTab.values.first.label));
    expect(themeOnTop(tester).brightness, Brightness.dark);

    expect(
      getIt<SettingsLocalDataSource>().getString(
        SettingsLocalDataSource.themeModeKey,
      ),
      'dark',
    );
  });

  testWidgets('a saved Dark is there from the very first frame', (
    tester,
  ) async {
    await configureTestDependencies(
      preferences: {SettingsLocalDataSource.themeModeKey: 'dark'},
    );
    tester.usePhoneSurface();

    await tester.pumpWidget(const StarterApp());

    expect(themeOnTop(tester).brightness, Brightness.dark);
    await tester.settle();
  });

  testWidgets('Light wins over a dark device; System follows it', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pumpStarter(tester, initialLocation: '/settings');
    expect(themeOnTop(tester).brightness, Brightness.dark);

    await tester.tap(find.text('Light'));
    await tester.settleRealAsync();
    expect(themeOnTop(tester).brightness, Brightness.light);

    await tester.tap(find.text('System'));
    await tester.settleRealAsync();
    expect(themeOnTop(tester).brightness, Brightness.dark);
  });

  group('dynamic color', () {
    testWidgets("Android 12+: on by default, in the wallpaper's colors", (
      tester,
    ) async {
      await pumpStarter(
        tester,
        initialLocation: '/settings',
        wallpaperColor: wallpaper,
      );

      expect(
        themeOnTop(tester).colorScheme.primary,
        AppTheme.fromSeed(
          const Color(wallpaper),
          Brightness.light,
        ).colorScheme.primary,
      );
      expect(
        themeOnTop(tester).colorScheme.primary,
        isNot(AppTheme.light().colorScheme.primary),
      );
    });

    testWidgets('dark too follows the wallpaper', (tester) async {
      await pumpStarter(
        tester,
        initialLocation: '/settings',
        wallpaperColor: wallpaper,
        preferences: {SettingsLocalDataSource.themeModeKey: 'dark'},
      );

      expect(themeOnTop(tester).brightness, Brightness.dark);
      expect(
        themeOnTop(tester).colorScheme.primary,
        AppTheme.fromSeed(
          const Color(wallpaper),
          Brightness.dark,
        ).colorScheme.primary,
      );
    });

    testWidgets("switched off: the app's own colors", (tester) async {
      await pumpStarter(
        tester,
        initialLocation: '/settings',
        wallpaperColor: wallpaper,
      );

      await tester.tap(find.text('Dynamic color'));
      await tester.settleRealAsync();

      expect(
        themeOnTop(tester).colorScheme.primary,
        AppTheme.light().colorScheme.primary,
      );
      expect(
        getIt<SettingsLocalDataSource>().getBool(
          SettingsLocalDataSource.dynamicColorKey,
        ),
        isFalse,
      );
    });

    testWidgets('no wallpaper colors: no switch, the own colors', (
      tester,
    ) async {
      await pumpStarter(tester, initialLocation: '/settings');

      expect(find.text('Dynamic color'), findsNothing);
      expect(
        themeOnTop(tester).colorScheme.primary,
        AppTheme.light().colorScheme.primary,
      );
    });
  });

  testWidgets("About: the app's name and version", (tester) async {
    await pumpStarter(tester, initialLocation: '/settings');

    expect(find.text('Clean Starter'), findsOneWidget);
    expect(find.text('Version 1.0.0 (1)'), findsOneWidget);
  });
}
