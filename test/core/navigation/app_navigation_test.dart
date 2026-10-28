import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/features/shell/main_shell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';

// The shell, whatever its tabs: a feature's own routes are tested in its
// files (the Tasks sample's: `task_routes_navigation_test.dart`).
void main() {
  tearDown(getIt.reset);

  final first = AppTab.values.first.label;
  final last = AppTab.values.last.label;

  group('tabs', () {
    testWidgets('the app opens on the first tab', (tester) async {
      await pumpStarter(tester);

      expect(appBarTitled(first), findsOneWidget);
      expect(tester.selectedTab, 0);
    });

    testWidgets('each tab shows its own screen', (tester) async {
      await pumpStarter(tester);

      for (final (index, tab) in [
        ...AppTab.values.indexed.skip(1),
        (0, AppTab.values.first),
      ]) {
        await tester.tapAndSettle(destination(tab.label));
        expect(tester.selectedTab, index);
        expect(appBarTitled(tab.label), findsOneWidget);
      }
    });

    testWidgets('a tab keeps its screen while another is shown', (
      tester,
    ) async {
      await pumpStarter(tester, initialLocation: '/settings');

      await tester.tapAndSettle(destination(first));
      await tester.tapAndSettle(destination(last));

      expect(appBarTitled(last), findsOneWidget);
    });
  });

  testWidgets('an unknown location shows "Page not found", with a way back', (
    tester,
  ) async {
    await pumpStarter(tester, initialLocation: '/nowhere');
    expect(find.text('Page not found'), findsOneWidget);

    await tester.tapAndSettle(find.byType(FilledButton));
    expect(appBarTitled(first), findsOneWidget);
    expect(tester.selectedTab, 0);
  });
}
