import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_clean_starter/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database.dart';

// The rules the database itself enforces on the task tables: whatever code
// writes, these rows can't exist. They are the last guard behind the use
// cases and the form.
void main() {
  late AppDatabase db;
  final at = DateTime.utc(2026, 10, 1, 9);

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  Matcher refused() => throwsA(isA<SqliteException>());

  Future<void> insert({
    String id = 't1',
    String title = 'Title',
    int? dueDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => db
      .into(db.tasks)
      .insert(
        TasksCompanion.insert(
          id: id,
          title: title,
          dueDay: Value(dueDay),
          createdAt: createdAt ?? at,
          updatedAt: updatedAt ?? createdAt ?? at,
        ),
      );

  test('a valid row is accepted', () async {
    await insert(dueDay: 20261029);
    expect(await db.select(db.tasks).get(), hasLength(1));
  });

  test('a title must have more than spaces', () {
    expect(insert(title: ''), refused());
    expect(insert(title: '   '), refused());
  });

  test('a due day must look like yyyymmdd', () {
    expect(insert(dueDay: 0), refused());
    expect(insert(dueDay: 2026102), refused());
  });

  test('times must be UTC: a local time is refused', () {
    expect(insert(createdAt: DateTime(2026, 10, 1, 9)), refused());
    expect(insert(updatedAt: DateTime(2026, 10, 2, 9)), refused());
  });

  test('an update can not come before the creation', () async {
    expect(
      insert(updatedAt: at.subtract(const Duration(microseconds: 1000))),
      refused(),
    );
    // Compared as times, not text: "…00.000Z" sorts after "…00.000500Z".
    await insert(updatedAt: at.add(const Duration(microseconds: 500)));
  });

  test('an id is unique', () async {
    await insert();
    expect(insert(title: 'Other'), refused());
  });

  test('tombstone times must be UTC', () {
    expect(
      db
          .into(db.deletedTasks)
          .insert(
            DeletedTasksCompanion.insert(
              id: 't1',
              deletedAt: DateTime(2026, 10, 2),
            ),
          ),
      refused(),
    );
  });

  test('times are stored as UTC ISO-8601 text', () async {
    await insert(createdAt: DateTime.utc(2026, 10, 1, 9, 30, 0, 123));

    final stored = await db
        .customSelect('SELECT created_at FROM tasks')
        .getSingle();
    expect(stored.data['created_at'], '2026-10-01T09:30:00.123Z');
  });
}
