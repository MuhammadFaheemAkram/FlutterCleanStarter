import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_clean_starter/features/task_detail/cubit/task_detail_cubit.dart';
import 'package:flutter_clean_starter/features/task_detail/cubit/task_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/data_stack.dart';
import '../../../helpers/fakes/scripted_deletes.dart';
import '../../../helpers/task_fixtures.dart';
import '../../../helpers/wait_for.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack stack;
  late ScriptedDeletes tasks;
  final cubits = <TaskDetailCubit>[];

  setUp(() async {
    stack = await DataStack.create();
    tasks = ScriptedDeletes(stack.tasks);
    await stack.tasks.seedIfNeeded();
  });

  tearDown(() async {
    for (final cubit in cubits) {
      await cubit.close();
    }
    cubits.clear();
    await stack.close();
  });

  TaskDetailCubit open(String id) {
    final cubit = TaskDetailCubit(
      id,
      WatchTaskUseCase(stack.tasks),
      SetTaskCompletedUseCase(stack.tasks),
      DeleteTaskUseCase(tasks),
      stack.clock,
    )..load();
    cubits.add(cubit);
    return cubit;
  }

  Future<TaskDetailState> settled(TaskDetailCubit cubit) =>
      waitFor(cubit, (s) => s.status != TaskDetailStatus.loading);

  test('shows the task, with today', () async {
    final state = await settled(open(demoTaskId));

    expect(state.status, TaskDetailStatus.ready);
    expect(state.task!.title, 'Explore the architecture');
    expect(state.today, demoToday);
  });

  test('a task that does not exist is not found', () async {
    expect((await settled(open('nope'))).status, TaskDetailStatus.notFound);
  });

  test('toggle ticks it off, and back', () async {
    final cubit = open(demoTaskId);
    await settled(cubit);

    await cubit.toggle();
    await waitFor(cubit, (s) => s.task!.isCompleted);
    await cubit.toggle();

    expect(
      (await waitFor(cubit, (s) => !s.task!.isCompleted)).task!.isCompleted,
      isFalse,
    );
  });

  test('an edit elsewhere shows at once', () async {
    final cubit = open(demoTaskId);
    final before = (await settled(cubit)).task!;

    await stack.tasks.update(before.copyWith(title: 'Edited in the form'));

    expect(
      (await waitFor(cubit, (s) => s.task!.title != before.title)).task!.title,
      'Edited in the form',
    );
  });

  test('delete: deleted, never "not found", and stored as gone', () async {
    final cubit = open(demoTaskId);
    await settled(cubit);
    final seen = <TaskDetailStatus>[];
    final subscription = cubit.stream.listen((s) => seen.add(s.status));

    await cubit.delete();
    await pumpEventQueue();
    await subscription.cancel();

    expect(seen, [TaskDetailStatus.deleting, TaskDetailStatus.deleted]);
    expect(await stack.tasks.watchTask(demoTaskId).first, isNull);
  });

  test('deleted elsewhere: not found', () async {
    final cubit = open(demoTaskId);
    await settled(cubit);

    await stack.tasks.delete(demoTaskId);

    expect(
      (await waitFor(cubit, (s) => s.status != TaskDetailStatus.ready)).status,
      TaskDetailStatus.notFound,
    );
  });

  test('a failed delete stays on the task and says why', () async {
    final cubit = open(demoTaskId);
    await settled(cubit);
    tasks.deleteAnswer = const Err(UnknownException());

    await cubit.delete();

    expect(cubit.state.status, TaskDetailStatus.ready);
    expect(cubit.state.message, const UnknownException().message);
  });

  test('toggle and delete do nothing while not ready', () async {
    final cubit = open('nope');
    await settled(cubit);

    await cubit.toggle();
    await cubit.delete();

    expect(cubit.state.status, TaskDetailStatus.notFound);
    expect(cubit.state.messageSerial, 0);
  });
}
