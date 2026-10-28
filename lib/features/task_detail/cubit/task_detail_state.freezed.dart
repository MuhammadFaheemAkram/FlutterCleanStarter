// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskDetailState {

 TaskDetailStatus get status; Task? get task;/// The user's day, for "Overdue".
 CalendarDate? get today;/// A one-time SnackBar (a failed write).
 String? get message; int get messageSerial;
/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDetailStateCopyWith<TaskDetailState> get copyWith => _$TaskDetailStateCopyWithImpl<TaskDetailState>(this as TaskDetailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskDetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDetailState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.task, _this.task) || other.task == _this.task)&&(identical(other.today, _this.today) || other.today == _this.today)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.messageSerial, _this.messageSerial) || other.messageSerial == _this.messageSerial));
}


@override
int get hashCode {
  final _this = this as TaskDetailState;
  return Object.hash(runtimeType,_this.status,_this.task,_this.today,_this.message,_this.messageSerial);
}

@override
String toString() {
  final _this = this as TaskDetailState;
  return 'TaskDetailState(status: ${_this.status}, task: ${_this.task}, today: ${_this.today}, message: ${_this.message}, messageSerial: ${_this.messageSerial})';
}


}

/// @nodoc
abstract mixin class $TaskDetailStateCopyWith<$Res>  {
  factory $TaskDetailStateCopyWith(TaskDetailState value, $Res Function(TaskDetailState) _then) = _$TaskDetailStateCopyWithImpl;
@useResult
$Res call({
 TaskDetailStatus status, Task? task, CalendarDate? today, String? message, int messageSerial
});


$TaskCopyWith<$Res>? get task;

}
/// @nodoc
class _$TaskDetailStateCopyWithImpl<$Res>
    implements $TaskDetailStateCopyWith<$Res> {
  _$TaskDetailStateCopyWithImpl(this._self, this._then);

  final TaskDetailState _self;
  final $Res Function(TaskDetailState) _then;

/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? task = freezed,Object? today = freezed,Object? message = freezed,Object? messageSerial = null,}) {
  return _then(TaskDetailState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskDetailStatus,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task?,today: freezed == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as CalendarDate?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,messageSerial: null == messageSerial ? _self.messageSerial : messageSerial // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res>? get task {
    if (_self.task == null) {
    return null;
  }

  return $TaskCopyWith<$Res>(_self.task!, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskDetailState].
extension TaskDetailStatePatterns on TaskDetailState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskDetailState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskDetailState value)  $default,){
final _that = this;
switch (_that) {
case _TaskDetailState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _TaskDetailState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TaskDetailStatus status,  Task? task,  CalendarDate? today,  String? message,  int messageSerial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskDetailState() when $default != null:
return $default(_that.status,_that.task,_that.today,_that.message,_that.messageSerial);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TaskDetailStatus status,  Task? task,  CalendarDate? today,  String? message,  int messageSerial)  $default,) {final _that = this;
switch (_that) {
case _TaskDetailState():
return $default(_that.status,_that.task,_that.today,_that.message,_that.messageSerial);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TaskDetailStatus status,  Task? task,  CalendarDate? today,  String? message,  int messageSerial)?  $default,) {final _that = this;
switch (_that) {
case _TaskDetailState() when $default != null:
return $default(_that.status,_that.task,_that.today,_that.message,_that.messageSerial);case _:
  return null;

}
}

}

/// @nodoc


class _TaskDetailState implements TaskDetailState {
  const _TaskDetailState({this.status = TaskDetailStatus.loading, this.task, this.today, this.message, this.messageSerial = 0});
  

@override@JsonKey() final  TaskDetailStatus status;
@override final  Task? task;
/// The user's day, for "Overdue".
@override final  CalendarDate? today;
/// A one-time SnackBar (a failed write).
@override final  String? message;
@override@JsonKey() final  int messageSerial;

/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskDetailStateCopyWith<_TaskDetailState> get copyWith => __$TaskDetailStateCopyWithImpl<_TaskDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskDetailState&&(identical(other.status, status) || other.status == status)&&(identical(other.task, task) || other.task == task)&&(identical(other.today, today) || other.today == today)&&(identical(other.message, message) || other.message == message)&&(identical(other.messageSerial, messageSerial) || other.messageSerial == messageSerial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,task,today,message,messageSerial);
}

@override
String toString() {
    return 'TaskDetailState(status: $status, task: $task, today: $today, message: $message, messageSerial: $messageSerial)';
}


}

/// @nodoc
abstract mixin class _$TaskDetailStateCopyWith<$Res> implements $TaskDetailStateCopyWith<$Res> {
  factory _$TaskDetailStateCopyWith(_TaskDetailState value, $Res Function(_TaskDetailState) _then) = __$TaskDetailStateCopyWithImpl;
@override @useResult
$Res call({
 TaskDetailStatus status, Task? task, CalendarDate? today, String? message, int messageSerial
});


@override $TaskCopyWith<$Res>? get task;

}
/// @nodoc
class __$TaskDetailStateCopyWithImpl<$Res>
    implements _$TaskDetailStateCopyWith<$Res> {
  __$TaskDetailStateCopyWithImpl(this._self, this._then);

  final _TaskDetailState _self;
  final $Res Function(_TaskDetailState) _then;

/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? task = freezed,Object? today = freezed,Object? message = freezed,Object? messageSerial = null,}) {
  return _then(_TaskDetailState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskDetailStatus,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task?,today: freezed == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as CalendarDate?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,messageSerial: null == messageSerial ? _self.messageSerial : messageSerial // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res>? get task {
    if (_self.task == null) {
    return null;
  }

  return $TaskCopyWith<$Res>(_self.task!, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}

// dart format on
