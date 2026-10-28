import 'package:flutter_clean_starter/domain/calculation/task_rules.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/task_fixtures.dart';

void main() {
  group('titleError', () {
    test('a title is required, spaces alone are not one', () {
      expect(TaskRules.titleError(''), 'Enter a title.');
      expect(TaskRules.titleError('   \n'), 'Enter a title.');
      expect(TaskRules.titleError('Buy milk'), isNull);
    });

    test('at most 80 characters, after trimming', () {
      expect(TaskRules.titleError('a' * 80), isNull);
      expect(TaskRules.titleError('  ${'a' * 80}  '), isNull);
      expect(
        TaskRules.titleError('a' * 81),
        'Keep the title to 80 characters or fewer.',
      );
    });

    test('counts what a reader sees as one character', () {
      // 👩‍💻 is 5 UTF-16 code units, and one character.
      const coder = '👩‍💻';
      expect(coder.length, 5);

      expect(TaskRules.titleError(coder * 80), isNull);
      expect(TaskRules.titleError(coder * 81), isNotNull);
      // é as e + a combining accent: two code units, one character.
      expect(TaskRules.titleError('é' * 80), isNull);
    });
  });

  group('notesError', () {
    test('notes are optional, and at most 1000 characters', () {
      expect(TaskRules.notesError(''), isNull);
      expect(TaskRules.notesError('a' * 1000), isNull);
      expect(
        TaskRules.notesError('a' * 1001),
        'Keep the notes to 1000 characters or fewer.',
      );
      expect(TaskRules.notesError('👍' * 1000), isNull);
    });
  });

  test('firstError reports the title before the notes', () {
    expect(
      TaskRules.firstError(title: '', notes: 'a' * 1001),
      'Enter a title.',
    );
    expect(TaskRules.firstError(title: 'ok', notes: 'a' * 1001), isNotNull);
    expect(TaskRules.firstError(title: 'ok', notes: ''), isNull);
  });

  group('isOverdue', () {
    final yesterday = demoToday.addDays(-1);

    test('an open task due before today is overdue', () {
      expect(isOverdue(task(due: yesterday), demoToday), isTrue);
    });

    test('a task due today is not overdue yet', () {
      expect(isOverdue(task(due: demoToday), demoToday), isFalse);
    });

    test('a done task never is', () {
      expect(
        isOverdue(task(due: yesterday, isCompleted: true), demoToday),
        isFalse,
      );
    });

    test('a task with no due date never is', () {
      expect(isOverdue(task(), demoToday), isFalse);
    });
  });

  group('compareTasks', () {
    List<String> order(List<Task> tasks) => [
      for (final task in [...tasks]..sort(compareTasks)) task.id,
    ];

    test('open tasks first, then done ones', () {
      expect(order([task(id: 'done', isCompleted: true), task(id: 'open')]), [
        'open',
        'done',
      ]);
    });

    test('then the soonest due date, and no date last', () {
      expect(
        order([
          task(id: 'none'),
          task(id: 'later', due: demoToday.addDays(5)),
          task(id: 'overdue', due: demoToday.addDays(-2)),
          task(id: 'soon', due: demoToday),
        ]),
        ['overdue', 'soon', 'later', 'none'],
      );
    });

    test('then the newest first, and the id breaks a tie', () {
      final at = DateTime.utc(2026, 10, 2);
      expect(
        order([
          task(id: 'old', createdAt: at),
          task(id: 'b', createdAt: at.add(const Duration(hours: 1))),
          task(id: 'a', createdAt: at.add(const Duration(hours: 1))),
        ]),
        ['a', 'b', 'old'],
      );
    });

    test('done tasks are ordered by the same rules', () {
      expect(
        order([
          task(id: 'done-none', isCompleted: true),
          task(id: 'done-due', isCompleted: true, due: demoToday),
          task(id: 'open-none'),
        ]),
        ['open-none', 'done-due', 'done-none'],
      );
    });
  });
}
