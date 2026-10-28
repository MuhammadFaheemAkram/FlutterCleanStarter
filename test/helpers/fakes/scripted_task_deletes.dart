import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/repository/task_repository.dart';

/// The real repository, except that a delete can be answered without
/// touching the store: as if the database hadn't reported it yet, or had
/// refused it.
class ScriptedDeletes implements TaskRepository {
  ScriptedDeletes(this._real);

  final TaskRepository _real;

  /// When set, a delete answers this and changes nothing.
  Result<Task>? deleteAnswer;

  @override
  Future<Result<Task>> delete(String id) async =>
      deleteAnswer ?? await _real.delete(id);

  @override
  Stream<List<Task>> watchTasks() => _real.watchTasks();

  @override
  Stream<Task?> watchTask(String id) => _real.watchTask(id);

  @override
  Future<Result<int>> seedIfNeeded() => _real.seedIfNeeded();

  @override
  Future<Result<int>> refresh() => _real.refresh();

  @override
  Future<Result<Task>> add(TaskDraft draft) => _real.add(draft);

  @override
  Future<Result<void>> update(Task task) => _real.update(task);

  @override
  Future<Result<void>> setCompleted(String id, {required bool completed}) =>
      _real.setCompleted(id, completed: completed);

  @override
  Future<Result<void>> restore(Task task) => _real.restore(task);

  @override
  Future<Result<int>> resetDemoData() => _real.resetDemoData();
}
