// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, unused_field

part of 'task_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskDto _$TaskDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TaskDto', json, ($checkedConvert) {
  final val = TaskDto(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    notes: $checkedConvert('notes', (v) => v as String),
    due: $checkedConvert('due', (v) => v as String?),
    isCompleted: $checkedConvert('isCompleted', (v) => v as bool),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});
