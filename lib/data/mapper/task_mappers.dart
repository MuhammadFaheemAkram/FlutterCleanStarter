import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/database/app_database.dart';
import 'package:flutter_clean_starter/core/network/dto/task_dto.dart';
import 'package:flutter_clean_starter/domain/calculation/task_rules.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';

// Three models for one task, one per layer, and the mappers between them:
//
//   TaskDto (the API's JSON) ──toTask()──▶ Task (the app's) ◀──▶ TaskRow (drift)
//
// The server's data is checked here, *before* anything is stored: a task
// that breaks the app's rules makes the whole answer a
// `DataFormatException`, and nothing is written.

extension TaskDtoMapper on TaskDto {
  /// The domain [Task], or a [DataFormatException] when the record breaks a
  /// rule: an empty id or title, a title or notes too long, a due date that
  /// isn't a day, a time that isn't UTC, or an update before the creation.
  Task toTask() {
    final due = this.due;
    if (id.trim().isEmpty ||
        TaskRules.firstError(title: title, notes: notes) != null ||
        !createdAt.isUtc ||
        !updatedAt.isUtc ||
        updatedAt.isBefore(createdAt)) {
      throw const DataFormatException();
    }
    final CalendarDate? dueDay;
    try {
      dueDay = due == null ? null : CalendarDate.parse(due);
    } on FormatException {
      throw const DataFormatException();
    }
    return Task(
      id: id,
      title: title.trim(),
      notes: notes,
      due: dueDay,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension TaskDtoListMapper on List<TaskDto> {
  /// Every task, or a [DataFormatException] when any record is damaged or
  /// two share an id.
  List<Task> toTasks() {
    final tasks = [for (final dto in this) dto.toTask()];
    if (tasks.map((task) => task.id).toSet().length != tasks.length) {
      throw const DataFormatException();
    }
    return tasks;
  }
}

extension TaskRowMapper on TaskRow {
  Task toTask() => Task(
    id: id,
    title: title,
    notes: notes,
    due: switch (dueDay) {
      final day? => CalendarDate.fromInt(day),
      null => null,
    },
    isCompleted: isCompleted,
    createdAt: createdAt.toUtc(),
    updatedAt: updatedAt.toUtc(),
  );
}

extension TaskToRow on Task {
  TaskRow toRow() => TaskRow(
    id: id,
    title: title,
    notes: notes,
    dueDay: due?.yyyymmdd,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
