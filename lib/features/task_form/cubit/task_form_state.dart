import 'package:flutter_clean_starter/domain/calculation/task_rules.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_form_state.freezed.dart';

enum TaskFormStatus {
  /// Reading the task to edit.
  loading,
  editing,
  saving,

  /// Saved: the view closes the form (a one-time effect: it happens once).
  saved,

  /// The task to edit doesn't exist (a stale link).
  notFound,
}

/// The form's fields and where it is in its life.
///
/// The field errors are *derived* (getters over [TaskRules]), not stored:
/// they can never disagree with the text, and they show only once the user
/// has tried to save ([showErrors]), so a new form doesn't open in red.
@freezed
abstract class TaskFormState with _$TaskFormState {
  const factory TaskFormState({
    @Default(TaskFormStatus.editing) TaskFormStatus status,
    @Default('') String title,
    @Default('') String notes,
    CalendarDate? due,
    @Default(false) bool isCompleted,

    /// After the first Save.
    @Default(false) bool showErrors,

    /// The task as stored, when editing; `null` for a new one.
    Task? original,

    /// Why the last save failed (a database error), shown under the form.
    String? saveError,

    /// The user's day: where the date picker opens.
    CalendarDate? today,
  }) = _TaskFormState;

  const TaskFormState._();

  bool get isEditing => original != null;

  String? get titleError => showErrors ? TaskRules.titleError(title) : null;

  String? get notesError => showErrors ? TaskRules.notesError(notes) : null;

  bool get isValid => TaskRules.firstError(title: title, notes: notes) == null;

  /// Whether leaving would lose something: the discard guard asks first.
  bool get hasChanges {
    final original = this.original;
    if (original == null) {
      return title.trim().isNotEmpty || notes.trim().isNotEmpty || due != null;
    }
    return title != original.title ||
        notes != original.notes ||
        due != original.due ||
        isCompleted != original.isCompleted;
  }
}
