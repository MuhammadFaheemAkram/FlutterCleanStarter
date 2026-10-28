import 'package:drift/drift.dart';
import 'package:flutter_clean_starter/core/database/app_database.dart';
import 'package:flutter_clean_starter/core/database/tables/tasks.dart';

part 'tasks_dao.g.dart';

/// Every query and write on the task tables.
///
/// A DAO keeps SQL out of the repository: the repository decides *what*
/// happens (seed, merge, delete with Undo), the DAO *how* it is stored.
/// Writes that belong together run in one transaction, so a failure halfway
/// leaves nothing half-written (conventions §11.53).
@DriftAccessor(tables: [Tasks, DeletedTasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.attachedDatabase);

  /// Every task, then every change. Unordered: the domain's `compareTasks`
  /// orders them.
  Stream<List<TaskRow>> watchAll() => select(tasks).watch();

  Stream<TaskRow?> watchById(String id) =>
      (select(tasks)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<TaskRow?> findById(String id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> countTasks() async {
    final count = tasks.id.count();
    final query = selectOnly(tasks)..addColumns([count]);
    return (await query.getSingle()).read(count)!;
  }

  /// The first launch's seed: every row, or none.
  Future<void> insertAll(List<TaskRow> rows) =>
      batch((batch) => batch.insertAll(tasks, rows));

  /// A refresh: adds the server's [rows] the device doesn't have, in one
  /// transaction; the number added.
  ///
  /// `ON CONFLICT (id) DO NOTHING` keeps every stored row as it is, so a
  /// local edit is never overwritten (`REPLACE` would delete it and insert
  /// the server's). A tombstoned id is skipped, so a deleted task never
  /// comes back.
  ///
  /// Not `INSERT OR IGNORE`: that also skips a row breaking a `CHECK`,
  /// silently, where this refuses it and rolls the transaction back.
  Future<int> mergeServerTasks(List<TaskRow> rows) => transaction(() async {
    final deleted =
        await (selectOnly(deletedTasks)
              ..addColumns([deletedTasks.id])
              ..where(deletedTasks.id.isIn(rows.map((row) => row.id))))
            .map((row) => row.read(deletedTasks.id)!)
            .get();
    final skip = deleted.toSet();
    var added = 0;
    for (final row in rows) {
      if (skip.contains(row.id)) continue;
      final inserted = await into(tasks)
          .insertReturningOrNull(row, onConflict: DoNothing());
      if (inserted != null) added++;
    }
    return added;
  });

  Future<void> insertTask(TaskRow row) => into(tasks).insert(row);

  /// Writes [changes] to task [id]; the number of rows changed (0 when it
  /// doesn't exist).
  Future<int> updateTask(String id, TasksCompanion changes) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(changes);

  /// Deletes task [id] and records its tombstone, in one transaction; the
  /// deleted row (for Undo), or `null` when there was none.
  Future<TaskRow?> deleteWithTombstone(String id, DateTime deletedAt) =>
      transaction(() async {
        final row = await findById(id);
        if (row == null) return null;
        await (delete(tasks)..where((t) => t.id.equals(id))).go();
        await into(deletedTasks).insertOnConflictUpdate(
          DeletedTasksCompanion.insert(id: id, deletedAt: deletedAt),
        );
        return row;
      });

  /// Undo: puts [row] back as it was and removes its tombstone, in one
  /// transaction. A row that is already back stays as it is.
  Future<void> restore(TaskRow row) => transaction(() async {
    await into(tasks).insert(row, onConflict: DoNothing());
    await (delete(deletedTasks)..where((t) => t.id.equals(row.id))).go();
  });

  /// Reset: every task and tombstone goes, then [rows] are written, in one
  /// transaction.
  Future<void> replaceAll(List<TaskRow> rows) => transaction(() async {
    await delete(tasks).go();
    await delete(deletedTasks).go();
    await batch((batch) => batch.insertAll(tasks, rows));
  });
}
