import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_clean_starter/features/tasks/cubit/tasks_cubit.dart';
import 'package:flutter_clean_starter/features/tasks/cubit/tasks_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/data_stack.dart';
import '../../../helpers/fakes/scripted_deletes.dart';
import '../../../helpers/task_fixtures.dart';
import '../../../helpers/wait_for.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack stack;
  late ScriptedDeletes tasks;
  late TasksCubit cubit;

  TasksCubit newCubit() => TasksCubit(
    WatchTasksUseCase(tasks),
    SeedTasksUseCase(tasks),
    RefreshTasksUseCase(tasks),
    SetTaskCompletedUseCase(tasks),
    DeleteTaskUseCase(tasks),
    RestoreTaskUseCase(tasks),
    stack.clock,
  );

  setUp(() async {
    stack = await DataStack.create();
    tasks = ScriptedDeletes(stack.tasks);
    cubit = newCubit();
  });

  tearDown(() async {
    await cubit.close();
    await stack.close();
  });

  Future<TasksState> loaded() async {
    await cubit.load();
    return waitFor(cubit, (s) => s.status != TasksStatus.loading);
  }

  List<String> titles(TasksState state) => [
    for (final task in state.tasks) task.title,
  ];

  group('the first launch', () {
    test('starts loading, then shows the seeded tasks in order', () async {
      expect(cubit.state.status, TasksStatus.loading);

      final state = await loaded();

      expect(state.status, TasksStatus.ready);
      expect(titles(state), [
        'Swap the fake API for a real one',
        'Explore the architecture',
        'Rename the project',
        'Welcome to Flutter Clean Starter',
        'Run the test suite',
      ]);
      expect(state.today, demoToday);
    });

    test(
      'stays loading until the seed has answered (no "No tasks" flash)',
      () async {
        final seen = <TasksStatus>[];
        final subscription = cubit.stream.listen((s) => seen.add(s.status));

        await loaded();
        await pumpEventQueue();
        await subscription.cancel();

        expect(seen, isNot(contains(TasksStatus.empty)));
        expect(seen.last, TasksStatus.ready);
      },
    );

    test('offline: the error state, with why', () async {
      stack.api.fail(const NetworkException());

      final state = await loaded();

      expect(state.status, TasksStatus.error);
      expect(state.errorMessage, const NetworkException().message);
    });

    test('Try again seeds, and the list appears', () async {
      stack.api.fail(const NetworkException());
      await loaded();

      await cubit.retry();
      final state = await waitFor(cubit, (s) => s.status == TasksStatus.ready);

      expect(state.tasks, hasLength(5));
      expect(state.errorMessage, isNull);
    });
  });

  test('a later launch with no tasks left is empty, not an error', () async {
    await stack.tasks.seedIfNeeded();
    for (final task in await stack.tasks.watchTasks().first) {
      await stack.tasks.delete(task.id);
    }
    stack.api.fail(const NetworkException());

    expect((await loaded()).status, TasksStatus.empty);
  });

  group('refresh', () {
    setUp(loaded);

    test('says what it added', () async {
      stack.api.answer([taskDto(id: 'new', title: 'New one')]);

      await cubit.refresh();

      expect(cubit.state.message, '1 new task from the server.');
      final state = await waitFor(cubit, (s) => s.tasks.length == 6);
      expect(titles(state), contains('New one'));
      expect(state.refreshing, isFalse);
    });

    test('with nothing new: up to date', () async {
      await cubit.refresh();

      expect(cubit.state.message, "You're up to date.");
    });

    test('offline: says why, once, and keeps the list', () async {
      stack.api.fail(const NetworkException());
      final serial = cubit.state.messageSerial;

      await cubit.refresh();

      expect(cubit.state.message, const NetworkException().message);
      expect(cubit.state.messageSerial, serial + 1);
      expect(cubit.state.tasks, hasLength(5));
      expect(cubit.state.status, TasksStatus.ready);
    });
  });

  group('toggle', () {
    setUp(loaded);

    test('marks a task done, and the list follows (done tasks last)', () async {
      final first = cubit.state.tasks.first;

      await cubit.toggle(first);
      final state = await waitFor(
        cubit,
        (s) => s.tasks.any((t) => t.id == first.id && t.isCompleted),
      );

      final position = state.tasks.indexWhere((t) => t.id == first.id);
      expect(
        position,
        greaterThan(state.tasks.lastIndexWhere((t) => !t.isCompleted)),
      );
    });

    test('a task deleted meanwhile: says so', () async {
      final first = cubit.state.tasks.first;
      await stack.tasks.delete(first.id);

      await cubit.toggle(first);

      expect(cubit.state.message, "That task doesn't exist any more.");
    });
  });

  group('delete and Undo', () {
    late Task first;

    setUp(() async {
      await loaded();
      first = cubit.state.tasks.first;
    });

    test('the task leaves the list at once, before the database answers', () {
      // Not awaited: the row must be gone in the same frame as the swipe.
      final deleting = cubit.delete(first);

      expect(cubit.state.tasks.map((t) => t.id), isNot(contains(first.id)));
      return deleting;
    });

    test('offers Undo with the deleted task', () async {
      final serial = cubit.state.undoSerial;

      await cubit.delete(first);

      expect(cubit.state.undoable, first);
      expect(cubit.state.undoSerial, serial + 1);
      expect(await stack.tasks.watchTask(first.id).first, isNull);
    });

    test('Undo brings it back exactly', () async {
      await cubit.delete(first);

      await cubit.undo(cubit.state.undoable!);
      final state = await waitFor(cubit, (s) => s.tasks.length == 5);

      expect(state.tasks.first, first);
    });

    test(
      'Undo before the database reported the delete still shows it',
      () async {
        // The delete answers, but drift never reports the row gone: only Undo
        // can bring it back into the list.
        tasks.deleteAnswer = Ok(first);
        await cubit.delete(first);
        expect(cubit.state.tasks.map((t) => t.id), isNot(contains(first.id)));

        await cubit.undo(first);

        expect(cubit.state.tasks.map((t) => t.id), contains(first.id));
      },
    );

    test('deleting the last task makes the list empty', () async {
      for (final task in [...cubit.state.tasks]) {
        await cubit.delete(task);
      }

      expect(
        (await waitFor(cubit, (s) => s.status != TasksStatus.ready)).status,
        TasksStatus.empty,
      );
    });

    test('a failed delete puts the row back and says why', () async {
      tasks.deleteAnswer = const Err(UnknownException());

      await cubit.delete(first);

      expect(cubit.state.tasks.first, first);
      expect(cubit.state.message, const UnknownException().message);
      expect(cubit.state.undoable, isNull);
    });
  });

  test('a change made elsewhere reaches the list', () async {
    await loaded();

    await stack.tasks.add(const TaskDraft(title: 'From another screen'));

    final state = await waitFor(cubit, (s) => s.tasks.length == 6);
    expect(titles(state), contains('From another screen'));
  });
}
