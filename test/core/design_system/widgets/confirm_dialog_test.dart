import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<bool?> ask(
    WidgetTester tester,
    String choice,
    TargetPlatform platform,
  ) async {
    bool? answer;
    await tester.pumpThemed(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => answer = await showConfirmDialog(
            context,
            title: 'Delete this task?',
            message: 'It will be deleted.',
            confirmLabel: 'Delete',
            destructive: true,
          ),
          child: const Text('ask'),
        ),
      ),
      theme: AppTheme.light().copyWith(platform: platform),
    );
    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this task?'), findsOneWidget);
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
    return answer;
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('${platform.name}: confirm is true, cancel is false', (
      tester,
    ) async {
      expect(await ask(tester, 'Delete', platform), isTrue);
      expect(await ask(tester, 'Cancel', platform), isFalse);
    });
  }

  testWidgets('iOS: an iOS alert, with the destructive action in red', (
    tester,
  ) async {
    await tester.pumpThemed(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showConfirmDialog(
            context,
            title: 'Delete?',
            message: '',
            confirmLabel: 'Delete',
            destructive: true,
          ),
          child: const Text('ask'),
        ),
      ),
      theme: AppTheme.light().copyWith(platform: TargetPlatform.iOS),
    );
    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(
      tester
          .widget<CupertinoDialogAction>(
            find.widgetWithText(CupertinoDialogAction, 'Delete'),
          )
          .isDestructiveAction,
      isTrue,
    );
  });
}
