import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_clean_starter/features/task_form/cubit/task_form_cubit.dart';
import 'package:flutter_clean_starter/features/task_form/cubit/task_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/task_fixtures.dart';
import '../../../helpers/tasks_data_stack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack stack;
  final cubits = <TaskFormCubit>[];

  setUp(() async {
    stack = await DataStack.create();
    await stack.tasks.seedIfNeeded();
  });

  tearDown(() async {
    for (final cubit in cubits) {
      await cubit.close();
    }
    cubits.clear();
    await stack.close();
  });

  Future<TaskFormCubit> form([String? id]) async {
    final cubit = TaskFormCubit(
      id,
      WatchTaskUseCase(stack.tasks),
      AddTaskUseCase(stack.tasks),
      UpdateTaskUseCase(stack.tasks),
      stack.clock,
    );
    cubits.add(cubit);
    await cubit.load();
    return cubit;
  }

  Future<Task> stored(String id) async =>
      (await stack.tasks.watchTask(id).first)!;

  Future<List<Task>> all() => stack.tasks.watchTasks().first;

  group('a new task', () {
    test('opens empty, editable, with no errors and no changes', () async {
      final cubit = await form();

      expect(cubit.state.status, TaskFormStatus.editing);
      expect(cubit.state.isEditing, isFalse);
      expect(cubit.state.titleError, isNull);
      expect(cubit.state.hasChanges, isFalse);
      expect(cubit.state.today, demoToday);
    });

    test('Save with no title shows the error and saves nothing', () async {
      final cubit = await form();

      final statuses = <TaskFormStatus>[];
      final subscription = cubit.stream.listen((s) => statuses.add(s.status));
      await cubit.save();
      await subscription.cancel();

      expect(cubit.state.titleError, 'Enter a title.');
      // Refused here, by the form's own rules: never sent to be saved.
      expect(statuses, isNot(contains(TaskFormStatus.saving)));
      expect(cubit.state.saveError, isNull);
      expect(await all(), hasLength(5));
    });

    test('errors follow the text once shown', () async {
      final cubit = await form();
      await cubit.save();

      cubit.titleChanged('Fixed');
      expect(cubit.state.titleError, isNull);
      cubit.notesChanged('a' * 1001);
      expect(cubit.state.notesError, isNotNull);
    });

    test('a valid task is saved, and the form says so (once)', () async {
      final cubit = await form();
      final day = CalendarDate(2026, 11, 2);
      cubit
        ..titleChanged('  Write the release notes ')
        ..notesChanged('For 1.0')
        ..dueChanged(day);

      final statuses = <TaskFormStatus>[];
      final subscription = cubit.stream.listen((s) => statuses.add(s.status));
      await cubit.save();
      await subscription.cancel();

      expect(statuses, contains(TaskFormStatus.saving));
      expect(cubit.state.status, TaskFormStatus.saved);
      final added = (await all()).firstWhere(
        (t) => t.title == 'Write the release notes',
      );
      expect(added.notes, 'For 1.0');
      expect(added.due, day);
    });

    test('a second Save while saving does nothing', () async {
      final cubit = await form();
      cubit.titleChanged('Once');

      await Future.wait([cubit.save(), cubit.save()]);

      expect((await all()).where((t) => t.title == 'Once'), hasLength(1));
    });

    test('anything typed counts as a change; spaces alone do not', () async {
      final cubit = await form();

      cubit.titleChanged('   ');
      expect(cubit.state.hasChanges, isFalse);
      cubit.dueChanged(demoToday);
      expect(cubit.state.hasChanges, isTrue);
      cubit.dueChanged(null);
      cubit.notesChanged('x');
      expect(cubit.state.hasChanges, isTrue);
    });
  });

  group('editing', () {
    test('opens on the stored task', () async {
      final original = await stored(demoTaskId);
      final cubit = await form(demoTaskId);

      expect(cubit.state.status, TaskFormStatus.editing);
      expect(cubit.state.original, original);
      expect(cubit.state.title, original.title);
      expect(cubit.state.notes, original.notes);
      expect(cubit.state.due, original.due);
      expect(cubit.state.isCompleted, isFalse);
      expect(cubit.state.hasChanges, isFalse);
    });

    test('starts loading until the task is read', () {
      final cubit = TaskFormCubit(
        demoTaskId,
        WatchTaskUseCase(stack.tasks),
        AddTaskUseCase(stack.tasks),
        UpdateTaskUseCase(stack.tasks),
        stack.clock,
      );
      cubits.add(cubit);
      expect(cubit.state.status, TaskFormStatus.loading);
    });

    test('a task that does not exist is not found', () async {
      expect((await form('nope')).state.status, TaskFormStatus.notFound);
    });

    test('saves every field, and the done switch', () async {
      final cubit = await form(demoTaskId);
      cubit
        ..titleChanged('Read ARCHITECTURE.md')
        ..notesChanged('')
        ..dueChanged(null)
        ..completedChanged(completed: true);

      await cubit.save();

      final task = await stored(demoTaskId);
      expect(task.title, 'Read ARCHITECTURE.md');
      expect(task.notes, '');
      expect(task.due, isNull);
      expect(task.isCompleted, isTrue);
      expect(cubit.state.status, TaskFormStatus.saved);
    });

    test(
      'a change elsewhere after opening does not overwrite the fields',
      () async {
        final cubit = await form(demoTaskId);
        cubit.titleChanged('Mine');

        final current = await stored(demoTaskId);
        await stack.tasks.update(current.copyWith(title: 'Theirs'));
        await pumpEventQueue();

        expect(cubit.state.title, 'Mine');
      },
    );

    test('changing a field back is no change', () async {
      final cubit = await form(demoTaskId);
      final title = cubit.state.title;

      cubit.titleChanged('Other');
      expect(cubit.state.hasChanges, isTrue);
      cubit.titleChanged(title);
      expect(cubit.state.hasChanges, isFalse);
      cubit.completedChanged(completed: true);
      expect(cubit.state.hasChanges, isTrue);
    });

    test('a failed save stays editing and says why', () async {
      final cubit = await form(demoTaskId);
      await stack.tasks.delete(demoTaskId);
      cubit.titleChanged('Too late');

      await cubit.save();

      expect(cubit.state.status, TaskFormStatus.editing);
      expect(cubit.state.saveError, "That task doesn't exist any more.");
    });
  });
}
