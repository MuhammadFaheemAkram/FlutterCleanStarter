import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final picked = <String>[];

  setUp(picked.clear);

  Future<void> pumpChoice(WidgetTester tester) => tester.pumpThemed(
    SegmentedChoice<String>(
      values: const ['a', 'b', 'c'],
      labelOf: (value) => value.toUpperCase(),
      selected: 'b',
      onSelected: picked.add,
    ),
  );

  testWidgets('segments at normal text sizes', (tester) async {
    await pumpChoice(tester);

    expect(find.byType(SegmentedButton<String>), findsOneWidget);
    await tester.tap(find.text('C'));
    expect(picked, ['c']);
  });

  testWidgets('wrapping chips at large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pumpChoice(tester);

    expect(find.byType(SegmentedButton<String>), findsNothing);
    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'B')).selected,
      isTrue,
    );
    await tester.tap(find.text('A'));
    expect(picked, ['a']);
  });
}
