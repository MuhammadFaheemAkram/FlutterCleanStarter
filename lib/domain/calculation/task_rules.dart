import 'package:characters/characters.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';

/// The rules a task must follow, in one place: the form shows them under
/// its fields, the use cases refuse what slips past, and the database's
/// `CHECK`s are the last guard.
///
/// Pure functions of their input: no Flutter, no I/O, so each is a one-line
/// unit test.
abstract final class TaskRules {
  static const titleMaxLength = 80;
  static const notesMaxLength = 1000;

  /// Why [title] can't be saved, or `null` when it can.
  ///
  /// Lengths count *grapheme clusters* (what a reader sees as one
  /// character), not UTF-16 code units: "👩‍💻" is one character, though
  /// `String.length` says 5.
  static String? titleError(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return 'Enter a title.';
    if (trimmed.characters.length > titleMaxLength) {
      return 'Keep the title to $titleMaxLength characters or fewer.';
    }
    return null;
  }

  /// Why [notes] can't be saved, or `null` when they can.
  static String? notesError(String notes) {
    if (notes.characters.length > notesMaxLength) {
      return 'Keep the notes to $notesMaxLength characters or fewer.';
    }
    return null;
  }

  /// The first error in [title] and [notes], or `null` when both are fine.
  static String? firstError({required String title, required String notes}) =>
      titleError(title) ?? notesError(notes);
}

/// Whether [task] is overdue on [today]: not done, and due *before* today.
///
/// A task due today isn't overdue yet; a done task never is.
bool isOverdue(Task task, CalendarDate today) {
  final due = task.due;
  return !task.isCompleted && due != null && due < today;
}

/// The Tasks list's order: open tasks first, then by due date (the soonest
/// first, no date last), then the newest first. The id breaks the last tie,
/// so the order never changes between two reads.
int compareTasks(Task a, Task b) {
  if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
  final (dueA, dueB) = (a.due, b.due);
  if (dueA != dueB) {
    if (dueA == null) return 1;
    if (dueB == null) return -1;
    return dueA.yyyymmdd.compareTo(dueB.yyyymmdd);
  }
  final byCreated = b.createdAt.compareTo(a.createdAt);
  return byCreated != 0 ? byCreated : a.id.compareTo(b.id);
}
