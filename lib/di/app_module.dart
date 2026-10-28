import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_starter/core/database/app_database.dart';
import 'package:flutter_clean_starter/core/database/daos/tasks_dao.dart';
import 'package:flutter_clean_starter/core/storage/settings_local_data_source.dart';
import 'package:flutter_clean_starter/core/storage/tasks_preferences.dart';
import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:flutter_clean_starter/domain/service/dynamic_color_source.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers types the app doesn't own, so they can be injected (and
/// replaced in tests) like everything else.
///
/// The classes the app *does* own register themselves with an annotation
/// (`@injectable`, `@lazySingleton`, `@LazySingleton(as: …)`).
@module
abstract class AppModule {
  /// The asset bundle the fake API reads its seed from.
  @lazySingleton
  AssetBundle get assetBundle => rootBundle;

  /// The current time, injected so tests can fix it (`Clock.fixed`): every
  /// "now" and "today" in the app comes from here.
  @lazySingleton
  Clock get clock => const Clock();

  /// One database for the whole app. Several connections to the same SQLite
  /// file would break drift's change notifications.
  @lazySingleton
  AppDatabase get appDatabase => AppDatabase();

  @lazySingleton
  TasksDao tasksDao(AppDatabase database) => database.tasksDao;

  /// `@preResolve` awaits this before `runApp`, so preferences can be read
  /// synchronously from the first frame: the app opens in the chosen theme,
  /// with no flash of the default one.
  @preResolve
  @lazySingleton
  Future<SharedPreferencesWithCache> get preferences =>
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: {
            ...SettingsLocalDataSource.allowList,
            ...TasksPreferences.allowList,
          },
        ),
      );

  /// Read once before the first frame, like the preferences: About shows
  /// the version without a loading state.
  @preResolve
  @lazySingleton
  Future<AppInfo> get appInfo async {
    final info = await PackageInfo.fromPlatform();
    return AppInfo(
      name: info.appName,
      version: info.version,
      buildNumber: info.buildNumber,
    );
  }

  /// The wallpaper's color, before the first frame: the first frame is
  /// already in the right colors.
  @preResolve
  @lazySingleton
  Future<DeviceColors> deviceColors(DynamicColorSource source) async =>
      DeviceColors(wallpaperColor: await source.wallpaperColor());
}
