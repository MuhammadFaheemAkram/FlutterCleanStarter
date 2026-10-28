import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:flutter_clean_starter/domain/repository/settings_repository.dart';
import 'package:flutter_clean_starter/domain/usecase/settings_use_cases.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_state.dart';
import 'package:injectable/injectable.dart';

/// The settings, app-wide: provided *above* `MaterialApp.router`, so the
/// theme mode and dynamic color apply to every screen at once, and the
/// Settings screen reads and changes them through the same Cubit.
///
/// Every other Cubit belongs to its screen; this is the one exception,
/// because the theme is the app's, not a screen's.
///
/// It starts from the settings loaded before the first frame
/// (`@preResolve`), so the app never flashes the wrong theme.
@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    SettingsRepository settings,
    this._watchSettings,
    this._updateThemeMode,
    this._updateDynamicColor,
    DeviceColors deviceColors,
  ) : super(
        SettingsState(settings: settings.current, deviceColors: deviceColors),
      );

  final WatchSettingsUseCase _watchSettings;
  final UpdateThemeModeUseCase _updateThemeMode;
  final UpdateDynamicColorUseCase _updateDynamicColor;

  StreamSubscription<AppSettings>? _changes;

  void load() {
    _changes ??= _watchSettings().listen(
      (settings) => emit(state.copyWith(settings: settings)),
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) => _updateThemeMode(mode);

  Future<void> setDynamicColor({required bool enabled}) =>
      _updateDynamicColor(enabled: enabled);

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
