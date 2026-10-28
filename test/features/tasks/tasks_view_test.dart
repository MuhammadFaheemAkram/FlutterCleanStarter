import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/features/tasks/cubit/tasks_cubit.dart';
import 'package:flutter_clean_starter/features/tasks/cubit/tasks_state.dart';
import 'package:flutter_clean_starter/features/tasks/tasks_page.dart';
import 'package:flutter_clean_starter/features/tasks/widgets/task_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/task_fixtures.dart';

class _MockTasksCubit extends MockCubit<TasksState> implements TasksCubit {}

void main() {
  late _MockTasksCubit cubit;

  setUpAll(() => registerFallbackValue(task()));

  setUp(() {
    cubit = _MockTasksCubit();
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.retry()).thenAnswer((_) async {});
    when(() => cubit.toggle(any())).thenAnswer((_) async {});
    when(() => cubit.delete(any())).thenAnswer((_) async {});
    when(() => cubit.undo(any())).thenAnswer((_) async {});
  });

  // One state per test: a MockCubit pumped again keeps its first state
  // (conventions §11.73). Changes over time go through `whenListen`.
  Future<void> pumpView(
    WidgetTester tester,
    TasksState state, {
    Stream<TasksState>? then,
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
        home: BlocProvider<TasksCubit>.value(
          value: cubit,
          child: const TasksView(),
        ),
      ),
    );
  }

  final ready = TasksState(
    status: TasksStatus.ready,
    today: demoToday,
    tasks: [
      task(id: 'a', title: 'First'),
      task(id: 'b', title: 'Second'),
    ],
  );

  testWidgets('loading: a spinner, and no Add button yet', (tester) async {
    await pumpView(tester, const TasksState());

    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('error: why, and Try again seeds again', (tester) async {
    await pumpView(
      tester,
      const TasksState(status: TasksStatus.error, errorMessage: 'Offline.'),
    );

    expect(find.text('Offline.'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    await tester.tap(find.text('Try again'));
    verify(() => cubit.retry()).called(1);
  });

  testWidgets('empty: "No tasks yet", with Add buttons', (tester) async {
    await pumpView(
      tester,
      TasksState(status: TasksStatus.empty, today: demoToday),
    );

    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add task'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('ready: a card per task, in the given order', (tester) async {
    await pumpView(tester, ready);

    expect(find.byType(TaskCard), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text('First')).dy,
      lessThan(tester.getTopLeft(find.text('Second')).dy),
    );
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('tapping a checkbox toggles that task', (tester) async {
    await pumpView(tester, ready);

    await tester.tap(find.byType(Checkbox).last);

    verify(() => cubit.toggle(ready.tasks.last)).called(1);
  });

  testWidgets('swiping a card away deletes that task', (tester) async {
    await pumpView(tester, ready);

    await tester.drag(find.text('First'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    verify(() => cubit.delete(ready.tasks.first)).called(1);
  });

  testWidgets('a swipe the other way does nothing', (tester) async {
    await pumpView(tester, ready);

    await tester.drag(find.text('First'), const Offset(500, 0));
    await tester.pumpAndSettle();

    verifyNever(() => cubit.delete(any()));
  });

  testWidgets('pulling down refreshes', (tester) async {
    await pumpView(tester, ready);

    await tester.fling(find.text('First'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => cubit.refresh()).called(1);
  });

  testWidgets('a deletion shows "Task deleted" with Undo, once', (
    tester,
  ) async {
    final deleted = ready.copyWith(
      tasks: [ready.tasks.last],
      undoable: ready.tasks.first,
      undoSerial: 1,
    );
    await pumpView(tester, ready, then: Stream.value(deleted));
    await tester.pumpAndSettle();

    expect(find.text('Task deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    verify(() => cubit.undo(ready.tasks.first)).called(1);
  });

  testWidgets('a message shows in a SnackBar when its serial changes', (
    tester,
  ) async {
    await pumpView(
      tester,
      ready,
      then: Stream.fromIterable([
        ready.copyWith(message: "You're up to date.", messageSerial: 1),
        // The same serial: not a new message, whatever the text says.
        ready.copyWith(message: 'Not shown', messageSerial: 1),
      ]),
    );
    await tester.pump();

    expect(find.text("You're up to date."), findsOneWidget);
    expect(find.text('Not shown'), findsNothing);
  });
}
