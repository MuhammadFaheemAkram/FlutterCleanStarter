import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:flutter_clean_starter/domain/usecase/settings_use_cases.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository settings;
  late SettingsCubit cubit;

  SettingsCubit newCubit({int? wallpaper}) => SettingsCubit(
    settings,
    WatchSettingsUseCase(settings),
    UpdateThemeModeUseCase(settings),
    UpdateDynamicColorUseCase(settings),
    DeviceColors(wallpaperColor: wallpaper),
  );

  setUp(() {
    settings = FakeSettingsRepository(
      const AppSettings(themeMode: AppThemeMode.dark),
    );
    cubit = newCubit()..load();
  });

  tearDown(() => cubit.close());

  test('starts from the stored settings: no flash of the default theme', () {
    expect(newCubit().state.settings.themeMode, AppThemeMode.dark);
  });

  test('a theme mode is saved, and the state follows', () async {
    await cubit.setThemeMode(AppThemeMode.light);
    await pumpEventQueue();

    expect(settings.current.themeMode, AppThemeMode.light);
    expect(cubit.state.settings.themeMode, AppThemeMode.light);
  });

  test('dynamic color is saved, and the state follows', () async {
    await cubit.setDynamicColor(enabled: false);
    await pumpEventQueue();

    expect(settings.current.dynamicColor, isFalse);
    expect(cubit.state.settings.dynamicColor, isFalse);
  });

  test('a change made elsewhere reaches the app', () async {
    await settings.update((s) => s.copyWith(themeMode: AppThemeMode.system));
    await pumpEventQueue();

    expect(cubit.state.settings.themeMode, AppThemeMode.system);
  });

  group('dynamicSeed', () {
    const wallpaper = 0xFF3366CC;

    test("the wallpaper's color when on and the device has one", () {
      expect(
        const SettingsState(
          settings: AppSettings(),
          deviceColors: DeviceColors(wallpaperColor: wallpaper),
        ).dynamicSeed,
        wallpaper,
      );
    });

    test('none when switched off', () {
      expect(
        const SettingsState(
          settings: AppSettings(dynamicColor: false),
          deviceColors: DeviceColors(wallpaperColor: wallpaper),
        ).dynamicSeed,
        isNull,
      );
    });

    test('none where the device has no wallpaper colors (iOS)', () {
      expect(
        const SettingsState(
          settings: AppSettings(),
          deviceColors: DeviceColors(),
        ).dynamicSeed,
        isNull,
      );
    });
  });
}
