import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/repository/task_repository.dart';
import 'package:flutter_clean_starter/features/task_detail/task_detail_page.dart';
import 'package:flutter_clean_starter/features/task_form/task_form_page.dart';
import 'package:flutter_clean_starter/features/tasks/widgets/task_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';
import '../helpers/task_fixtures.dart';

// Task detail and the Add / Edit form on the real DI graph.
void main() {
  tearDown(getIt.reset);

  Future<List<Task>> stored(WidgetTester tester) async => (await tester
      .runAsync(() => getIt<TaskRepository>().watchTasks().first))!;

  /// The form's own field (the page beneath has none, but a dialog's text
  /// can match the page underneath, conventions §11.77).
  Finder field(String label) => find.descendant(
    of: find.byType(TaskFormView),
    matching: find.widgetWithText(TextField, label),
  );

  Future<void> save(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(TaskFormView),
        matching: find.widgetWithText(FilledButton, 'Save'),
      ),
    );
    await tester.settleRealAsync();
  }

  group('adding', () {
    testWidgets('Add → type → Save: back on the list, with the new task', (
      tester,
    ) async {
      await pumpStarter(tester);

      await tester.tapAndSettle(find.byTooltip('Add task'));
      await tester.enterText(field('Title'), 'Water the plants');
      await save(tester);
      await tester.pumpUntilFound(find.text('Water the plants'));

      expect(find.byType(TaskFormView), findsNothing);
      expect(find.byType(TaskCard), findsNWidgets(6));
      expect(await stored(tester), hasLength(6));
    });

    testWidgets('Save with no title: the error, and nothing saved', (
      tester,
    ) async {
      await pumpStarter(tester);

      await tester.tapAndSettle(find.byTooltip('Add task'));
      await save(tester);

      expect(find.text('Enter a title.'), findsOneWidget);
      expect(find.byType(TaskFormView), findsOneWidget);
      expect(await stored(tester), hasLength(5));
    });

    testWidgets('with a due date from the picker', (tester) async {
      await pumpStarter(tester);

      await tester.tapAndSettle(find.byTooltip('Add task'));
      await tester.enterText(field('Title'), 'Book the venue');
      await tester.tapAndSettle(find.text('Due date'));
      await tester.tap(find.text('31'));
      await tester.tapAndSettle(find.text('OK'));
      expect(find.text('Saturday 31 October 2026'), findsOneWidget);
      await save(tester);
      await tester.pumpUntilFound(find.text('Book the venue'));

      expect(
        find.descendant(
          of: find.widgetWithText(TaskCard, 'Book the venue'),
          matching: find.text('Due Sat 31 Oct'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('something typed, then Close: "Discard changes?"', (
      tester,
    ) async {
      await pumpStarter(tester);

      await tester.tapAndSettle(find.byTooltip('Add task'));
      await tester.enterText(field('Title'), 'Half a thought');
      await tester.tapAndSettle(find.byType(CloseButton));
      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tapAndSettle(find.text('Keep editing'));
      expect(field('Title'), findsOneWidget);

      await tester.tapAndSettle(find.byType(CloseButton));
      await tester.tapAndSettle(find.text('Discard'));
      expect(find.byType(TaskFormView), findsNothing);
      expect(find.text('Half a thought'), findsNothing);
      expect(await stored(tester), hasLength(5));
    });

    testWidgets('"/tasks/new" by link: saving lands on Tasks', (tester) async {
      await pumpStarter(tester, initialLocation: '/tasks/new');

      await tester.enterText(field('Title'), 'From a link');
      await save(tester);
      await tester.pumpUntilFound(find.text('From a link'));

      expect(appBarTitled('Tasks'), findsOneWidget);
    });
  });

  group("a task's screen", () {
    testWidgets('Edit → change → Save: the task shows the change, and the '
        'list too', (tester) async {
      await pumpStarter(tester);

      await tester.tapAndSettle(find.text('Explore the architecture'));
      await tester.tapAndSettle(find.byTooltip('Edit'));
      await tester.enterText(
        field('Explore the architecture'),
        'Read the docs',
      );
      await save(tester);
      await tester.pumpUntilFound(
        find.descendant(
          of: find.byType(TaskDetailView),
          matching: find.text('Read the docs'),
        ),
      );
      expect(find.byType(TaskFormView), findsNothing);

      await tester.tapAndSettle(find.byType(BackButton));
      expect(find.widgetWithText(TaskCard, 'Read the docs'), findsOneWidget);
    });

    testWidgets('the Done switch ticks it off, here and on the list', (
      tester,
    ) async {
      await pumpStarter(tester);

      await tester.tapAndSettle(find.text('Explore the architecture'));
      await tester.tap(find.byType(Switch));
      await tester.settleRealAsync();
      expect(find.text('Done'), findsWidgets);

      await tester.tapAndSettle(find.byType(BackButton));
      final title = tester.widget<Text>(
        find.descendant(
          of: find.byType(TaskCard),
          matching: find.text('Explore the architecture'),
        ),
      );
      expect(title.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('Delete, confirmed: back on the list, and it is gone', (
      tester,
    ) async {
      await pumpStarter(tester);

      await tester.tapAndSettle(find.text('Explore the architecture'));
      await tester.tapAndSettle(find.byTooltip('Delete'));
      expect(find.text('Delete this task?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.settleRealAsync();
      await tester.pumpUntilFound(appBarTitled('Tasks'));

      expect(find.byType(TaskDetailView), findsNothing);
      expect(find.text('Explore the architecture'), findsNothing);
      expect(await stored(tester), hasLength(4));
    });

    testWidgets('Delete, cancelled: the task stays', (tester) async {
      await pumpStarter(tester, initialLocation: demoTaskPath);

      await tester.tapAndSettle(find.byTooltip('Delete'));
      await tester.tapAndSettle(find.text('Cancel'));

      expect(find.byType(TaskDetailView), findsOneWidget);
      expect(await stored(tester), hasLength(5));
    });
  });

  group('links', () {
    testWidgets('to a task that does not exist: "Task not found"', (
      tester,
    ) async {
      await pumpStarter(tester, initialLocation: '/tasks/nope');

      expect(find.text('Task not found'), findsOneWidget);
      await tester.tapAndSettle(find.text('Go to Tasks'));
      expect(find.byType(TaskCard), findsNWidgets(5));
    });

    testWidgets("to a missing task's form: not found, and no Save", (
      tester,
    ) async {
      await pumpStarter(tester, initialLocation: '/tasks/nope/edit');

      expect(find.text('Task not found'), findsWidgets);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets("to a task's form: saving returns to the task", (tester) async {
      await pumpStarter(tester, initialLocation: '$demoTaskPath/edit');

      await tester.enterText(field('Explore the architecture'), 'Linked edit');
      await save(tester);
      await tester.pumpUntilFound(find.byType(TaskDetailView));

      expect(find.byType(TaskFormView), findsNothing);
      expect(find.text('Linked edit'), findsOneWidget);
    });
  });
}
