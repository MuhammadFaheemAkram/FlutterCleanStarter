import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_clean_starter/features/task_detail/cubit/task_detail_state.dart';
import 'package:injectable/injectable.dart';

/// One task's screen: watch it, tick it off, delete it.
///
/// The task's id arrives through `@factoryParam`: the route knows it, and
/// `getIt<TaskDetailCubit>(param1: id)` passes it in, so the Cubit needs no
/// router and a test constructs it with any id.
@injectable
class TaskDetailCubit extends Cubit<TaskDetailState> {
  TaskDetailCubit(
    @factoryParam this.taskId,
    this._watchTask,
    this._setCompleted,
    this._deleteTask,
    this._clock,
  ) : super(const TaskDetailState());

  final String taskId;
  final WatchTaskUseCase _watchTask;
  final SetTaskCompletedUseCase _setCompleted;
  final DeleteTaskUseCase _deleteTask;
  final Clock _clock;

  StreamSubscription<Task?>? _subscription;

  /// Watches the task: an edit (here or in the form) shows at once, and a
  /// deletion elsewhere turns the screen into "Task not found".
  void load() {
    _subscription ??= _watchTask(taskId).listen((task) {
      final status = state.status;
      // Deleted from here: the row's disappearance is expected.
      if (status == TaskDetailStatus.deleting ||
          status == TaskDetailStatus.deleted) {
        return;
      }
      emit(
        state.copyWith(
          status: task == null
              ? TaskDetailStatus.notFound
              : TaskDetailStatus.ready,
          task: task,
          today: CalendarDate.fromDateTime(_clock.now()),
        ),
      );
    });
  }

  /// Marks the task done, or not done.
  Future<void> toggle() async {
    final task = state.task;
    if (task == null || state.status != TaskDetailStatus.ready) return;
    final result = await _setCompleted(task.id, completed: !task.isCompleted);
    if (isClosed) return;
    if (result case Err(:final exception)) _say(exception.message);
  }

  /// Deletes the task. The view asks first; this only runs once confirmed.
  Future<void> delete() async {
    if (state.status != TaskDetailStatus.ready) return;
    emit(state.copyWith(status: TaskDetailStatus.deleting));
    final result = await _deleteTask(taskId);
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(state.copyWith(status: TaskDetailStatus.deleted));
      case Err(:final exception):
        emit(state.copyWith(status: TaskDetailStatus.ready));
        _say(exception.message);
    }
  }

  void _say(String message) => emit(
    state.copyWith(message: message, messageSerial: state.messageSerial + 1),
  );

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
