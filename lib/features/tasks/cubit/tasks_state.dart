import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tasks_state.freezed.dart';

/// What the Tasks screen shows.
enum TasksStatus {
  /// Before the first answer: the stored tasks, or the first launch's seed.
  loading,

  /// At least one task.
  ready,

  /// No tasks (the user deleted them all, or started without the demo).
  empty,

  /// The first launch's seed failed and nothing is stored: [TasksState.
  /// errorMessage] says why, and Try again seeds again.
  error,
}

/// Everything the Tasks screen draws, in one immutable value.
///
/// One-time effects (a SnackBar, the Undo offer) are values with a *serial*:
/// the view reacts when the serial changes, so each fires once, and a
/// rebuild for another reason doesn't show it again.
@freezed
abstract class TasksState with _$TasksState {
  const factory TasksState({
    @Default(TasksStatus.loading) TasksStatus status,

    /// In the list's order (`compareTasks`).
    @Default(<Task>[]) List<Task> tasks,

    /// A pull to refresh is running.
    @Default(false) bool refreshing,

    /// The user's day, for "Overdue" and "Due today".
    CalendarDate? today,

    /// Why the first launch's seed failed ([TasksStatus.error]).
    String? errorMessage,

    /// A one-time SnackBar: a refresh's outcome, a failed write.
    String? message,
    @Default(0) int messageSerial,

    /// The task just deleted, for the SnackBar's Undo.
    Task? undoable,
    @Default(0) int undoSerial,
  }) = _TasksState;
}
