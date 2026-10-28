import 'package:flutter_clean_starter/core/network/network_simulator.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/repository/task_repository.dart';
import 'package:flutter_clean_starter/features/tasks/widgets/task_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';
import '../helpers/task_fixtures.dart';

// The Tasks screen on the real DI graph: the real repository on an
// in-memory database, the real fake server with no latency, a fixed clock.
void main() {
  tearDown(getIt.reset);

  Future<int> storedCount(WidgetTester tester) async =>
      (await tester.runAsync(() => getIt<TaskRepository>().watchTasks().first))!
          .length;

  testWidgets('the first launch seeds the demo, overdue task first', (
    tester,
  ) async {
    await pumpStarter(tester);

    expect(find.byType(TaskCard), findsNWidgets(5));
    expect(find.text('Overdue · due yesterday'), findsOneWidget);
    expect(find.text('Due Fri 30 Oct'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('offline on the first launch: the error, then Try again', (
    tester,
  ) async {
    await pumpStarter(tester, offline: true);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    getIt<NetworkSimulator>().failRequests = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpUntilFound(find.byType(TaskCard));

    expect(find.byType(TaskCard), findsNWidgets(5));
  });

  testWidgets('a launch after the user deleted everything: "No tasks yet", '
      'and Add opens the form', (tester) async {
    await pumpStarter(tester, preferences: {'tasks.seeded': true});

    expect(find.text('No tasks yet'), findsOneWidget);
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Add task'));
    expect(appBarTitled('New task'), findsOneWidget);
  });

  testWidgets('ticking a task off strikes it through and saves it', (
    tester,
  ) async {
    await pumpStarter(tester);
    final title = find.text('Rename the project');

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(TaskCard, 'Rename the project'),
        matching: find.byType(Checkbox),
      ),
    );
    await tester.settleRealAsync();

    expect(
      tester.widget<Text>(title).style?.decoration,
      TextDecoration.lineThrough,
    );
    final stored = await tester.runAsync(
      () => getIt<TaskRepository>().watchTasks().first,
    );
    expect(
      stored!.firstWhere((t) => t.title == 'Rename the project').isCompleted,
      isTrue,
    );
  });

  testWidgets('swipe to delete, then Undo', (tester) async {
    await pumpStarter(tester);

    await tester.drag(find.text('Rename the project'), const Offset(-600, 0));
    await tester.settleRealAsync();

    expect(find.text('Rename the project'), findsNothing);
    expect(find.text('Task deleted'), findsOneWidget);
    expect(await storedCount(tester), 4);

    await tester.tap(find.text('Undo'));
    await tester.pumpUntilFound(find.text('Rename the project'));
    expect(await storedCount(tester), 5);
  });

  testWidgets('the Undo SnackBar sits above the Add button, not over it', (
    tester,
  ) async {
    await pumpStarter(tester);

    await tester.drag(find.text('Rename the project'), const Offset(-600, 0));
    await tester.settleRealAsync();

    final snackBar = tester.getRect(find.byType(SnackBar));
    final fab = tester.getRect(find.byType(FloatingActionButton));
    expect(snackBar.bottom, lessThanOrEqualTo(fab.top));
    await tester.tapAndSettle(find.byType(FloatingActionButton));
    expect(appBarTitled('New task'), findsOneWidget);
  });

  testWidgets('a deleted demo task stays deleted after a refresh', (
    tester,
  ) async {
    await pumpStarter(tester);
    await tester.drag(find.text('Rename the project'), const Offset(-600, 0));
    await tester.settleRealAsync();
    // Let the Undo SnackBar go (conventions §11.48).
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(TaskCard).first, const Offset(0, 400), 1000);
    await tester.pumpUntilFound(find.text("You're up to date."));

    expect(find.text('Rename the project'), findsNothing);
  });

  testWidgets('pull to refresh offline: says why, and the list stays', (
    tester,
  ) async {
    await pumpStarter(tester, beforeLaunch: seedDemo, offline: true);

    await tester.fling(find.byType(TaskCard).first, const Offset(0, 400), 1000);
    await tester.pumpUntilFound(find.textContaining("Couldn't reach"));

    expect(find.byType(TaskCard), findsNWidgets(5));
  });

  testWidgets('tapping a task opens it above the tabs; Back returns', (
    tester,
  ) async {
    await pumpStarter(tester);

    await tester.tapAndSettle(find.text('Explore the architecture'));
    expect(appBarTitled('Task'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tapAndSettle(find.byType(BackButton));
    expect(find.byType(TaskCard), findsNWidgets(5));
  });

  testWidgets('the list survives a trip to Settings and back', (tester) async {
    await pumpStarter(tester);
    await tester.drag(find.text('Rename the project'), const Offset(-600, 0));
    await tester.settleRealAsync();

    await tester.tapAndSettle(destination('Settings'));
    await tester.tapAndSettle(destination('Tasks'));

    expect(find.byType(TaskCard), findsNWidgets(4));
  });
}
