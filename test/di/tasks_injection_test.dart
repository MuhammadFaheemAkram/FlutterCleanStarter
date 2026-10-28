import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/repository/task_repository.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_cubit.dart';
import 'package:flutter_clean_starter/features/task_detail/cubit/task_detail_cubit.dart';
import 'package:flutter_clean_starter/features/task_form/cubit/task_form_cubit.dart';
import 'package:flutter_clean_starter/features/tasks/cubit/tasks_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(getIt.reset);

  test('the real container resolves the Tasks sample', () async {
    await configureTestDependencies();

    expect(getIt<TaskRepository>(), same(getIt<TaskRepository>()));
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
      () => getIt<TasksCubit>(),
      () => getIt<TaskDetailCubit>(param1: 'id'),
      () => getIt<TaskFormCubit>(),
      () => getIt<TasksDemoCubit>(),
    ]) {
      expect(resolve(), isNotNull);
    }
  });
}
