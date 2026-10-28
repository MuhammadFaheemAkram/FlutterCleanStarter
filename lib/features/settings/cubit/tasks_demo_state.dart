import 'package:freezed_annotation/freezed_annotation.dart';

part 'tasks_demo_state.freezed.dart';

@freezed
abstract class TasksDemoState with _$TasksDemoState {
  const factory TasksDemoState({
    @Default(false) bool resetting,

    /// A one-time SnackBar: how the reset went.
    String? message,
    @Default(0) int messageSerial,
  }) = _TasksDemoState;
}
