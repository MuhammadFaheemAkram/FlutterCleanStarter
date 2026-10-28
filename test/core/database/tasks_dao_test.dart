import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_clean_starter/core/database/app_database.dart';
import 'package:flutter_clean_starter/core/database/daos/tasks_dao.dart';
import 'package:flutter_clean_starter/data/mapper/task_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database.dart';
import '../../helpers/task_fixtures.dart';

void main() {
  late AppDatabase db;
  late TasksDao dao;
  final deletedAt = DateTime.utc(2026, 10, 20);

  setUp(() {
    db = newTestDatabase();
    dao = db.tasksDao;
  });
  tearDown(() => db.close());

  TaskRow row(String id, {String title = 'Title'}) =>
      task(id: id, title: title).toRow();

  Future<List<String>> ids() async =>
      [for (final row in await db.select(db.tasks).get()) row.id]..sort();

  Future<List<String>> tombstones() async =>
      [for (final row in await db.select(db.deletedTasks).get()) row.id]
        ..sort();

  test('insertAll writes every row, or none', () async {
    await dao.insertAll([row('a'), row('b')]);
    expect(await ids(), ['a', 'b']);

    // The second row breaks a CHECK: the first isn't kept either.
    expect(dao.insertAll([row('c'), row('d', title: ' ')]), throwsA(anything));
    await pumpEventQueue();
    expect(await ids(), ['a', 'b']);
  });

  test('countTasks', () async {
    expect(await dao.countTasks(), 0);
    await dao.insertAll([row('a'), row('b')]);
    expect(await dao.countTasks(), 2);
  });

  group('mergeServerTasks', () {
    test('adds only the tasks the device does not have', () async {
      await dao.insertAll([row('a')]);

      final added = await dao.mergeServerTasks([row('a'), row('b')]);

      expect(added, 1);
      expect(await ids(), ['a', 'b']);
    });

    test('never overwrites a local edit', () async {
      await dao.insertAll([row('a', title: 'Mine')]);

      await dao.mergeServerTasks([row('a', title: "The server's")]);

      expect((await dao.findById('a'))!.title, 'Mine');
    });

    test('never brings back a deleted task', () async {
      await dao.insertAll([row('a')]);
      await dao.deleteWithTombstone('a', deletedAt);

      final added = await dao.mergeServerTasks([row('a'), row('b')]);

      expect(added, 1);
      expect(await ids(), ['b']);
    });

    test('adds nothing when a row is damaged', () async {
      expect(
        dao.mergeServerTasks([row('a'), row('b', title: '')]),
        throwsA(anything),
      );
      await pumpEventQueue();
      expect(await ids(), isEmpty);
    });
  });

  test('updateTask changes one row and says how many', () async {
    await dao.insertAll([row('a'), row('b')]);

    expect(
      await dao.updateTask('a', const TasksCompanion(title: Value('New'))),
      1,
    );
    expect((await dao.findById('a'))!.title, 'New');
    expect((await dao.findById('b'))!.title, 'Title');
    expect(
      await dao.updateTask('nope', const TasksCompanion(title: Value('X'))),
      0,
    );
  });

  group('delete and restore', () {
    test('a delete removes the row and writes its tombstone', () async {
      await dao.insertAll([row('a')]);

      final deleted = await dao.deleteWithTombstone('a', deletedAt);

      expect(deleted, row('a'));
      expect(await ids(), isEmpty);
      expect(await tombstones(), ['a']);
    });

    test('deleting a missing task changes nothing', () async {
      expect(await dao.deleteWithTombstone('nope', deletedAt), isNull);
      expect(await tombstones(), isEmpty);
    });

    test(
      'restore puts the row back exactly, and drops the tombstone',
      () async {
        await dao.insertAll([row('a')]);
        final deleted = (await dao.deleteWithTombstone('a', deletedAt))!;

        await dao.restore(deleted);

        expect(await dao.findById('a'), deleted);
        expect(await tombstones(), isEmpty);
      },
    );

    test('restoring twice keeps one row', () async {
      await dao.insertAll([row('a')]);
      final deleted = (await dao.deleteWithTombstone('a', deletedAt))!;

      await dao.restore(deleted);
      await dao.restore(deleted);

      expect(await ids(), ['a']);
    });
  });

  test(
    'replaceAll clears tasks and tombstones, then writes the rows',
    () async {
      await dao.insertAll([row('a'), row('b')]);
      await dao.deleteWithTombstone('b', deletedAt);

      await dao.replaceAll([row('b'), row('c')]);

      expect(await ids(), ['b', 'c']);
      expect(await tombstones(), isEmpty);
    },
  );

  test('replaceAll with a damaged row keeps everything as it was', () async {
    await dao.insertAll([row('a')]);
    await dao.deleteWithTombstone('a', deletedAt);
    await dao.insertAll([row('k')]);

    expect(dao.replaceAll([row('b'), row('c', title: '')]), throwsA(anything));
    await pumpEventQueue();

    expect(await ids(), ['k']);
    expect(await tombstones(), ['a']);
  });

  test('watchById follows one task, and null once it is gone', () async {
    await dao.insertAll([row('a')]);
    final seen = <String?>[];
    final subscription = dao.watchById('a').listen((r) => seen.add(r?.title));
    await pumpEventQueue();

    await dao.updateTask('a', const TasksCompanion(title: Value('New')));
    await pumpEventQueue();
    await dao.deleteWithTombstone('a', deletedAt);
    await pumpEventQueue();
    await subscription.cancel();

    expect(seen, ['Title', 'New', null]);
  });
}
