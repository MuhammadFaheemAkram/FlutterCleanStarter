import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/result_matchers.dart';
import '../../helpers/task_fixtures.dart';
import '../../helpers/tasks_data_stack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack stack;

  setUp(() async => stack = await DataStack.create());
  tearDown(() => stack.close());

  Future<List<Task>> tasks() => stack.tasks.watchTasks().first;

  Future<List<String>> titles() async => [
    for (final task in await tasks()) task.title,
  ];

  T valueOf<T>(Result<T> result) => (result as Ok<T>).value;

  group('seedIfNeeded', () {
    test(
      'the first launch writes the server\'s tasks and sets the flag',
      () async {
        expect(await stack.tasks.seedIfNeeded(), isOk(5));

        expect(await tasks(), hasLength(5));
        expect(stack.flags.seeded, isTrue);
      },
    );

    test('the seeded due dates are days counted from that launch', () async {
      await stack.tasks.seedIfNeeded();

      final due = {for (final task in await tasks()) task.title: task.due};
      expect(due['Explore the architecture'], demoToday.addDays(2));
      expect(due['Swap the fake API for a real one'], demoToday.addDays(-1));
    });

    test(
      'runs once: a later launch neither asks the server nor writes',
      () async {
        await stack.tasks.seedIfNeeded();
        await stack.tasks.delete((await tasks()).first.id);

        expect(await stack.tasks.seedIfNeeded(), isOk(0));
        expect(stack.api.calls, 1);
        expect(await tasks(), hasLength(4));
      },
    );

    test('an empty store after the seed stays empty (the user deleted '
        'everything)', () async {
      await stack.tasks.seedIfNeeded();
      for (final task in await tasks()) {
        await stack.tasks.delete(task.id);
      }

      expect(await stack.tasks.seedIfNeeded(), isOk(0));
      expect(await tasks(), isEmpty);
    });

    test('two calls at once seed once', () async {
      final results = await Future.wait([
        stack.tasks.seedIfNeeded(),
        stack.tasks.seedIfNeeded(),
      ]);

      expect(results, [isOk(5), isOk(5)]);
      expect(stack.api.calls, 1);
    });

    test(
      'offline: an Err, nothing written, and the flag stays unset',
      () async {
        stack.api.fail(const NetworkException());

        expect(await stack.tasks.seedIfNeeded(), isErr<NetworkException>());
        expect(await tasks(), isEmpty);
        expect(stack.flags.seeded, isFalse);

        // Try again, online.
        expect(await stack.tasks.seedIfNeeded(), isOk(5));
      },
    );

    test('damaged data: an Err, and nothing written', () async {
      stack.api.answer([taskDto(id: 'a'), taskDto(id: 'b', title: '')]);

      expect(await stack.tasks.seedIfNeeded(), isErr<DataFormatException>());
      expect(await tasks(), isEmpty);
      expect(stack.flags.seeded, isFalse);
    });

    test('tasks but no flag (its write was lost): the flag is set, nothing '
        'fetched', () async {
      await stack.tasks.add(const TaskDraft(title: 'Mine'));

      expect(await stack.tasks.seedIfNeeded(), isOk(0));
      expect(stack.flags.seeded, isTrue);
      expect(stack.api.calls, 0);
    });
  });

  group('refresh', () {
    setUp(() async => stack.tasks.seedIfNeeded());

    test('adds the server\'s new tasks', () async {
      stack.api.answer([taskDto(id: 'new', title: 'New on the server')]);

      expect(await stack.tasks.refresh(), isOk(1));
      expect(await titles(), contains('New on the server'));
    });

    test('never overwrites a local edit', () async {
      final mine = (await tasks()).firstWhere(
        (task) => task.title == 'Explore the architecture',
      );
      await stack.tasks.update(mine.copyWith(title: 'Read the docs first'));

      expect(await stack.tasks.refresh(), isOk(0));

      expect(await titles(), contains('Read the docs first'));
      expect(await titles(), isNot(contains('Explore the architecture')));
    });

    test('never brings back a deleted task', () async {
      final deleted = (await tasks()).first;
      await stack.tasks.delete(deleted.id);

      expect(await stack.tasks.refresh(), isOk(0));
      expect(await titles(), isNot(contains(deleted.title)));
    });

    test('a later day does not move a stored due date', () async {
      stack.now = demoNow.add(const Duration(days: 3));

      await stack.tasks.refresh();

      final explore = (await tasks()).firstWhere(
        (task) => task.title == 'Explore the architecture',
      );
      expect(explore.due, demoToday.addDays(2));
    });

    test('offline: an Err, and the tasks stay as they were', () async {
      final before = await tasks();
      stack.api.fail(const NetworkException());

      expect(await stack.tasks.refresh(), isErr<NetworkException>());
      expect(await tasks(), before);
    });
  });

  group('add', () {
    test('saves a new task with an id and the time', () async {
      final saved = valueOf(
        await stack.tasks.add(
          TaskDraft(title: '  Ship it ', notes: 'Soon', due: demoToday),
        ),
      );

      expect(saved.id, isNotEmpty);
      expect(saved.title, 'Ship it');
      expect(saved.notes, 'Soon');
      expect(saved.due, demoToday);
      expect(saved.isCompleted, isFalse);
      expect(saved.createdAt, demoNow);
      expect(saved.updatedAt, demoNow);
      expect(await tasks(), [saved]);
    });

    test('each task gets its own id', () async {
      final a = valueOf(await stack.tasks.add(const TaskDraft(title: 'A')));
      final b = valueOf(await stack.tasks.add(const TaskDraft(title: 'B')));

      expect(a.id, isNot(b.id));
    });

    test('the database refuses what slips past the use case', () async {
      expect(
        await stack.tasks.add(const TaskDraft(title: '   ')),
        isErr<UnknownException>(),
      );
      expect(await tasks(), isEmpty);
    });
  });

  group('update and setCompleted', () {
    late Task original;

    setUp(() async {
      original = valueOf(
        await stack.tasks.add(const TaskDraft(title: 'Original')),
      );
      stack.now = demoNow.add(const Duration(hours: 2));
    });

    test(
      'update writes the fields and a new updatedAt, never createdAt',
      () async {
        final edited = original.copyWith(
          title: 'Edited',
          notes: 'More',
          due: CalendarDate(2026, 11, 5),
          isCompleted: true,
          // A changed creation time is ignored.
          createdAt: DateTime.utc(2020),
        );

        expect(await stack.tasks.update(edited), isOk());

        final stored = await stack.tasks.watchTask(original.id).first;
        expect(
          stored,
          edited.copyWith(createdAt: original.createdAt, updatedAt: stack.now),
        );
      },
    );

    test('clearing the due date stores none', () async {
      await stack.tasks.update(original.copyWith(due: demoToday));
      await stack.tasks.update(original.copyWith(due: null));

      expect((await stack.tasks.watchTask(original.id).first)!.due, isNull);
    });

    test('setCompleted toggles and moves updatedAt', () async {
      expect(
        await stack.tasks.setCompleted(original.id, completed: true),
        isOk(),
      );

      final done = (await stack.tasks.watchTask(original.id).first)!;
      expect(done.isCompleted, isTrue);
      expect(done.updatedAt, stack.now);
      expect(done.createdAt, original.createdAt);

      await stack.tasks.setCompleted(original.id, completed: false);
      expect(
        (await stack.tasks.watchTask(original.id).first)!.isCompleted,
        isFalse,
      );
    });

    test('a task that no longer exists is NotFound', () async {
      expect(
        await stack.tasks.update(original.copyWith(id: 'gone')),
        isErr<NotFoundException>(),
      );
      expect(
        await stack.tasks.setCompleted('gone', completed: true),
        isErr<NotFoundException>(),
      );
    });
  });

  group('delete and restore', () {
    late Task original;

    setUp(() async {
      original = valueOf(
        await stack.tasks.add(
          TaskDraft(title: 'Keep me', notes: 'n', due: demoToday),
        ),
      );
    });

    test('delete answers the deleted task, for Undo', () async {
      expect(await stack.tasks.delete(original.id), isOk(original));
      expect(await tasks(), isEmpty);
    });

    test('Undo restores it exactly: same id, same times', () async {
      stack.now = demoNow.add(const Duration(minutes: 5));
      final deleted = valueOf(await stack.tasks.delete(original.id));

      expect(await stack.tasks.restore(deleted), isOk());

      expect(await tasks(), [original]);
    });

    test('a restored server task is not added again by a refresh', () async {
      // The server's tasks (the stored one already counts as a seed).
      await stack.tasks.resetDemoData();
      final seeded = (await tasks()).first;
      final deleted = valueOf(await stack.tasks.delete(seeded.id));
      await stack.tasks.restore(deleted);

      expect(await stack.tasks.refresh(), isOk(0));
      expect((await tasks()).where((t) => t.id == seeded.id), hasLength(1));
    });

    test('deleting a missing task is NotFound', () async {
      expect(await stack.tasks.delete('gone'), isErr<NotFoundException>());
    });
  });

  group('resetDemoData', () {
    test('replaces every task with the server\'s', () async {
      await stack.tasks.seedIfNeeded();
      await stack.tasks.add(const TaskDraft(title: 'Mine'));
      await stack.tasks.delete((await tasks()).last.id);

      expect(await stack.tasks.resetDemoData(), isOk(5));

      expect(await tasks(), hasLength(5));
      expect(await titles(), isNot(contains('Mine')));
    });

    test('deleted demo tasks come back, and stay on a refresh', () async {
      await stack.tasks.seedIfNeeded();
      for (final task in await tasks()) {
        await stack.tasks.delete(task.id);
      }

      await stack.tasks.resetDemoData();
      await stack.tasks.refresh();

      expect(await tasks(), hasLength(5));
    });

    test('offline: an Err, and nothing changes', () async {
      await stack.tasks.add(const TaskDraft(title: 'Mine'));
      stack.api.fail(const NetworkException());

      expect(await stack.tasks.resetDemoData(), isErr<NetworkException>());
      expect(await titles(), ['Mine']);
    });

    test('damaged data: an Err, and nothing changes', () async {
      await stack.tasks.add(const TaskDraft(title: 'Mine'));
      stack.api.answer([taskDto(title: '')]);

      expect(await stack.tasks.resetDemoData(), isErr<DataFormatException>());
      expect(await titles(), ['Mine']);
    });
  });

  test(
    'watchTasks is in the list\'s order, and follows every change',
    () async {
      await stack.tasks.seedIfNeeded();
      final seen = <List<String>>[];
      final subscription = stack.tasks.watchTasks().listen(
        (tasks) => seen.add([for (final task in tasks) task.title]),
      );
      await pumpEventQueue();

      await stack.tasks.add(TaskDraft(title: 'Due today', due: demoToday));
      await pumpEventQueue();
      await subscription.cancel();

      expect(seen.first, [
        'Swap the fake API for a real one', // overdue
        'Explore the architecture', // in 2 days
        'Rename the project', // no date, the newest
        'Welcome to Flutter Clean Starter',
        'Run the test suite', // done
      ]);
      expect(seen.last.take(2), [
        'Swap the fake API for a real one',
        'Due today',
      ]);
    },
  );

  test('watchTask is null for a task that does not exist', () async {
    expect(await stack.tasks.watchTask('nope').first, isNull);
  });
}
