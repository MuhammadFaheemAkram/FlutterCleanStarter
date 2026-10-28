import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/task_fixtures.dart';

void main() {
  tearDown(getIt.reset);

  group('tabs', () {
    testWidgets('the app opens on Tasks', (tester) async {
      await pumpStarter(tester);

      expect(appBarTitled('Tasks'), findsOneWidget);
      expect(tester.selectedTab, 0);
    });

    testWidgets('each tab shows its own screen', (tester) async {
      await pumpStarter(tester);

      await tester.tapAndSettle(destination('Settings'));
      expect(tester.selectedTab, 1);
      expect(appBarTitled('Settings'), findsOneWidget);

      await tester.tapAndSettle(destination('Tasks'));
      expect(tester.selectedTab, 0);
      expect(appBarTitled('Tasks'), findsOneWidget);
    });

    testWidgets('a tab keeps its screen while another is shown', (
      tester,
    ) async {
      await pumpStarter(tester, initialLocation: '/settings');

      await tester.tapAndSettle(destination('Tasks'));
      await tester.tapAndSettle(destination('Settings'));

      expect(appBarTitled('Settings'), findsOneWidget);
    });
  });

  group('the task form', () {
    testWidgets('Add opens a full-screen dialog above the tabs, and Close '
        'returns', (tester) async {
      await pumpStarter(tester);

      await tester.tapAndSettle(find.byTooltip('Add task'));
      expect(appBarTitled('New task'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final route = ModalRoute.of(tester.element(find.text('New task').last));
      expect((route! as PageRoute<void>).fullscreenDialog, isTrue);

      await tester.tapAndSettle(find.byType(CloseButton));
      expect(appBarTitled('Tasks'), findsOneWidget);
      expect(tester.selectedTab, 0);
    });

    testWidgets("a task's Edit opens the form over it, and Close returns to "
        'it', (tester) async {
      await pumpStarter(tester, initialLocation: demoTaskPath);

      await tester.tapAndSettle(find.byTooltip('Edit'));
      expect(appBarTitled('Edit task'), findsOneWidget);

      await tester.tapAndSettle(find.byType(CloseButton));
      expect(appBarTitled('Task'), findsOneWidget);
    });

    testWidgets('an edit link opens the form over its task, and Close returns '
        'to it', (tester) async {
      await pumpStarter(tester, initialLocation: '$demoTaskPath/edit');

      expect(appBarTitled('Edit task'), findsOneWidget);
      await tester.tapAndSettle(find.byType(CloseButton));
      expect(appBarTitled('Task'), findsOneWidget);
    });

    testWidgets('"/tasks/new" by link: Close goes to Tasks', (tester) async {
      await pumpStarter(tester, initialLocation: '/tasks/new');

      expect(appBarTitled('New task'), findsOneWidget);
      await tester.tapAndSettle(find.byType(CloseButton));
      expect(appBarTitled('Tasks'), findsOneWidget);
    });
  });

  group('a task', () {
    testWidgets('opened from Tasks, it has Back, which returns to the tab', (
      tester,
    ) async {
      await pumpStarter(tester);
      await tester.tapAndSettle(find.text('Explore the architecture'));

      expect(appBarTitled('Task'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tester.tapAndSettle(find.byType(BackButton));
      expect(appBarTitled('Tasks'), findsOneWidget);
    });

    testWidgets('by link, it opens with a Close button to Tasks', (
      tester,
    ) async {
      await pumpStarter(tester, initialLocation: demoTaskPath);
      expect(appBarTitled('Task'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);

      await tester.tapAndSettle(find.byTooltip('Close'));

      expect(appBarTitled('Tasks'), findsOneWidget);
    });
  });

  testWidgets('an unknown location shows "Page not found", with a way back', (
    tester,
  ) async {
    await pumpStarter(tester, initialLocation: '/nowhere');
    expect(find.text('Page not found'), findsOneWidget);

    await tester.tapAndSettle(find.text('Go to Tasks'));
    expect(appBarTitled('Tasks'), findsOneWidget);
  });
}
