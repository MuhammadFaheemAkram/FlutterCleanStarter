import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_state.dart';
import 'package:flutter_clean_starter/features/settings/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

void main() {
  late _MockSettingsCubit settings;

  setUpAll(() => registerFallbackValue(AppThemeMode.system));

  setUp(() {
    settings = _MockSettingsCubit();
    when(() => settings.setThemeMode(any())).thenAnswer((_) async {});
    when(() => settings.setDynamicColor(enabled: any(named: 'enabled')))
        .thenAnswer((_) async {});
  });

  Future<void> pumpView(
    WidgetTester tester, {
    AppSettings appSettings = const AppSettings(),
    DeviceColors deviceColors = const DeviceColors(),
  }) async {
    when(() => settings.state).thenReturn(
      SettingsState(settings: appSettings, deviceColors: deviceColors),
    );
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<SettingsCubit>.value(
          value: settings,
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

  testWidgets("About: the app's name and version", (tester) async {
    await pumpView(tester);

    expect(find.text('Clean Starter'), findsOneWidget);
    expect(find.text('Version 1.0.0 (7)'), findsOneWidget);
    expect(find.textContaining('A starter template'), findsOneWidget);
  });

  testWidgets("a feature's section shows between Appearance and About", (
    tester,
  ) async {
    when(() => settings.state).thenReturn(
      const SettingsState(
        settings: AppSettings(),
        deviceColors: DeviceColors(),
      ),
    );
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<SettingsCubit>.value(
          value: settings,
          child: const SettingsView(
            appInfo: AppInfo(name: 'A', version: '1', buildNumber: ''),
            dataSection: Text('My data'),
          ),
        ),
      ),
    );

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('Appearance'), lessThan(top('My data')));
    expect(top('My data'), lessThan(top('About')));
  });
}
