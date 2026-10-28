import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/common/guard_write.dart';
import 'package:flutter_clean_starter/core/common/id_generator.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/core/database/app_database.dart';
import 'package:flutter_clean_starter/core/database/daos/tasks_dao.dart';
import 'package:flutter_clean_starter/core/network/task_api.dart';
import 'package:flutter_clean_starter/core/storage/tasks_preferences.dart';
import 'package:flutter_clean_starter/data/mapper/task_mappers.dart';
import 'package:flutter_clean_starter/domain/calculation/task_rules.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/repository/task_repository.dart';
import 'package:injectable/injectable.dart';

/// The default [TaskRepository]: drift is the source of truth, the API only
/// seeds and refreshes it.
///
/// - **Offline-first:** every read is a drift stream. The API is called by
///   the seed, a refresh and a reset only; when it fails, the stored tasks
///   stay as they were and the `Err` says why.
/// - **The device owns the tasks:** adding, editing, completing and deleting
///   are local writes. A refresh *adds* the server's new tasks and never
///   overwrites one the device has (insert-or-ignore), and a tombstone keeps
///   a deleted task from coming back.
/// - **Times come from the injected [Clock]**, in UTC, so tests fix them.
@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(
    this._api,
    this._dao,
    this._preferences,
    this._clock,
    this._ids,
  );

  final TaskApi _api;
  final TasksDao _dao;
  final TasksPreferences _preferences;
  final Clock _clock;
  final IdGenerator _ids;

  /// The seed in progress, if any: a second call while it runs gets the same
  /// answer instead of seeding twice.
  Future<Result<int>>? _seeding;

  @override
  Stream<List<Task>> watchTasks() => _dao.watchAll().map(
    (rows) => [for (final row in rows) row.toTask()]..sort(compareTasks),
  );

  @override
  Stream<Task?> watchTask(String id) =>
      _dao.watchById(id).map((row) => row?.toTask());

  @override
  Future<Result<int>> seedIfNeeded() =>
      _seeding ??= _seed().whenComplete(() => _seeding = null);

  Future<Result<int>> _seed() async {
    if (_preferences.seeded) return const Ok(0);
    return guardWrite('Seeding the tasks', () async {
      // Tasks but no flag: a seed committed and the flag's write was lost.
      // The store is seeded; only the flag is missing.
      if (await _dao.countTasks() > 0) {
        await _preferences.markSeeded();
        return 0;
      }
      final rows = await _fetchRows();
      await _dao.insertAll(rows);
      // Only now: had the insert failed, the next launch would seed again.
      await _preferences.markSeeded();
      return rows.length;
    });
  }

  @override
  Future<Result<int>> refresh() => guardWrite(
    'Refreshing the tasks',
    () async => _dao.mergeServerTasks(await _fetchRows()),
  );

  @override
  Future<Result<Task>> add(TaskDraft draft) =>
      guardWrite('Adding a task', () async {
        final now = _now();
        final task = Task(
          id: _ids(),
          title: draft.title.trim(),
          notes: draft.notes,
          due: draft.due,
          createdAt: now,
          updatedAt: now,
        );
        await _dao.insertTask(task.toRow());
        return task;
      });

  /// Writes what the user can change, and a new `updatedAt`. `createdAt` is
  /// never written: whatever [task] says, a task's creation time stays.
  @override
  Future<Result<void>> update(Task task) => guardWrite(
    'Updating a task',
    () => _write(
      task.id,
      TasksCompanion(
        title: Value(task.title.trim()),
        notes: Value(task.notes),
        dueDay: Value(task.due?.yyyymmdd),
        isCompleted: Value(task.isCompleted),
      ),
    ),
  );

  @override
  Future<Result<void>> setCompleted(String id, {required bool completed}) =>
      guardWrite(
        'Completing a task',
        () => _write(id, TasksCompanion(isCompleted: Value(completed))),
      );

  @override
  Future<Result<Task>> delete(String id) =>
      guardWrite('Deleting a task', () async {
        final row = await _dao.deleteWithTombstone(id, _now());
        if (row == null) throw const NotFoundException('task');
        return row.toTask();
      });

  @override
  Future<Result<void>> restore(Task task) =>
      guardWrite('Restoring a task', () => _dao.restore(task.toRow()));

  @override
  Future<Result<int>> resetDemoData() =>
      guardWrite('Resetting the demo', () async {
        // Fetched first: offline, the throw comes before anything is deleted.
        final rows = await _fetchRows();
        await _dao.replaceAll(rows);
        await _preferences.markSeeded();
        return rows.length;
      });

  /// Writes [changes] and a new `updatedAt` to task [id].
  Future<void> _write(String id, TasksCompanion changes) async {
    final written = await _dao.updateTask(
      id,
      changes.copyWith(updatedAt: Value(_now())),
    );
    if (written == 0) throw const NotFoundException('task');
  }

  /// The server's tasks as rows, checked: a `NetworkException` or a
  /// `DataFormatException` before anything is written.
  Future<List<TaskRow>> _fetchRows() async => [
    for (final task in (await _api.fetchTasks()).toTasks()) task.toRow(),
  ];

  DateTime _now() => _clock.now().toUtc();
}
