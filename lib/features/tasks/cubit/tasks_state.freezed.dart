// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tasks_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TasksState {

 TasksStatus get status;/// In the list's order (`compareTasks`).
 List<Task> get tasks;/// A pull to refresh is running.
 bool get refreshing;/// The user's day, for "Overdue" and "Due today".
 CalendarDate? get today;/// Why the first launch's seed failed ([TasksStatus.error]).
 String? get errorMessage;/// A one-time SnackBar: a refresh's outcome, a failed write.
 String? get message; int get messageSerial;/// The task just deleted, for the SnackBar's Undo.
 Task? get undoable; int get undoSerial;
/// Create a copy of TasksState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TasksStateCopyWith<TasksState> get copyWith => _$TasksStateCopyWithImpl<TasksState>(this as TasksState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TasksState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TasksState&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.tasks, _this.tasks)&&(identical(other.refreshing, _this.refreshing) || other.refreshing == _this.refreshing)&&(identical(other.today, _this.today) || other.today == _this.today)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.messageSerial, _this.messageSerial) || other.messageSerial == _this.messageSerial)&&(identical(other.undoable, _this.undoable) || other.undoable == _this.undoable)&&(identical(other.undoSerial, _this.undoSerial) || other.undoSerial == _this.undoSerial));
}


@override
int get hashCode {
  final _this = this as TasksState;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.tasks),_this.refreshing,_this.today,_this.errorMessage,_this.message,_this.messageSerial,_this.undoable,_this.undoSerial);
}

@override
String toString() {
  final _this = this as TasksState;
  return 'TasksState(status: ${_this.status}, tasks: ${_this.tasks}, refreshing: ${_this.refreshing}, today: ${_this.today}, errorMessage: ${_this.errorMessage}, message: ${_this.message}, messageSerial: ${_this.messageSerial}, undoable: ${_this.undoable}, undoSerial: ${_this.undoSerial})';
}


}

/// @nodoc
abstract mixin class $TasksStateCopyWith<$Res>  {
  factory $TasksStateCopyWith(TasksState value, $Res Function(TasksState) _then) = _$TasksStateCopyWithImpl;
@useResult
$Res call({
 TasksStatus status, List<Task> tasks, bool refreshing, CalendarDate? today, String? errorMessage, String? message, int messageSerial, Task? undoable, int undoSerial
});


$TaskCopyWith<$Res>? get undoable;

}
/// @nodoc
class _$TasksStateCopyWithImpl<$Res>
    implements $TasksStateCopyWith<$Res> {
  _$TasksStateCopyWithImpl(this._self, this._then);

  final TasksState _self;
  final $Res Function(TasksState) _then;

/// Create a copy of TasksState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? tasks = null,Object? refreshing = null,Object? today = freezed,Object? errorMessage = freezed,Object? message = freezed,Object? messageSerial = null,Object? undoable = freezed,Object? undoSerial = null,}) {
  return _then(TasksState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TasksStatus,tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<Task>,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,today: freezed == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as CalendarDate?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,messageSerial: null == messageSerial ? _self.messageSerial : messageSerial // ignore: cast_nullable_to_non_nullable
as int,undoable: freezed == undoable ? _self.undoable : undoable // ignore: cast_nullable_to_non_nullable
as Task?,undoSerial: null == undoSerial ? _self.undoSerial : undoSerial // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of TasksState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res>? get undoable {
    if (_self.undoable == null) {
    return null;
  }

  return $TaskCopyWith<$Res>(_self.undoable!, (value) {
    return _then(_self.copyWith(undoable: value));
  });
}
}


