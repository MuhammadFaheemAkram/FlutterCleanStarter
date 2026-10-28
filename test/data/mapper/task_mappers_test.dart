import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/data/mapper/task_mappers.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/task_fixtures.dart';

void main() {
  group('TaskDto → Task', () {
    test('maps every field, the due day included', () {
      final created = DateTime.utc(2026, 10, 1, 9);
      final updated = DateTime.utc(2026, 10, 2, 9);

      final task = taskDto(
        id: 'server-1',
        title: '  Plan the sprint ',
        notes: 'Notes',
        due: '2026-11-02',
        isCompleted: true,
        createdAt: created,
        updatedAt: updated,
      ).toTask();

      expect(task.id, 'server-1');
      expect(task.title, 'Plan the sprint');
      expect(task.notes, 'Notes');
      expect(task.due, CalendarDate(2026, 11, 2));
      expect(task.isCompleted, isTrue);
      expect(task.createdAt, created);
      expect(task.updatedAt, updated);
    });

    test('no due date stays none', () {
      expect(taskDto().toTask().due, isNull);
    });

    final damaged = {
      'an empty id': taskDto(id: ' '),
      'an empty title': taskDto(title: '  '),
      'a title too long': taskDto(title: 'a' * 81),
      'notes too long': taskDto(notes: 'a' * 1001),
      'a due date that is not a day': taskDto(due: '2026-02-30'),
      'a due date with a time': taskDto(due: '2026-10-30T10:00:00Z'),
      'a local creation time': taskDto(createdAt: DateTime(2026, 10, 1, 9)),
      'a local update time': taskDto(
        createdAt: DateTime.utc(2026, 10, 3),
        updatedAt: DateTime(2026, 10, 4),
      ),
      'an update before the creation': taskDto(
        createdAt: DateTime.utc(2026, 10, 3),
        updatedAt: DateTime.utc(2026, 10, 2),
      ),
    };
    for (final MapEntry(key: name, value: dto) in damaged.entries) {
      test('refuses $name', () {
        expect(dto.toTask, throwsA(isA<DataFormatException>()));
      });
    }

    test('a list with two tasks sharing an id is refused whole', () {
      expect(
        [taskDto(id: 'a'), taskDto(id: 'a', title: 'Other')].toTasks,
        throwsA(isA<DataFormatException>()),
      );
      expect([taskDto(id: 'a'), taskDto(id: 'b')].toTasks(), hasLength(2));
    });
  });

  test('Task → TaskRow → Task is lossless', () {
    final original = task(
      notes: 'Notes',
      due: CalendarDate(2026, 12, 31),
      isCompleted: true,
      createdAt: DateTime.utc(2026, 10, 1, 9, 30, 15, 123, 456),
      updatedAt: DateTime.utc(2026, 10, 2, 8),
    );

    final row = original.toRow();
    expect(row.dueDay, 20261231);
    expect(row.toTask(), original);
  });
}
