import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/repository/settings_repository.dart';
import 'package:flutter_clean_starter/domain/repository/task_repository.dart';
import 'package:flutter_clean_starter/domain/usecase/settings_use_cases.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_dependencies.dart';

void main() {
  tearDown(getIt.reset);

  // A smoke test of the real composition root. A dependency injectable can't
  // resolve only fails when its type is first resolved, at runtime; resolving
  // the top of each graph here catches it in CI. Every new Cubit, repository
  // and use case belongs here.
  test('the real container resolves the repositories and use cases', () async {
    await configureTestDependencies();

    expect(getIt<TaskRepository>(), same(getIt<TaskRepository>()));
    expect(getIt<SettingsRepository>(), same(getIt<SettingsRepository>()));
    for (final resolve in <Object Function()>[
      () => getIt<WatchTasksUseCase>(),
      () => getIt<WatchTaskUseCase>(),
      () => getIt<SeedTasksUseCase>(),
      () => getIt<RefreshTasksUseCase>(),
      () => getIt<AddTaskUseCase>(),
      () => getIt<UpdateTaskUseCase>(),
      () => getIt<SetTaskCompletedUseCase>(),
      () => getIt<DeleteTaskUseCase>(),
      () => getIt<RestoreTaskUseCase>(),
      () => getIt<ResetDemoDataUseCase>(),
      () => getIt<WatchSettingsUseCase>(),
      () => getIt<UpdateThemeModeUseCase>(),
      () => getIt<UpdateDynamicColorUseCase>(),
    ]) {
      expect(resolve(), isNotNull);
    }
  });

  test('settings are loaded before the first frame (@preResolve)', () async {
    await configureTestDependencies(
      preferences: {'settings.themeMode': 'dark'},
    );

    expect(getIt<SettingsRepository>().current.themeMode.name, 'dark');
  });
}
