import 'package:flutter/semantics.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/features/tasks/widgets/task_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/task_fixtures.dart';

void main() {
  final taps = <String>[];

  setUp(taps.clear);

  Future<void> pumpCard(WidgetTester tester, Task task, {ThemeData? theme}) =>
      tester.pumpThemed(
        TaskCard(
          task: task,
          today: demoToday,
          onTap: () => taps.add('open'),
          onToggle: () => taps.add('toggle'),
          onDelete: () => taps.add('delete'),
        ),
        theme: theme,
      );

  Text textOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text));

  testWidgets('shows the title, a line of notes, and the created date', (
    tester,
  ) async {
    await pumpCard(
      tester,
      task(
        title: 'Plan the sprint',
        notes: '  First line\nSecond line',
        createdAt: DateTime.utc(2026, 10, 1, 12),
      ),
    );

    expect(find.text('Plan the sprint'), findsOneWidget);
    expect(find.text('First line'), findsOneWidget);
    expect(find.textContaining('Second line'), findsNothing);
    expect(textOf(tester, 'First line').maxLines, 1);
    expect(find.text('Created 1 Oct'), findsOneWidget);
  });

  testWidgets('no notes, no due date: no empty lines', (tester) async {
    await pumpCard(tester, task());

    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('a due date: "Due" and the day', (tester) async {
    await pumpCard(tester, task(due: demoToday));
    expect(find.text('Due today'), findsOneWidget);
  });

  testWidgets('a later due date names the day', (tester) async {
    await pumpCard(tester, task(due: demoToday.addDays(2)));
    expect(find.text('Due Fri 30 Oct'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('overdue: an icon and the word, in the overdue color '
        '(${brightness.name})', (tester) async {
      final theme = brightness == Brightness.light
          ? AppTheme.light()
          : AppTheme.dark();
      await pumpCard(tester, task(due: demoToday.addDays(-1)), theme: theme);

      const label = 'Overdue · due yesterday';
      expect(find.text(label), findsOneWidget);
      final color = theme.extension<AppColors>()!.overdue;
      expect(textOf(tester, label).style?.color, color);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.error_outline)).color,
        color,
      );
    });
  }

  testWidgets('at large text the status icon grows with the text, and sits '
      'on its first line', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    tester.usePhoneSurface();
    await pumpCard(tester, task(due: demoToday.addDays(-1)));

    final icon = find.byIcon(Icons.error_outline);
    final text = find.textContaining('Overdue');
    // 20 × 3, capped.
    expect(tester.getSize(icon).height, AppIconSize.large);
    // The label wraps, and the icon stays level with its first line.
    expect(tester.getSize(text).height, greaterThan(AppIconSize.large * 2));
    expect(
      tester.getCenter(icon).dy,
      lessThan(tester.getTopLeft(text).dy + AppIconSize.large),
    );
  });

  testWidgets('done: struck through, "Done", and never overdue', (
    tester,
  ) async {
    await pumpCard(
      tester,
      task(title: 'Finished', isCompleted: true, due: demoToday.addDays(-3)),
    );

    expect(
      textOf(tester, 'Finished').style?.decoration,
      TextDecoration.lineThrough,
    );
    expect(find.text('Done'), findsOneWidget);
    expect(find.textContaining('Overdue'), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('tapping the card opens it; the checkbox toggles', (
    tester,
  ) async {
    await pumpCard(tester, task(title: 'Tap me'));

    await tester.tap(find.text('Tap me'));
    await tester.tap(find.byType(Checkbox));

    expect(taps, ['open', 'toggle']);
  });

  testWidgets('the checkbox names its task for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCard(tester, task(title: 'Call Sam'));

    expect(
      tester.getSemantics(find.byType(Checkbox)),
      matchesSemantics(
        label: 'Done: Call Sam',
        hasCheckedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('Delete is offered as a screen-reader action (a swipe is not '
      'reachable)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCard(tester, task());

    final node = tester.getSemantics(find.byType(TaskCard));
    final delete = node.getSemanticsData().customSemanticsActionIds!.single;
    node.owner!.performAction(node.id, SemanticsAction.customAction, delete);

    expect(CustomSemanticsAction.getAction(delete)!.label, 'Delete');
    expect(taps, ['delete']);
    handle.dispose();
  });
}
