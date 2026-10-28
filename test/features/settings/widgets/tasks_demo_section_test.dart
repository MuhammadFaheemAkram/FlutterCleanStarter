import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_cubit.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_state.dart';
import 'package:flutter_clean_starter/features/settings/widgets/tasks_demo_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockTasksDemoCubit extends MockCubit<TasksDemoState>
    implements TasksDemoCubit {}

void main() {
  late _MockTasksDemoCubit demo;

  setUp(() {
    demo = _MockTasksDemoCubit();
    when(() => demo.reset()).thenAnswer((_) async {});
  });

  Future<void> pumpView(
    WidgetTester tester, {
    TasksDemoState demoState = const TasksDemoState(),
    Stream<TasksDemoState>? demoThen,
  }) async {
    if (demoThen != null) {
      whenListen(demo, demoThen, initialState: demoState);
    } else {
      when(() => demo.state).thenReturn(demoState);
    }
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: BlocProvider<TasksDemoCubit>.value(
            value: demo,
            child: const TasksDemoSection(),
          ),
        ),
      ),
    );
  }

  testWidgets('Reset demo data asks first; Cancel keeps everything', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text('Reset demo data'));
    await tester.pumpAndSettle();
    expect(find.text('Reset demo data?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => demo.reset());
  });

  testWidgets('Reset demo data, confirmed, resets', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text('Reset demo data'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await tester.pumpAndSettle();

    verify(() => demo.reset()).called(1);
  });

  testWidgets('while resetting: busy, and the row is off', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpView(tester, demoState: const TasksDemoState(resetting: true));

    expect(find.bySemanticsLabel(RegExp('Resetting')), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Reset demo data'))
          .enabled,
      isFalse,
    );
    handle.dispose();
  });

  testWidgets("the reset's outcome shows in a SnackBar", (tester) async {
    await pumpView(
      tester,
      demoThen: Stream.value(
        const TasksDemoState(
          message: 'Demo data restored: 5 tasks.',
          messageSerial: 1,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Demo data restored: 5 tasks.'), findsOneWidget);
  });
}
