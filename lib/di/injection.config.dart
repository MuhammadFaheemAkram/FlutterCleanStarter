// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:clock/clock.dart' as _i454;
import 'package:flutter/services.dart' as _i281;
import 'package:flutter_clean_starter/core/common/id_generator.dart' as _i192;
import 'package:flutter_clean_starter/core/database/app_database.dart' as _i18;
import 'package:flutter_clean_starter/core/database/daos/tasks_dao.dart'
    as _i626;
import 'package:flutter_clean_starter/core/network/asset_json_loader.dart'
    as _i785;
import 'package:flutter_clean_starter/core/network/fake_task_api.dart' as _i445;
import 'package:flutter_clean_starter/core/network/network_simulator.dart'
    as _i723;
import 'package:flutter_clean_starter/core/network/task_api.dart' as _i405;
import 'package:flutter_clean_starter/core/storage/settings_local_data_source.dart'
    as _i373;
import 'package:flutter_clean_starter/core/storage/tasks_preferences.dart'
    as _i7;
import 'package:flutter_clean_starter/data/repository/settings_repository_impl.dart'
    as _i798;
import 'package:flutter_clean_starter/data/repository/task_repository_impl.dart'
    as _i707;
import 'package:flutter_clean_starter/di/app_module.dart' as _i611;
import 'package:flutter_clean_starter/domain/repository/settings_repository.dart'
    as _i179;
import 'package:flutter_clean_starter/domain/repository/task_repository.dart'
    as _i397;
import 'package:flutter_clean_starter/domain/usecase/settings_use_cases.dart'
    as _i726;
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart'
    as _i749;
import 'package:flutter_clean_starter/features/tasks/cubit/tasks_cubit.dart'
    as _i612;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i192.IdGenerator>(() => _i192.IdGenerator());
    gh.lazySingleton<_i723.NetworkSimulator>(() => _i723.NetworkSimulator());
    gh.lazySingleton<_i281.AssetBundle>(() => appModule.assetBundle);
    gh.lazySingleton<_i454.Clock>(() => appModule.clock);
    gh.lazySingleton<_i18.AppDatabase>(() => appModule.appDatabase);
    await gh.lazySingletonAsync<_i460.SharedPreferencesWithCache>(
      () => appModule.preferences,
      preResolve: true,
    );
    gh.lazySingleton<_i626.TasksDao>(
      () => appModule.tasksDao(gh<_i18.AppDatabase>()),
    );
    gh.lazySingleton<_i373.SettingsLocalDataSource>(
      () =>
          _i373.SettingsLocalDataSource(gh<_i460.SharedPreferencesWithCache>()),
    );
    gh.lazySingleton<_i7.TasksPreferences>(
      () => _i7.TasksPreferences(gh<_i460.SharedPreferencesWithCache>()),
    );
    gh.lazySingleton<_i785.AssetJsonLoader>(
      () => _i785.AssetJsonLoader(gh<_i281.AssetBundle>()),
    );
    gh.lazySingleton<_i405.TaskApi>(
      () => _i445.FakeTaskApi(
        gh<_i785.AssetJsonLoader>(),
        gh<_i723.NetworkSimulator>(),
        gh<_i454.Clock>(),
      ),
    );
    gh.lazySingleton<_i179.SettingsRepository>(
      () => _i798.SettingsRepositoryImpl(gh<_i373.SettingsLocalDataSource>()),
    );
    gh.lazySingleton<_i397.TaskRepository>(
      () => _i707.TaskRepositoryImpl(
        gh<_i405.TaskApi>(),
        gh<_i626.TasksDao>(),
        gh<_i7.TasksPreferences>(),
        gh<_i454.Clock>(),
        gh<_i192.IdGenerator>(),
      ),
    );
    gh.factory<_i726.WatchSettingsUseCase>(
      () => _i726.WatchSettingsUseCase(gh<_i179.SettingsRepository>()),
    );
    gh.factory<_i726.UpdateThemeModeUseCase>(
      () => _i726.UpdateThemeModeUseCase(gh<_i179.SettingsRepository>()),
    );
    gh.factory<_i726.UpdateDynamicColorUseCase>(
      () => _i726.UpdateDynamicColorUseCase(gh<_i179.SettingsRepository>()),
    );
    gh.factory<_i749.WatchTasksUseCase>(
      () => _i749.WatchTasksUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i749.WatchTaskUseCase>(
      () => _i749.WatchTaskUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i749.SeedTasksUseCase>(
      () => _i749.SeedTasksUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i749.RefreshTasksUseCase>(
      () => _i749.RefreshTasksUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i749.AddTaskUseCase>(
      () => _i749.AddTaskUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i749.UpdateTaskUseCase>(
      () => _i749.UpdateTaskUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i749.SetTaskCompletedUseCase>(
      () => _i749.SetTaskCompletedUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i749.DeleteTaskUseCase>(
      () => _i749.DeleteTaskUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i749.RestoreTaskUseCase>(
      () => _i749.RestoreTaskUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i749.ResetDemoDataUseCase>(
      () => _i749.ResetDemoDataUseCase(gh<_i397.TaskRepository>()),
    );
    gh.factory<_i612.TasksCubit>(
      () => _i612.TasksCubit(
        gh<_i749.WatchTasksUseCase>(),
        gh<_i749.SeedTasksUseCase>(),
        gh<_i749.RefreshTasksUseCase>(),
        gh<_i749.SetTaskCompletedUseCase>(),
        gh<_i749.DeleteTaskUseCase>(),
        gh<_i749.RestoreTaskUseCase>(),
        gh<_i454.Clock>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i611.AppModule {}
