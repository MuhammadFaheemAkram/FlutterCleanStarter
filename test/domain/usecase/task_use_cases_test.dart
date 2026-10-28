import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/data_stack.dart';
import '../../helpers/result_matchers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack stack;

  setUp(() async => stack = await DataStack.create());
  tearDown(() => stack.close());

  Future<List<Task>> stored() => WatchTasksUseCase(stack.tasks)().first;

  group('AddTaskUseCase', () {
    test('saves a valid draft', () async {
      final result = await AddTaskUseCase(stack.tasks)(
        const TaskDraft(title: 'Valid'),
      );

      expect(result, isOk(isA<Task>()));
      expect(await stored(), hasLength(1));
    });

    test(
      'refuses what the form would, saying why, and writes nothing',
      () async {
        final add = AddTaskUseCase(stack.tasks);

        expect(
          await add(const TaskDraft(title: '  ')),
          isErrSaying('Enter a title.'),
        );
        expect(
          await add(TaskDraft(title: 'a' * 81)),
          isErr<InvalidInputException>(),
        );
        expect(
          await add(TaskDraft(title: 'ok', notes: 'a' * 1001)),
          isErrSaying('Keep the notes to 1000 characters or fewer.'),
        );
        expect(await stored(), isEmpty);
      },
    );
  });

  group('UpdateTaskUseCase', () {
    test('saves a valid task, and refuses an invalid one', () async {
      await AddTaskUseCase(stack.tasks)(const TaskDraft(title: 'Before'));
      final task = (await stored()).single;
      final update = UpdateTaskUseCase(stack.tasks);

      expect(
        await update(task.copyWith(title: '')),
        isErr<InvalidInputException>(),
      );
      expect((await stored()).single.title, 'Before');

      expect(await update(task.copyWith(title: 'After')), isOk());
      expect((await stored()).single.title, 'After');
    });
  });

  test('the other task use cases reach the repository', () async {
    expect(await SeedTasksUseCase(stack.tasks)(), isOk(5));
    final first = (await stored()).first;

    expect(
      await SetTaskCompletedUseCase(stack.tasks)(first.id, completed: true),
      isOk(),
    );
    expect(
      (await WatchTaskUseCase(stack.tasks)(first.id).first)!.isCompleted,
      isTrue,
    );

    final deleted = await DeleteTaskUseCase(stack.tasks)(first.id);
    expect(await stored(), hasLength(4));

    final undo = RestoreTaskUseCase(stack.tasks);
    expect(await undo((deleted as Ok<Task>).value), isOk());
    expect(await stored(), hasLength(5));

    expect(await RefreshTasksUseCase(stack.tasks)(), isOk(0));
    expect(await ResetDemoDataUseCase(stack.tasks)(), isOk(5));
    expect(await stored(), hasLength(5));
  });
}
