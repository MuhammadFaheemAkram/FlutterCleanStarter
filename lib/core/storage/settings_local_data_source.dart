import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the raw preference values. The keys live here and
/// nowhere else.
///
/// Preferences belong in `shared_preferences`: small, non-secret values the
/// device owns. Records (tasks) live in drift.
///
/// It is backed by `SharedPreferencesWithCache`, created once before `runApp`
/// (`@preResolve` in `AppModule`): reads are synchronous afterwards, and
/// writes update the cache at once and the disk asynchronously.
@lazySingleton
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._preferences);

  static const themeModeKey = 'settings.themeMode';
  static const dynamicColorKey = 'settings.dynamicColor';

  /// The keys this class reads and writes. The cache loads, and allows
  /// writing, only the keys `AppModule` lists.
  static const allowList = {themeModeKey, dynamicColorKey};

  final SharedPreferencesWithCache _preferences;

  bool? getBool(String key) => _preferences.getBool(key);

  String? getString(String key) => _preferences.getString(key);

  Future<void> setBool(String key, {required bool value}) =>
      _preferences.setBool(key, value);

  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);
}
