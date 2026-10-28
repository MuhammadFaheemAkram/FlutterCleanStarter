import 'package:flutter_clean_starter/core/network/dto/task_dto.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';

/// "Now" in every test: Wednesday 28 October 2026, 14:00 UTC.
final demoNow = DateTime.utc(2026, 10, 28, 14);

/// The day of [demoNow]: the tests' "today".
final demoToday = CalendarDate(2026, 10, 28);

/// A task with sensible defaults; name only what a test is about.
Task task({
  String id = 't1',
  String title = 'Write the tests',
  String notes = '',
  CalendarDate? due,
  bool isCompleted = false,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final created = createdAt ?? DateTime.utc(2026, 10, 1, 9);
  return Task(
    id: id,
    title: title,
    notes: notes,
    due: due,
    isCompleted: isCompleted,
    createdAt: created,
    updatedAt: updatedAt ?? created,
  );
}

/// A task as the server sends it.
TaskDto taskDto({
  String id = 's1',
  String title = 'From the server',
  String notes = '',
  String? due,
  bool isCompleted = false,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final created = createdAt ?? DateTime.utc(2026, 10, 1, 9);
  return TaskDto(
    id: id,
    title: title,
    notes: notes,
    due: due,
    isCompleted: isCompleted,
    createdAt: created,
    updatedAt: updatedAt ?? created,
  );
}
