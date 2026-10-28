import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

/// A task: the sample feature's one domain model.
///
/// Domain models are plain Dart: no JSON (that's `TaskDto`) and no database
/// row (that's `TaskRow`). Each layer has its own model, and mappers turn
/// one into the next, so a change to the API's format or the table's columns
/// stops at the mapper.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    @Default('') String notes,

    /// A calendar day, not an instant (see [CalendarDate]); `null` when the
    /// task has no due date.
    CalendarDate? due,
    @Default(false) bool isCompleted,

    /// UTC. Set once, when the task is created (on the device or the
    /// server), and never changed.
    required DateTime createdAt,

    /// UTC. Changes on every edit and every toggle.
    required DateTime updatedAt,
  }) = _Task;
}

/// What the user typed into the form: a task without an id or times, which
/// the repository adds when it saves it.
@freezed
abstract class TaskDraft with _$TaskDraft {
  const factory TaskDraft({
    required String title,
    @Default('') String notes,
    CalendarDate? due,
  }) = _TaskDraft;
}
