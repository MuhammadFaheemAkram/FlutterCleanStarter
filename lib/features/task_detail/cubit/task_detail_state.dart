import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_detail_state.freezed.dart';

enum TaskDetailStatus {
  loading,
  ready,

  /// No such task: a stale link, or deleted elsewhere.
  notFound,

  /// Deleting it, after the user confirmed.
  deleting,

  /// Deleted from here: the view leaves.
  deleted,
}

@freezed
abstract class TaskDetailState with _$TaskDetailState {
  const factory TaskDetailState({
    @Default(TaskDetailStatus.loading) TaskDetailStatus status,
    Task? task,

    /// The user's day, for "Overdue".
    CalendarDate? today,

    /// A one-time SnackBar (a failed write).
    String? message,
    @Default(0) int messageSerial,
  }) = _TaskDetailState;
}
