import 'package:flutter_clean_starter/core/storage/settings_local_data_source.dart';
import 'package:flutter_clean_starter/data/repository/settings_repository_impl.dart';
import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// An in-memory store that records every write, to prove which keys a
/// change writes.
final class _RecordingStore extends InMemorySharedPreferencesAsync {
  _RecordingStore(super.data) : super.withData();

  final writes = <String>[];

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) {
    writes.add(key);
    return super.setString(key, value, options);
  }

  @override
  Future<bool> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) {
    writes.add(key);
    return super.setBool(key, value, options);
  }
}

void main() {
  late _RecordingStore store;
  final repositories = <SettingsRepositoryImpl>[];

  /// A repository over the current [store], as a new launch would open it.
  Future<SettingsRepositoryImpl> reopen() async {
    final preferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: SettingsLocalDataSource.allowList,
      ),
    );
    final repository = SettingsRepositoryImpl(
      SettingsLocalDataSource(preferences),
    );
    repositories.add(repository);
    return repository;
  }

  Future<SettingsRepositoryImpl> open([Map<String, Object> stored = const {}]) {
    store = _RecordingStore(Map.of(stored));
    SharedPreferencesAsyncPlatform.instance = store;
    return reopen();
  }

  tearDown(() async {
    for (final repository in repositories) {
      await repository.dispose();
    }
    repositories.clear();
  });

  test('nothing stored: the defaults (System, dynamic color on)', () async {
    final repository = await open();

    expect(repository.current, const AppSettings());
    expect(repository.current.themeMode, AppThemeMode.system);
    expect(repository.current.dynamicColor, isTrue);
  });

  test('reads what was stored', () async {
    final repository = await open({
      'settings.themeMode': 'dark',
      'settings.dynamicColor': false,
    });

    expect(
      repository.current,
      const AppSettings(themeMode: AppThemeMode.dark, dynamicColor: false),
    );
  });

  test('an unknown stored value falls back to the default', () async {
    final repository = await open({'settings.themeMode': 'sepia'});

    expect(repository.current.themeMode, AppThemeMode.system);
  });

  test('a change is published at once and saved', () async {
    final repository = await open();
    final seen = <AppSettings>[];
    final subscription = repository.watch().listen(seen.add);

    await repository.update((s) => s.copyWith(themeMode: AppThemeMode.light));
    await pumpEventQueue();
    await subscription.cancel();

    expect(seen.map((s) => s.themeMode), [
      AppThemeMode.system,
      AppThemeMode.light,
    ]);
    expect((await reopen()).current.themeMode, AppThemeMode.light);
  });

  test('only the changed keys are written', () async {
    final repository = await open();

    await repository.update((s) => s.copyWith(dynamicColor: false));
    expect(store.writes, ['settings.dynamicColor']);

    await repository.update((s) => s.copyWith(themeMode: AppThemeMode.dark));
    expect(store.writes, ['settings.dynamicColor', 'settings.themeMode']);
  });

  test('a change to the same value writes and publishes nothing', () async {
    final repository = await open();
    final seen = <AppSettings>[];
    final subscription = repository.watch().listen(seen.add);

    await repository.update((s) => s.copyWith(dynamicColor: true));
    await pumpEventQueue();
    await subscription.cancel();

    expect(store.writes, isEmpty);
    expect(seen, hasLength(1));
  });
}
