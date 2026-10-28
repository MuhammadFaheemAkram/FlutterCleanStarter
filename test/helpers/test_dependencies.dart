import 'package:clock/clock.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_clean_starter/core/database/app_database.dart';
import 'package:flutter_clean_starter/core/network/network_simulator.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'database.dart';
import 'test_clock.dart';

/// Builds the app's real composition root for app-level tests, with these
/// swaps:
/// - preferences live in an in-memory store, pre-filled with [preferences]
///   (raw keys, as the data sources name them);
/// - the database lives in memory (and is closed by `getIt.reset()`);
/// - the simulated network has no latency;
/// - the clock is fixed at [demoNow];
/// - the device has no wallpaper colors (as on iOS), or [wallpaperColor];
/// - the app is "Clean Starter" 1.0.0 (1).
///
/// Everything else is the real code, so these tests also prove the DI graph
/// resolves. Call `getIt.reset()` in `tearDown`.
Future<void> configureTestDependencies({
  Map<String, Object> preferences = const {},
  int? wallpaperColor,
}) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(Map.of(preferences));
  // Answered at once: an unanswered platform call before the first pump
  // waits on fake time forever (conventions §11.44, §11.58).
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(DynamicColorPlugin.channel, (_) async => null);
  PackageInfo.setMockInitialValues(
    appName: 'Clean Starter',
    packageName: 'co.bitfuse.flutter.cleanstarter',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await configureDependencies();
  if (wallpaperColor != null) {
    getIt
      ..unregister<DeviceColors>()
      ..registerSingleton(DeviceColors(wallpaperColor: wallpaperColor));
  }
  getIt
    ..unregister<AppDatabase>()
    ..registerLazySingleton<AppDatabase>(
      newTestDatabase,
      dispose: (database) => database.close(),
    )
    ..unregister<NetworkSimulator>()
    ..registerLazySingleton<NetworkSimulator>(
      () => NetworkSimulator(latency: Duration.zero),
    )
    ..unregister<Clock>()
    ..registerLazySingleton<Clock>(() => Clock.fixed(demoNow));
}
