import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/tasks_data_stack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack stack;
  late TasksDemoCubit cubit;

  setUp(() async {
    stack = await DataStack.create();
    await stack.tasks.seedIfNeeded();
    cubit = TasksDemoCubit(ResetDemoDataUseCase(stack.tasks));
  });

  tearDown(() async {
    await cubit.close();
    await stack.close();
  });

  Future<List<String>> titles() async => [
    for (final task in await stack.tasks.watchTasks().first) task.title,
  ];

  test('replaces every task with the sample ones, and says so', () async {
    await stack.tasks.add(const TaskDraft(title: 'Mine'));
    final first = (await stack.tasks.watchTasks().first).first;
    await stack.tasks.delete(first.id);

    await cubit.reset();

    expect(cubit.state.message, 'Demo data restored: 5 tasks.');
    expect(cubit.state.messageSerial, 1);
    expect(cubit.state.resetting, isFalse);
    expect(await titles(), hasLength(5));
    expect(await titles(), isNot(contains('Mine')));
  });

  test('offline: says why, and nothing changes', () async {
    await stack.tasks.add(const TaskDraft(title: 'Mine'));
    stack.api.fail(const NetworkException());

    await cubit.reset();

    expect(cubit.state.message, const NetworkException().message);
    expect(await titles(), contains('Mine'));
    expect(await titles(), hasLength(6));
  });

  test('resetting while a reset runs does nothing', () async {
    await Future.wait([cubit.reset(), cubit.reset()]);

    expect(stack.api.calls, 2); // the seed, then one reset
    expect(cubit.state.messageSerial, 1);
  });
}
