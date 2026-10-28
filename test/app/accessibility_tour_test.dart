import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';

// Every screen, in light and dark, with text at 200%: no layout overflows
// (an overflow fails the test), tap targets of at least 48 × 48, a label on
// everything tappable, and readable text contrast. A new screen, or a new
// state of one, gets a case here.
void main() {
  tearDown(getIt.reset);

  for (final brightness in Brightness.values) {
    group('${brightness.name} theme, text at 200%', () {
      Future<void> open(
        WidgetTester tester, {
        required String at,
        bool withDemo = true,
        bool offline = false,
        Map<String, Object> preferences = const {},
      }) async {
        tester.platformDispatcher
          ..textScaleFactorTestValue = 2
          ..platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await pumpStarter(
          tester,
          initialLocation: at,
          withDemo: withDemo,
          offline: offline,
          preferences: preferences,
        );
        // Phone width, but tall enough to lay out every item of a long list:
        // the checks below see only what is built.
        tester.view.physicalSize = const Size(390 * 3, 6000 * 3);
        await tester.settle();
        final context = tester.element(find.byType(Scaffold).last);
        expect(MediaQuery.textScalerOf(context).scale(10), 20);
        expect(Theme.of(context).brightness, brightness);
      }

      Future<void> expectAccessible(WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      }

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
          withDemo: false,
          preferences: {'tasks.seeded': true},
        );
        expect(find.text('No tasks yet'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('Tasks: the first launch offline', (tester) async {
        await open(tester, at: '/tasks', withDemo: false, offline: true);
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

      for (final (name, location) in [
        ('Settings', '/settings'),
        ('Task', '/tasks/t1'),
        ('New task', '/tasks/new'),
        ('Edit task', '/tasks/t1/edit'),
        ('Page not found', '/nowhere'),
      ]) {
        testWidgets(name, (tester) async {
          await open(tester, at: location);
          await expectAccessible(tester);
        });
      }
    });
  }

  testWidgets('the tab labels keep their size at any text setting (a long '
      'press shows them)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pumpStarter(tester);

    final label = destination('Settings');
    final inBar = tester.element(label);
    expect(MediaQuery.textScalerOf(inBar).scale(10), 10);

    final before = find.text('Settings').evaluate().length;
    await tester.longPress(label);
    await tester.pumpAndSettle();
    // One more: the tooltip over the bar.
    expect(find.text('Settings'), findsNWidgets(before + 1));
  });
}
