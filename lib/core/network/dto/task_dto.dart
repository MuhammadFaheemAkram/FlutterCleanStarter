import 'package:json_annotation/json_annotation.dart';

part 'task_dto.g.dart';

/// A task as the server sends it: the API's format, not the app's.
///
/// `checked: true` (in `build.yaml`) makes a wrong type fail with the
/// field's name. The mapper (`TaskDto.toTask`) then checks the app's rules
/// before anything is stored.
@JsonSerializable(createToJson: false)
class TaskDto {
  const TaskDto({
    required this.id,
    required this.title,
    required this.notes,
    required this.due,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);

  final String id;
  final String title;
  final String notes;

  /// A calendar day, `2026-10-29`, or `null`.
  final String? due;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
}
