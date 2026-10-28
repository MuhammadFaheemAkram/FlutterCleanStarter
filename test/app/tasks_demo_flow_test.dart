import 'package:flutter_clean_starter/core/network/network_simulator.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/features/tasks/widgets/task_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';

// Settings → Reset demo data, the Tasks sample's part of Settings, on the
// real DI graph.
void main() {
  tearDown(getIt.reset);

  Future<void> openSettings(WidgetTester tester) =>
      tester.tapAndSettle(destination('Settings'));

  group('Reset demo data', () {
    testWidgets('brings the sample tasks back, and says so', (tester) async {
      await pumpStarter(tester);
      await tester.drag(find.text('Rename the project'), const Offset(-600, 0));
      await tester.settleRealAsync();
      expect(find.byType(TaskCard), findsNWidgets(4));

      await openSettings(tester);
      await tester.tapAndSettle(find.text('Reset demo data'));
      expect(find.text('Reset demo data?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpUntilFound(find.text('Demo data restored: 5 tasks.'));

      await tester.tapAndSettle(destination('Tasks'));
      await tester.pumpUntilFound(find.text('Rename the project'));
      expect(find.byType(TaskCard), findsNWidgets(5));
    });

    testWidgets('offline: says why, and the tasks stay as they were', (
      tester,
    ) async {
      await pumpStarter(tester);
      await tester.drag(find.text('Rename the project'), const Offset(-600, 0));
      await tester.settleRealAsync();
      getIt<NetworkSimulator>().failRequests = true;

      await openSettings(tester);
      await tester.tapAndSettle(find.text('Reset demo data'));
      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpUntilFound(find.textContaining("Couldn't reach"));

      await tester.tapAndSettle(destination('Tasks'));
      expect(find.byType(TaskCard), findsNWidgets(4));
    });
  });
}
