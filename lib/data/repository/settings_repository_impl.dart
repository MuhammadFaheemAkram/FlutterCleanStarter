import 'dart:async';

import 'package:flutter_clean_starter/core/storage/settings_local_data_source.dart';
import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/repository/settings_repository.dart';
import 'package:injectable/injectable.dart';

typedef _Keys = SettingsLocalDataSource;

/// The default [SettingsRepository].
///
/// It keeps the current [AppSettings] in memory, publishes every change to
/// its watchers at once, and persists through [SettingsLocalDataSource].
/// Missing values fall back to the defaults.
///
/// Only the values that changed are written: once an app has a second
/// writer (a background isolate), writing every key from a stale copy would
/// undo what the other one saved (conventions §11.64).
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local) : _current = _read(_local);

  final SettingsLocalDataSource _local;
  final _changes = StreamController<AppSettings>.broadcast(sync: true);
  AppSettings _current;

  @override
  AppSettings get current => _current;

  @override
  Stream<AppSettings> watch() {
    // The current value on listen, then every change. Subscribing to the
    // changes in the same step leaves no gap for an update to slip through.
    return Stream.multi((watcher) {
      final subscription = _changes.stream.listen(watcher.add);
      watcher
        ..onCancel = subscription.cancel
        ..add(_current);
    });
  }

  @override
  Future<void> update(AppSettings Function(AppSettings settings) change) async {
    final before = _current;
    final after = change(before);
    if (after == before) return;
    _current = after;
    _changes.add(after);
    if (before.themeMode != after.themeMode) {
      await _local.setString(_Keys.themeModeKey, after.themeMode.name);
    }
    if (before.dynamicColor != after.dynamicColor) {
      await _local.setBool(_Keys.dynamicColorKey, value: after.dynamicColor);
    }
  }

  /// Closes the change stream (for tests: the app keeps one repository for
  /// its whole lifetime).
  Future<void> dispose() => _changes.close();

  static AppSettings _read(SettingsLocalDataSource local) {
    const defaults = AppSettings();
    return AppSettings(
      // A value this version doesn't know (a later one wrote it) falls back
      // to the default rather than failing.
      themeMode:
          AppThemeMode.values.asNameMap()[local.getString(
            _Keys.themeModeKey,
          )] ??
          defaults.themeMode,
      dynamicColor:
          local.getBool(_Keys.dynamicColorKey) ?? defaults.dynamicColor,
    );
  }
}
