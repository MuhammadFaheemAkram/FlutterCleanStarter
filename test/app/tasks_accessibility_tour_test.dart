import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/accessibility.dart';
import '../helpers/app_harness.dart';
import '../helpers/task_fixtures.dart';

// The Tasks sample's stops on the accessibility tour: every screen and
// state, in light and dark, at 200 % text.
void main() {
  tearDown(getIt.reset);

  for (final brightness in Brightness.values) {
    group('${brightness.name} theme, text at 200%', () {
      /// [seeded]: the demo is stored before the launch (a link to one of
      /// its tasks needs it); without it, the app's first launch seeds.
      Future<void> open(
        WidgetTester tester, {
        required String at,
        bool seeded = true,
        bool offline = false,
        Map<String, Object> preferences = const {},
      }) => openForTour(
        tester,
        brightness: brightness,
        at: at,
        beforeLaunch: seeded ? seedDemo : null,
        offline: offline,
        preferences: preferences,
      );

      testWidgets('Tasks: the demo (overdue, due, done)', (tester) async {
        await open(tester, at: '/tasks');
        expect(find.textContaining('Overdue'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('Tasks: empty', (tester) async {
        await open(
          tester,
          at: '/tasks',
          seeded: false,
          preferences: {'tasks.seeded': true},
        );
        expect(find.text('No tasks yet'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('Tasks: the first launch offline', (tester) async {
        await open(tester, at: '/tasks', seeded: false, offline: true);
        expect(find.text('Try again'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('Tasks: "Task deleted", with Undo', (tester) async {
        await open(tester, at: '/tasks');
        await tester.drag(
          find.text('Rename the project'),
          const Offset(-600, 0),
        );
        await tester.settleRealAsync();
        expect(find.text('Undo'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('New task: the errors after Save', (tester) async {
        await open(tester, at: '/tasks/new');
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.settle();
        expect(find.text('Enter a title.'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('New task: "Discard changes?"', (tester) async {
        await open(tester, at: '/tasks/new');
        await tester.enterText(find.byType(TextField).first, 'Draft');
        await tester.tapAndSettle(find.byType(CloseButton));
        expect(find.text('Discard changes?'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('New task: the date picker', (tester) async {
        await open(tester, at: '/tasks/new');
        await tester.tapAndSettle(find.text('Due date'));
        expect(find.byType(DatePickerDialog), findsOneWidget);
        // Material's own calendar: seven day cells must fit the dialog, so
        // each is 47.7 px wide, a hair under 48. Not ours to resize; its
        // labels and contrast are still checked.
        await expectAccessible(tester, tapTargets: false);
      });

      testWidgets('Task: "Delete this task?"', (tester) async {
        await open(tester, at: demoTaskPath);
        await tester.tapAndSettle(find.byTooltip('Delete'));
        expect(find.text('Delete this task?'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('Settings: "Reset demo data?"', (tester) async {
        await open(tester, at: '/settings');
        await tester.tapAndSettle(find.text('Reset demo data'));
        expect(find.text('Reset demo data?'), findsOneWidget);
        await expectAccessible(tester);
      });

      for (final (name, location, shows) in [
        ('Task', demoTaskPath, 'Explore the architecture'),
        ('Task not found', '/tasks/nope', 'Task not found'),
        ('New task', '/tasks/new', 'Due date'),
        ('Edit task', '$demoTaskPath/edit', 'Explore the architecture'),
        ('Edit task: not found', '/tasks/nope/edit', 'Task not found'),
      ]) {
        testWidgets(name, (tester) async {
          await open(tester, at: location);
          expect(find.text(shows), findsWidgets);
          await expectAccessible(tester);
        });
      }
    });
  }
}
