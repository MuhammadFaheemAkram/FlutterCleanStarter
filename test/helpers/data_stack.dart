import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_starter/core/common/id_generator.dart';
import 'package:flutter_clean_starter/core/database/app_database.dart';
import 'package:flutter_clean_starter/core/network/asset_json_loader.dart';
import 'package:flutter_clean_starter/core/network/fake_task_api.dart';
import 'package:flutter_clean_starter/core/network/network_simulator.dart';
import 'package:flutter_clean_starter/core/storage/tasks_preferences.dart';
import 'package:flutter_clean_starter/data/repository/task_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'database.dart';
import 'fakes/scripted_task_api.dart';
import 'task_fixtures.dart';

/// The real repository on an in-memory database, with a clock stopped at
/// [now] (set it to move time), in-memory preferences, and a
/// [ScriptedTaskApi] in front of the real fake API (zero latency, reading
/// the bundled seed): what repository, use case and Cubit tests run against
/// instead of mocks.
///
/// Create it with [DataStack.create], and [close] it in `tearDown`. Tests
/// that read the bundled seed need
/// `TestWidgetsFlutterBinding.ensureInitialized()`.
class DataStack {
  DataStack._(this.preferences)
    : network = NetworkSimulator(latency: Duration.zero) {
    realApi = FakeTaskApi(AssetJsonLoader(rootBundle), network, clock);
    api = ScriptedTaskApi(realApi);
    tasks = TaskRepositoryImpl(
      api,
      db.tasksDao,
      TasksPreferences(preferences),
      clock,
      IdGenerator.seeded(Random(7)),
    );
  }

  /// A fresh stack; [preferences] pre-fills the store (raw keys).
  static Future<DataStack> create({
    Map<String, Object> preferences = const {},
  }) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(Map.of(preferences));
    return DataStack._(
      await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      ),
    );
  }

  final AppDatabase db = newTestDatabase();
  final NetworkSimulator network;
  final SharedPreferencesWithCache preferences;
  late final FakeTaskApi realApi;
  late final ScriptedTaskApi api;
  late final TaskRepositoryImpl tasks;

  /// The current time for everything in the stack.
  DateTime now = demoNow;

  late final Clock clock = Clock(() => now);

  TasksPreferences get flags => TasksPreferences(preferences);

  Future<void> close() => db.close();
}
