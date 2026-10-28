import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/usecase/settings_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_settings_repository.dart';

void main() {
  test('each settings use case changes its own setting', () async {
    final settings = FakeSettingsRepository();

    await UpdateThemeModeUseCase(settings)(AppThemeMode.dark);
    await UpdateDynamicColorUseCase(settings)(enabled: false);

    expect(
      settings.current,
      const AppSettings(themeMode: AppThemeMode.dark, dynamicColor: false),
    );
    expect(await WatchSettingsUseCase(settings)().first, settings.current);
  });
}
