import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_clean_starter/core/database/daos/tasks_dao.dart';
import 'package:flutter_clean_starter/core/database/tables/tasks.dart';

part 'app_database.g.dart';

/// The app's SQLite database: the **source of truth** every screen reads.
///
/// Screens watch its streams, never the API: the app works offline, and a
/// write anywhere (a toggle, a refresh) reaches every screen showing that
/// data. A new feature adds its tables and DAO to the lists below.
///
/// This file and the rest of `core/database/` never import `material_ui` or
/// the JSON packages: drift exports `Table`, `Column` and `JsonKey`, and
/// those names would clash (conventions §11.1).
@DriftDatabase(tables: [Tasks, DeletedTasks], daos: [TasksDao])
class AppDatabase extends _$AppDatabase {
  /// Opens `app.sqlite` in the app's documents directory. Tests pass an
  /// in-memory [executor] instead.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'app'));

  /// A change to the schema bumps this, exports the new version
  /// (`fvm dart run drift_dev make-migrations`) and ships a tested
  /// migration (the generated tests in `test/drift/`).
  ///
  /// 1. The first release: tasks and their tombstones.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // SQLite ships with foreign keys *off*, per connection. No table has one
    // yet; the pragma is here so the first `REFERENCES` a new feature adds
    // is enforced.
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
