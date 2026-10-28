import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_state.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_cubit.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_state.dart';
import 'package:flutter_clean_starter/features/settings/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class _MockTasksDemoCubit extends MockCubit<TasksDemoState>
    implements TasksDemoCubit {}

void main() {
  late _MockSettingsCubit settings;
  late _MockTasksDemoCubit demo;

  setUpAll(() => registerFallbackValue(AppThemeMode.system));

  setUp(() {
    settings = _MockSettingsCubit();
    demo = _MockTasksDemoCubit();
    when(() => settings.setThemeMode(any())).thenAnswer((_) async {});
    when(() => settings.setDynamicColor(enabled: any(named: 'enabled')))
        .thenAnswer((_) async {});
    when(() => demo.reset()).thenAnswer((_) async {});
  });

  Future<void> pumpView(
    WidgetTester tester, {
    AppSettings appSettings = const AppSettings(),
    DeviceColors deviceColors = const DeviceColors(),
    TasksDemoState demoState = const TasksDemoState(),
    Stream<TasksDemoState>? demoThen,
  }) async {
    when(() => settings.state).thenReturn(
      SettingsState(settings: appSettings, deviceColors: deviceColors),
    );
    if (demoThen != null) {
      whenListen(demo, demoThen, initialState: demoState);
    } else {
      when(() => demo.state).thenReturn(demoState);
    }
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>.value(value: settings),
            BlocProvider<TasksDemoCubit>.value(value: demo),
          ],
          child: const SettingsView(
            appInfo: AppInfo(
              name: 'Clean Starter',
              version: '1.0.0',
              buildNumber: '7',
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('appearance: three segments, the current one selected', (
    tester,
  ) async {
    await pumpView(
      tester,
      appSettings: const AppSettings(themeMode: AppThemeMode.dark),
    );

    final button = tester.widget<SegmentedButton<AppThemeMode>>(
      find.byType(SegmentedButton<AppThemeMode>),
    );
    expect(button.selected, {AppThemeMode.dark});
    await tester.tap(find.text('Light'));
    verify(() => settings.setThemeMode(AppThemeMode.light)).called(1);
  });

  testWidgets('at large text: a radio list, every label whole', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pumpView(tester);

    expect(find.byType(SegmentedButton<AppThemeMode>), findsNothing);
    expect(find.byType(RadioListTile<AppThemeMode>), findsNWidgets(3));
    await tester.tap(find.text('Dark'));
    verify(() => settings.setThemeMode(AppThemeMode.dark)).called(1);
  });

  testWidgets('no wallpaper colors (iOS, older Android): no dynamic color '
      'switch', (tester) async {
    await pumpView(tester);
    expect(find.text('Dynamic color'), findsNothing);
  });

  testWidgets('Android 12+: the dynamic color switch', (tester) async {
    await pumpView(
      tester,
      deviceColors: const DeviceColors(wallpaperColor: 0xFF3366CC),
    );

    expect(find.text('Dynamic color'), findsOneWidget);
    await tester.tap(find.text('Dynamic color'));
    verify(() => settings.setDynamicColor(enabled: false)).called(1);
  });

  testWidgets('Reset demo data asks first; Cancel keeps everything', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text('Reset demo data'));
    await tester.pumpAndSettle();
    expect(find.text('Reset demo data?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => demo.reset());
  });

  testWidgets('Reset demo data, confirmed, resets', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text('Reset demo data'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await tester.pumpAndSettle();

    verify(() => demo.reset()).called(1);
  });

  testWidgets('while resetting: busy, and the row is off', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpView(tester, demoState: const TasksDemoState(resetting: true));

    expect(find.bySemanticsLabel(RegExp('Resetting')), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Reset demo data'))
          .enabled,
      isFalse,
    );
    handle.dispose();
  });

  testWidgets("the reset's outcome shows in a SnackBar", (tester) async {
    await pumpView(
      tester,
      demoThen: Stream.value(
        const TasksDemoState(
          message: 'Demo data restored: 5 tasks.',
          messageSerial: 1,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Demo data restored: 5 tasks.'), findsOneWidget);
  });

  testWidgets("About: the app's name and version", (tester) async {
    await pumpView(tester);

    expect(find.text('Clean Starter'), findsOneWidget);
    expect(find.text('Version 1.0.0 (7)'), findsOneWidget);
    expect(find.textContaining('A starter template'), findsOneWidget);
  });
}
