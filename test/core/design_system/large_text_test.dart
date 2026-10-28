import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<bool> stackedAt(WidgetTester tester, double scale) async {
    late bool stacked;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Builder(
          builder: (context) {
            stacked = context.prefersStackedLayout;
            return const SizedBox();
          },
        ),
      ),
    );
    return stacked;
  }

  testWidgets('side by side up to 130 % text, stacked beyond it', (
    tester,
  ) async {
    expect(await stackedAt(tester, 1), isFalse);
    expect(await stackedAt(tester, 1.3), isFalse);
    expect(await stackedAt(tester, 1.35), isTrue);
    expect(await stackedAt(tester, 2), isTrue);
  });
}
