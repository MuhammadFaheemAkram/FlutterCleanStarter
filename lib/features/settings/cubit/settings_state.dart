import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    required AppSettings settings,
    required DeviceColors deviceColors,
  }) = _SettingsState;

  const SettingsState._();

  /// The wallpaper's color when dynamic color is on and the device has one;
  /// otherwise `null`: the app's own teal.
  int? get dynamicSeed =>
      settings.dynamicColor ? deviceColors.wallpaperColor : null;
}
