import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/features/task_form/cubit/task_form_cubit.dart';
import 'package:flutter_clean_starter/features/task_form/cubit/task_form_state.dart';
import 'package:flutter_clean_starter/features/task_form/task_form_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/task_fixtures.dart';

class _MockTaskFormCubit extends MockCubit<TaskFormState>
    implements TaskFormCubit {}

void main() {
  late _MockTaskFormCubit cubit;
  var closed = 0;

  setUp(() {
    cubit = _MockTaskFormCubit();
    closed = 0;
    when(() => cubit.save()).thenAnswer((_) async {});
    when(() => cubit.taskId).thenReturn(null);
  });

  Future<void> pumpView(
    WidgetTester tester,
    TaskFormState state, {
    Stream<TaskFormState>? then,
    String? taskId,
  }) async {
    when(() => cubit.taskId).thenReturn(taskId);
    if (then != null) {
      whenListen(cubit, then, initialState: state);
    } else {
      when(() => cubit.state).thenReturn(state);
    }
    tester.usePhoneSurface();
    // A route underneath, so the system back gesture has somewhere to go.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<TaskFormCubit>.value(
                    value: cubit,
                    child: TaskFormView(
                      onClose: () {
                        closed++;
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    // Past the route's transition. Not `pumpAndSettle`: a saving form's
    // spinner never settles.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  final empty = TaskFormState(today: demoToday);
  final typed = empty.copyWith(title: 'Something');
  final editing = TaskFormState(
    today: demoToday,
    original: task(title: 'Stored'),
    title: 'Stored',
  );

  testWidgets('a new task: "New task", the fields, no Done switch', (
    tester,
  ) async {
    await pumpView(tester, empty);

    expect(find.widgetWithText(AppBar, 'New task'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Title'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Notes (optional)'), findsOneWidget);
    expect(find.text('Due date'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('editing: "Edit task", the stored text, and the Done switch', (
    tester,
  ) async {
    await pumpView(tester, editing, taskId: 't1');

    expect(find.widgetWithText(AppBar, 'Edit task'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Stored'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('typing reaches the Cubit', (tester) async {
    await pumpView(tester, empty);

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Hello');
    await tester.enterText(
      find.widgetWithText(TextField, 'Notes (optional)'),
      'World',
    );

    verify(() => cubit.titleChanged('Hello')).called(1);
    verify(() => cubit.notesChanged('World')).called(1);
  });

  testWidgets('Save saves', (tester) async {
    await pumpView(tester, typed);

    await tester.tap(find.text('Save'));

    verify(() => cubit.save()).called(1);
  });

  testWidgets('the errors show under their fields', (tester) async {
    await pumpView(tester, empty.copyWith(showErrors: true, notes: 'a' * 1001));

    expect(find.text('Enter a title.'), findsOneWidget);
    expect(
      find.text('Keep the notes to 1000 characters or fewer.'),
      findsOneWidget,
    );
  });

  testWidgets('while saving: Save is off, and shows it is busy', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpView(tester, typed.copyWith(status: TaskFormStatus.saving));

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.bySemanticsLabel('Saving'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a failed save says why', (tester) async {
    await pumpView(tester, typed.copyWith(saveError: 'Disk full.'));
    expect(find.text('Disk full.'), findsOneWidget);
  });

  testWidgets('saved: the form closes (once)', (tester) async {
    await pumpView(
      tester,
      typed,
      then: Stream.fromIterable([
        typed.copyWith(status: TaskFormStatus.saving),
        typed.copyWith(status: TaskFormStatus.saved),
        typed.copyWith(status: TaskFormStatus.saved, showErrors: true),
      ]),
    );
    await tester.pumpAndSettle();

    expect(closed, 1);
  });

  group('the discard guard', () {
    testWidgets('nothing typed: Close leaves at once', (tester) async {
      await pumpView(tester, empty);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      expect(closed, 1);
    });

    testWidgets('something typed: Close asks; Keep editing stays', (
      tester,
    ) async {
      await pumpView(tester, typed);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text("This task won't be saved."), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(closed, 0);
      expect(find.widgetWithText(AppBar, 'New task'), findsOneWidget);
    });

    testWidgets('something typed: Discard leaves', (tester) async {
      await pumpView(tester, typed);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(closed, 1);
    });

    testWidgets('the system back gesture asks too', (tester) async {
      await pumpView(tester, editing.copyWith(title: 'Changed'), taskId: 't1');

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      expect(
        find.text("Your changes to this task won't be saved."),
        findsOneWidget,
      );
    });
  });

  testWidgets('not found: says so, and no Save', (tester) async {
    await pumpView(
      tester,
      empty.copyWith(status: TaskFormStatus.notFound),
      taskId: 'nope',
    );

    expect(find.text('Task not found'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });
}
