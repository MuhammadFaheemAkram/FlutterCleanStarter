import 'package:drift/drift.dart';

// The sample feature's tables. A new feature adds its own file here, and
// lists its tables in `AppDatabase`.
//
// Instants are UTC ISO-8601 text (conventions §11.14): every `*_at` column
// must end in `Z`, so a local `DateTime` (written with its offset) is
// refused. Times are compared with `julianday`, not as text: `…00.000Z` and
// `…00.000500Z` don't sort as text in time order.

/// `CHECK (<column> GLOB '*Z')`: a UTC instant.
String _utc(String column) => "CHECK ($column GLOB '*Z')";

/// The user's tasks. The device owns them: the server only seeds them and
/// offers new ones on a refresh.
@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get notes => text().withDefault(const Constant(''))();

  /// A calendar day as `yyyymmdd` (`CalendarDate`), or `NULL`.
  IntColumn get dueDay => integer().nullable()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(title)) > 0)',
    'CHECK (due_day IS NULL OR due_day BETWEEN 10000101 AND 99991231)',
    _utc('created_at'),
    _utc('updated_at'),
    'CHECK (julianday(updated_at) >= julianday(created_at))',
  ];
}

/// A **tombstone** for each task the user deleted: the server still lists
/// it, and without a record of the deletion a refresh would bring it back.
@DataClassName('DeletedTaskRow')
class DeletedTasks extends Table {
  TextColumn get id => text()();

  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [_utc('deleted_at')];
}