/// Adds pattern-matching-related methods to [TasksState].
extension TasksStatePatterns on TasksState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TasksState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TasksState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TasksState value)  $default,){
final _that = this;
switch (_that) {
case _TasksState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TasksState value)?  $default,){
final _that = this;
switch (_that) {
case _TasksState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TasksStatus status,  List<Task> tasks,  bool refreshing,  CalendarDate? today,  String? errorMessage,  String? message,  int messageSerial,  Task? undoable,  int undoSerial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TasksState() when $default != null:
return $default(_that.status,_that.tasks,_that.refreshing,_that.today,_that.errorMessage,_that.message,_that.messageSerial,_that.undoable,_that.undoSerial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TasksStatus status,  List<Task> tasks,  bool refreshing,  CalendarDate? today,  String? errorMessage,  String? message,  int messageSerial,  Task? undoable,  int undoSerial)  $default,) {final _that = this;
switch (_that) {
case _TasksState():
return $default(_that.status,_that.tasks,_that.refreshing,_that.today,_that.errorMessage,_that.message,_that.messageSerial,_that.undoable,_that.undoSerial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TasksStatus status,  List<Task> tasks,  bool refreshing,  CalendarDate? today,  String? errorMessage,  String? message,  int messageSerial,  Task? undoable,  int undoSerial)?  $default,) {final _that = this;
switch (_that) {
case _TasksState() when $default != null:
return $default(_that.status,_that.tasks,_that.refreshing,_that.today,_that.errorMessage,_that.message,_that.messageSerial,_that.undoable,_that.undoSerial);case _:
  return null;

}
}

}

/// @nodoc


class _TasksState implements TasksState {
  const _TasksState({this.status = TasksStatus.loading,  List<Task> tasks = const <Task>[], this.refreshing = false, this.today, this.errorMessage, this.message, this.messageSerial = 0, this.undoable, this.undoSerial = 0}): _tasks = tasks;
  

@override@JsonKey() final  TasksStatus status;
/// In the list's order (`compareTasks`).
 final  List<Task> _tasks;
/// In the list's order (`compareTasks`).
@override@JsonKey() List<Task> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

/// A pull to refresh is running.
@override@JsonKey() final  bool refreshing;
/// The user's day, for "Overdue" and "Due today".
@override final  CalendarDate? today;
/// Why the first launch's seed failed ([TasksStatus.error]).
@override final  String? errorMessage;
/// A one-time SnackBar: a refresh's outcome, a failed write.
@override final  String? message;
@override@JsonKey() final  int messageSerial;
/// The task just deleted, for the SnackBar's Undo.
@override final  Task? undoable;
@override@JsonKey() final  int undoSerial;

/// Create a copy of TasksState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TasksStateCopyWith<_TasksState> get copyWith => __$TasksStateCopyWithImpl<_TasksState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TasksState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.tasks, _tasks)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.today, today) || other.today == today)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.message, message) || other.message == message)&&(identical(other.messageSerial, messageSerial) || other.messageSerial == messageSerial)&&(identical(other.undoable, undoable) || other.undoable == undoable)&&(identical(other.undoSerial, undoSerial) || other.undoSerial == undoSerial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_tasks),refreshing,today,errorMessage,message,messageSerial,undoable,undoSerial);
}

@override
String toString() {
    return 'TasksState(status: $status, tasks: $tasks, refreshing: $refreshing, today: $today, errorMessage: $errorMessage, message: $message, messageSerial: $messageSerial, undoable: $undoable, undoSerial: $undoSerial)';
}


}

/// @nodoc
abstract mixin class _$TasksStateCopyWith<$Res> implements $TasksStateCopyWith<$Res> {
  factory _$TasksStateCopyWith(_TasksState value, $Res Function(_TasksState) _then) = __$TasksStateCopyWithImpl;
@override @useResult
$Res call({
 TasksStatus status, List<Task> tasks, bool refreshing, CalendarDate? today, String? errorMessage, String? message, int messageSerial, Task? undoable, int undoSerial
});


@override $TaskCopyWith<$Res>? get undoable;

}
/// @nodoc
class __$TasksStateCopyWithImpl<$Res>
    implements _$TasksStateCopyWith<$Res> {
  __$TasksStateCopyWithImpl(this._self, this._then);

  final _TasksState _self;
  final $Res Function(_TasksState) _then;

/// Create a copy of TasksState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? tasks = null,Object? refreshing = null,Object? today = freezed,Object? errorMessage = freezed,Object? message = freezed,Object? messageSerial = null,Object? undoable = freezed,Object? undoSerial = null,}) {
  return _then(_TasksState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TasksStatus,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<Task>,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,today: freezed == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as CalendarDate?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,messageSerial: null == messageSerial ? _self.messageSerial : messageSerial // ignore: cast_nullable_to_non_nullable
as int,undoable: freezed == undoable ? _self.undoable : undoable // ignore: cast_nullable_to_non_nullable
as Task?,undoSerial: null == undoSerial ? _self.undoSerial : undoSerial // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of TasksState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res>? get undoable {
    if (_self.undoable == null) {
    return null;
  }

  return $TaskCopyWith<$Res>(_self.undoable!, (value) {
    return _then(_self.copyWith(undoable: value));
  });
}
}

// dart format on
