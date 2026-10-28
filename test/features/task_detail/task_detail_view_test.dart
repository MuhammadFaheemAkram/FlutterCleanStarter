import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/features/task_detail/cubit/task_detail_cubit.dart';
import 'package:flutter_clean_starter/features/task_detail/cubit/task_detail_state.dart';
import 'package:flutter_clean_starter/features/task_detail/task_detail_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/task_fixtures.dart';

class _MockTaskDetailCubit extends MockCubit<TaskDetailState>
    implements TaskDetailCubit {}

void main() {
  late _MockTaskDetailCubit cubit;
  var left = 0;

  setUp(() {
    cubit = _MockTaskDetailCubit();
    left = 0;
    when(() => cubit.toggle()).thenAnswer((_) async {});
    when(() => cubit.delete()).thenAnswer((_) async {});
  });

  Future<void> pumpView(
    WidgetTester tester,
    TaskDetailState state, {
    Stream<TaskDetailState>? then,
  }) async {
    if (then != null) {
      whenListen(cubit, then, initialState: state);
    } else {
      when(() => cubit.state).thenReturn(state);
    }
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<TaskDetailCubit>.value(
          value: cubit,
          child: TaskDetailView(onLeave: () => left++),
        ),
      ),
    );
  }

  final shown = task(
    title: 'Plan the sprint',
    notes: 'Bring the board.',
    due: CalendarDate(2026, 10, 30),
    createdAt: DateTime(2026, 10, 1, 9).toUtc(),
    updatedAt: DateTime(2026, 10, 2, 17, 30).toUtc(),
  );
  final ready = TaskDetailState(
    status: TaskDetailStatus.ready,
    task: shown,
    today: demoToday,
  );

  testWidgets('shows everything about the task', (tester) async {
    await pumpView(tester, ready);

    expect(find.text('Plan the sprint'), findsOneWidget);
    expect(find.text('Due Fri 30 Oct'), findsOneWidget);
    expect(find.text('Bring the board.'), findsOneWidget);
    expect(find.text('Friday 30 October 2026'), findsOneWidget);
    expect(find.textContaining('Created 1 Oct 2026'), findsOneWidget);
    expect(find.textContaining('Updated 2 Oct 2026'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(find.byTooltip('Delete'), findsOneWidget);
  });

  testWidgets('no notes, no due date, never updated: says so', (tester) async {
    await pumpView(tester, ready.copyWith(task: task(title: 'Bare')));

    expect(find.text('No notes'), findsOneWidget);
    expect(find.text('No due date'), findsOneWidget);
    expect(find.textContaining('Updated'), findsNothing);
  });

  testWidgets('the title is a heading', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpView(tester, ready);

    expect(
      tester.getSemantics(find.text('Plan the sprint')),
      matchesSemantics(label: 'Plan the sprint', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('the Done switch toggles', (tester) async {
    await pumpView(tester, ready);

    await tester.tap(find.byType(Switch));

    verify(() => cubit.toggle()).called(1);
  });

  testWidgets('Delete asks first; Cancel keeps the task', (tester) async {
    await pumpView(tester, ready);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this task?'), findsOneWidget);
    expect(find.text('“Plan the sprint” will be deleted.'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => cubit.delete());
  });

  testWidgets('Delete, confirmed, deletes', (tester) async {
    await pumpView(tester, ready);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(() => cubit.delete()).called(1);
  });

  testWidgets('once deleted, the screen leaves (once)', (tester) async {
    await pumpView(
      tester,
      ready,
      then: Stream.fromIterable([
        ready.copyWith(status: TaskDetailStatus.deleting),
        ready.copyWith(status: TaskDetailStatus.deleted),
        ready.copyWith(status: TaskDetailStatus.deleted, messageSerial: 1),
      ]),
    );
    await tester.pump();

    expect(left, 1);
  });

  testWidgets('while deleting: no actions, the switch off', (tester) async {
    await pumpView(tester, ready.copyWith(status: TaskDetailStatus.deleting));

    expect(find.byTooltip('Edit'), findsNothing);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });

  testWidgets('not found: says so, with a way back', (tester) async {
    await pumpView(
      tester,
      const TaskDetailState(status: TaskDetailStatus.notFound),
    );

    expect(find.text('Task not found'), findsOneWidget);
    expect(find.text('Go to Tasks'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsNothing);
  });

  testWidgets('loading: a spinner', (tester) async {
    await pumpView(tester, const TaskDetailState());
    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets('a failed write shows its message', (tester) async {
    await pumpView(
      tester,
      ready,
      then: Stream.value(ready.copyWith(message: 'Oops.', messageSerial: 1)),
    );
    await tester.pump();

    expect(find.text('Oops.'), findsOneWidget);
  });
}
