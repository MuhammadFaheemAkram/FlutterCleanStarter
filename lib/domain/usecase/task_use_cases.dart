import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/calculation/task_rules.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/repository/task_repository.dart';
import 'package:injectable/injectable.dart';

// One use case per user action. Most only forward to the repository: they
// are the place a rule that spans repositories, or a check before a write,
// would go, and they keep Cubits from depending on the repository's whole
// surface. A Cubit takes exactly the actions its screen offers.

@injectable
class WatchTasksUseCase {
  const WatchTasksUseCase(this._tasks);

  final TaskRepository _tasks;

  Stream<List<Task>> call() => _tasks.watchTasks();
}

@injectable
class WatchTaskUseCase {
  const WatchTaskUseCase(this._tasks);

  final TaskRepository _tasks;

  Stream<Task?> call(String id) => _tasks.watchTask(id);
}

/// The first launch's seed (a no-op afterwards).
@injectable
class SeedTasksUseCase {
  const SeedTasksUseCase(this._tasks);

  final TaskRepository _tasks;

  Future<Result<int>> call() => _tasks.seedIfNeeded();
}

/// Pull to refresh.
@injectable
class RefreshTasksUseCase {
  const RefreshTasksUseCase(this._tasks);

  final TaskRepository _tasks;

  Future<Result<int>> call() => _tasks.refresh();
}

/// Checks the draft with the same [TaskRules] the form shows, then saves it.
@injectable
class AddTaskUseCase {
  const AddTaskUseCase(this._tasks);

  final TaskRepository _tasks;

  Future<Result<Task>> call(TaskDraft draft) async {
    final error = TaskRules.firstError(title: draft.title, notes: draft.notes);
    if (error != null) return Err(InvalidInputException(error));
    return _tasks.add(draft);
  }
}

/// Checks the task with the same [TaskRules] the form shows, then saves it.
@injectable
class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._tasks);

  final TaskRepository _tasks;

  Future<Result<void>> call(Task task) async {
    final error = TaskRules.firstError(title: task.title, notes: task.notes);
    if (error != null) return Err(InvalidInputException(error));
    return _tasks.update(task);
  }
}

@injectable
class SetTaskCompletedUseCase {
  const SetTaskCompletedUseCase(this._tasks);

  final TaskRepository _tasks;

  Future<Result<void>> call(String id, {required bool completed}) =>
      _tasks.setCompleted(id, completed: completed);
}

@injectable
class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._tasks);

  final TaskRepository _tasks;

  Future<Result<Task>> call(String id) => _tasks.delete(id);
}

/// Undo after a delete.
@injectable
class RestoreTaskUseCase {
  const RestoreTaskUseCase(this._tasks);

  final TaskRepository _tasks;

  Future<Result<void>> call(Task task) => _tasks.restore(task);
}

/// Settings → Reset demo data. Offline, nothing changes.
@injectable
class ResetDemoDataUseCase {
  const ResetDemoDataUseCase(this._tasks);

  final TaskRepository _tasks;

  Future<Result<int>> call() => _tasks.resetDemoData();
}
