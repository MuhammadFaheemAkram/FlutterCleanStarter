import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/repository/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// The settings now, then every change.
@injectable
class WatchSettingsUseCase {
  const WatchSettingsUseCase(this._settings);

  final SettingsRepository _settings;

  Stream<AppSettings> call() => _settings.watch();
}

@injectable
class UpdateThemeModeUseCase {
  const UpdateThemeModeUseCase(this._settings);

  final SettingsRepository _settings;

  Future<void> call(AppThemeMode mode) =>
      _settings.update((s) => s.copyWith(themeMode: mode));
}

@injectable
class UpdateDynamicColorUseCase {
  const UpdateDynamicColorUseCase(this._settings);

  final SettingsRepository _settings;

  Future<void> call({required bool enabled}) =>
      _settings.update((s) => s.copyWith(dynamicColor: enabled));
}
