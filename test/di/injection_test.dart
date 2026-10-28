import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:flutter_clean_starter/domain/repository/settings_repository.dart';
import 'package:flutter_clean_starter/domain/usecase/settings_use_cases.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(getIt.reset);

  // A smoke test of the real composition root. A dependency injectable can't
  // resolve only fails when its type is first resolved, at runtime; resolving
  // the top of each graph here catches it in CI. Every new Cubit, repository
  // and use case belongs here, or in its feature's own test (the Tasks
  // sample's: `tasks_injection_test.dart`).
  test('the real container resolves the app-wide graph', () async {
    await configureTestDependencies();

    expect(getIt<SettingsRepository>(), same(getIt<SettingsRepository>()));
    for (final resolve in <Object Function()>[
      () => getIt<WatchSettingsUseCase>(),
      () => getIt<UpdateThemeModeUseCase>(),
      () => getIt<UpdateDynamicColorUseCase>(),
      () => getIt<SettingsCubit>(),
      () => getIt<AppInfo>(),
      () => getIt<DeviceColors>(),
    ]) {
      expect(resolve(), isNotNull);
    }
  });

  test('settings are loaded before the first frame (@preResolve)', () async {
    await configureTestDependencies(
      preferences: {'settings.themeMode': 'dark'},
    );

    expect(getIt<SettingsRepository>().current.themeMode.name, 'dark');
  });
}
