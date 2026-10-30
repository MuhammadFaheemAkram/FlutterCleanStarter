import 'package:flutter_clean_starter/core/navigation/fallback_close_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late ValueNotifier<int> version;
  late int closes;

  setUp(() {
    version = ValueNotifier(0);
    closes = 0;
  });
  tearDown(() => version.dispose());

  Future<void> pumpScreen(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: _Screen(version: version, onClose: () => closes++),
    ),
  );

  Future<void> openAnother(WidgetTester tester) async {
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the only screen: Close, which runs onClose', (tester) async {
    await pumpScreen(tester);
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.byTooltip('Close'));
    expect(closes, 1);
  });

  testWidgets('a screen with one underneath: Back, no Close', (tester) async {
    await pumpScreen(tester);
    await openAnother(tester);

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
  });

  testWidgets('rebuilt while another screen covers it, it keeps Close for '
      'after Back', (tester) async {
    await pumpScreen(tester);
    await openAnother(tester);

    // Its data changes underneath (as a save on the covering screen does).
    version.value++;
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
  });
}

/// A screen whose app bar uses the fallback, rebuilt when [version]
/// changes; Open pushes another one over it.
class _Screen extends StatelessWidget {
  const _Screen({required this.version, required this.onClose});

  final ValueNotifier<int> version;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: version,
      builder: (context, value, _) => Scaffold(
        appBar: AppBar(
          leading: fallbackCloseButton(context, onClose),
          title: Text('Version $value'),
        ),
        body: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _Screen(version: version, onClose: onClose),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    );
  }
}
