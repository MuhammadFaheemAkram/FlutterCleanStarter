import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/task_fixtures.dart';

void main() {
  final changes = <CalendarDate?>[];

  setUp(changes.clear);

  Future<void> pumpField(
    WidgetTester tester, {
    CalendarDate? value,
    TargetPlatform platform = TargetPlatform.android,
  }) async {
    tester.usePhoneSurface();
    await tester.pumpThemed(
      Padding(
        padding: const EdgeInsets.all(16),
        child: DatePickerField(
          label: 'Due date',
          value: value,
          today: demoToday,
          onChanged: changes.add,
        ),
      ),
      theme: AppTheme.light().copyWith(platform: platform),
    );
  }

  testWidgets('empty: just the label, and no Clear', (tester) async {
    await pumpField(tester);

    expect(find.text('Due date'), findsOneWidget);
    expect(find.byTooltip('Clear Due date'), findsNothing);
  });

  testWidgets('a day: written in full, with Clear', (tester) async {
    await pumpField(tester, value: CalendarDate(2026, 10, 30));

    expect(find.text('Friday 30 October 2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear Due date'));

    expect(changes, [null]);
  });

  testWidgets('Android: a calendar dialog, opening on today', (tester) async {
    await pumpField(tester);

    await tester.tap(find.text('Due date'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('30'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(changes, [CalendarDate(2026, 10, 30)]);
  });

  testWidgets('Android: cancelling changes nothing', (tester) async {
    await pumpField(tester, value: demoToday);

    await tester.tap(find.text('Wednesday 28 October 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(changes, isEmpty);
  });

  testWidgets('iOS: a wheel in a sheet; Done picks the day shown', (
    tester,
  ) async {
    await pumpField(tester, platform: TargetPlatform.iOS);

    await tester.tap(find.text('Due date'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(changes, [demoToday]);
  });
}
