import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_clean_starter/features/task_form/cubit/task_form_state.dart';
import 'package:injectable/injectable.dart';

/// The Add / Edit form: one Cubit for both, chosen by [taskId] (`null` for a
/// new task), which arrives through `@factoryParam`.
@injectable
class TaskFormCubit extends Cubit<TaskFormState> {
  TaskFormCubit(
    @factoryParam this.taskId,
    this._watchTask,
    this._addTask,
    this._updateTask,
    Clock clock,
  ) : super(
        TaskFormState(
          status: taskId == null
              ? TaskFormStatus.editing
              : TaskFormStatus.loading,
          today: CalendarDate.fromDateTime(clock.now()),
        ),
      );

  final String? taskId;
  final WatchTaskUseCase _watchTask;
  final AddTaskUseCase _addTask;
  final UpdateTaskUseCase _updateTask;

  /// For an edit, fills the fields from the stored task, once: a change made
  /// elsewhere afterwards mustn't overwrite what's being typed.
  Future<void> load() async {
    final id = taskId;
    if (id == null || state.status != TaskFormStatus.loading) return;
    final task = await _watchTask(id).first;
    if (isClosed) return;
    emit(
      task == null
          ? state.copyWith(status: TaskFormStatus.notFound)
          : state.copyWith(
              status: TaskFormStatus.editing,
              original: task,
              title: task.title,
              notes: task.notes,
              due: task.due,
              isCompleted: task.isCompleted,
            ),
    );
  }

  void titleChanged(String title) => emit(state.copyWith(title: title));

  void notesChanged(String notes) => emit(state.copyWith(notes: notes));

  void dueChanged(CalendarDate? due) => emit(state.copyWith(due: due));

  void completedChanged({required bool completed}) =>
      emit(state.copyWith(isCompleted: completed));

  /// Shows the errors from now on, and saves if there are none. A second
  /// tap while saving does nothing.
  Future<void> save() async {
    if (state.status != TaskFormStatus.editing) return;
    emit(state.copyWith(showErrors: true, saveError: null));
    if (!state.isValid) return;
    emit(state.copyWith(status: TaskFormStatus.saving));
    final original = state.original;
    final Result<Object?> result = original == null
        ? await _addTask(
            TaskDraft(title: state.title, notes: state.notes, due: state.due),
          )
        : await _updateTask(
            original.copyWith(
              title: state.title,
              notes: state.notes,
              due: state.due,
              isCompleted: state.isCompleted,
            ),
          );
    if (isClosed) return;
    emit(switch (result) {
      Ok() => state.copyWith(status: TaskFormStatus.saved),
      Err(:final exception) => state.copyWith(
        status: TaskFormStatus.editing,
        saveError: exception.message,
      ),
    });
  }
}
