import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';

/// The user's tasks: stored on the device, seeded and refreshed from the
/// server.
///
/// A *contract* in the domain layer, implemented in the data layer
/// (`TaskRepositoryImpl`). Use cases depend on this interface only, so a
/// test can hand them a fake, and replacing the storage or the API changes
/// one class.
///
/// Reads are streams from the database (the single source of truth): a
/// screen watching them sees every change, whoever made it. Writes return a
/// [Result] and never throw.
abstract interface class TaskRepository {
  /// Every task, in the list's order (`compareTasks`).
  Stream<List<Task>> watchTasks();

  /// One task, then every change to it; `null` while it doesn't exist.
  Stream<Task?> watchTask(String id);

  /// On first launch only, writes the server's tasks; the number written
  /// (0 when the store was already seeded).
  Future<Result<int>> seedIfNeeded();

  /// Adds the server's tasks the device doesn't have yet; the number added.
  /// Never overwrites a local edit, never brings back a deleted task.
  Future<Result<int>> refresh();

  /// Saves a new task; the saved task, with its id and times.
  Future<Result<Task>> add(TaskDraft draft);

  /// Saves [task]'s title, notes, due date and done state.
  Future<Result<void>> update(Task task);

  Future<Result<void>> setCompleted(String id, {required bool completed});

  /// Deletes a task; the deleted task, for Undo.
  Future<Result<Task>> delete(String id);

  /// Undo: puts [task] back exactly as it was.
  Future<Result<void>> restore(Task task);

  /// Replaces every task with the server's; the number written.
  Future<Result<int>> resetDemoData();
}
