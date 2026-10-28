// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskFormState {

 TaskFormStatus get status; String get title; String get notes; CalendarDate? get due; bool get isCompleted;/// After the first Save.
 bool get showErrors;/// The task as stored, when editing; `null` for a new one.
 Task? get original;/// Why the last save failed (a database error), shown under the form.
 String? get saveError;/// The user's day: where the date picker opens.
 CalendarDate? get today;
/// Create a copy of TaskFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskFormStateCopyWith<TaskFormState> get copyWith => _$TaskFormStateCopyWithImpl<TaskFormState>(this as TaskFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskFormState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.due, _this.due) || other.due == _this.due)&&(identical(other.isCompleted, _this.isCompleted) || other.isCompleted == _this.isCompleted)&&(identical(other.showErrors, _this.showErrors) || other.showErrors == _this.showErrors)&&(identical(other.original, _this.original) || other.original == _this.original)&&(identical(other.saveError, _this.saveError) || other.saveError == _this.saveError)&&(identical(other.today, _this.today) || other.today == _this.today));
}


@override
int get hashCode {
  final _this = this as TaskFormState;
  return Object.hash(runtimeType,_this.status,_this.title,_this.notes,_this.due,_this.isCompleted,_this.showErrors,_this.original,_this.saveError,_this.today);
}

@override
String toString() {
  final _this = this as TaskFormState;
  return 'TaskFormState(status: ${_this.status}, title: ${_this.title}, notes: ${_this.notes}, due: ${_this.due}, isCompleted: ${_this.isCompleted}, showErrors: ${_this.showErrors}, original: ${_this.original}, saveError: ${_this.saveError}, today: ${_this.today})';
}


}

/// @nodoc
abstract mixin class $TaskFormStateCopyWith<$Res>  {
  factory $TaskFormStateCopyWith(TaskFormState value, $Res Function(TaskFormState) _then) = _$TaskFormStateCopyWithImpl;
@useResult
$Res call({
 TaskFormStatus status, String title, String notes, CalendarDate? due, bool isCompleted, bool showErrors, Task? original, String? saveError, CalendarDate? today
});


$TaskCopyWith<$Res>? get original;

}
/// @nodoc
class _$TaskFormStateCopyWithImpl<$Res>
    implements $TaskFormStateCopyWith<$Res> {
  _$TaskFormStateCopyWithImpl(this._self, this._then);

  final TaskFormState _self;
  final $Res Function(TaskFormState) _then;

/// Create a copy of TaskFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? title = null,Object? notes = null,Object? due = freezed,Object? isCompleted = null,Object? showErrors = null,Object? original = freezed,Object? saveError = freezed,Object? today = freezed,}) {
  return _then(TaskFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskFormStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as CalendarDate?,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Task?,saveError: freezed == saveError ? _self.saveError : saveError // ignore: cast_nullable_to_non_nullable
as String?,today: freezed == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as CalendarDate?,
  ));
}
/// Create a copy of TaskFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $TaskCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskFormState].
extension TaskFormStatePatterns on TaskFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskFormState value)  $default,){
final _that = this;
switch (_that) {
case _TaskFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskFormState value)?  $default,){
final _that = this;
switch (_that) {
case _TaskFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TaskFormStatus status,  String title,  String notes,  CalendarDate? due,  bool isCompleted,  bool showErrors,  Task? original,  String? saveError,  CalendarDate? today)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskFormState() when $default != null:
return $default(_that.status,_that.title,_that.notes,_that.due,_that.isCompleted,_that.showErrors,_that.original,_that.saveError,_that.today);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TaskFormStatus status,  String title,  String notes,  CalendarDate? due,  bool isCompleted,  bool showErrors,  Task? original,  String? saveError,  CalendarDate? today)  $default,) {final _that = this;
switch (_that) {
case _TaskFormState():
return $default(_that.status,_that.title,_that.notes,_that.due,_that.isCompleted,_that.showErrors,_that.original,_that.saveError,_that.today);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TaskFormStatus status,  String title,  String notes,  CalendarDate? due,  bool isCompleted,  bool showErrors,  Task? original,  String? saveError,  CalendarDate? today)?  $default,) {final _that = this;
switch (_that) {
case _TaskFormState() when $default != null:
return $default(_that.status,_that.title,_that.notes,_that.due,_that.isCompleted,_that.showErrors,_that.original,_that.saveError,_that.today);case _:
  return null;

}
}

}

/// @nodoc


class _TaskFormState extends TaskFormState {
  const _TaskFormState({this.status = TaskFormStatus.editing, this.title = '', this.notes = '', this.due, this.isCompleted = false, this.showErrors = false, this.original, this.saveError, this.today}): super._();
  

@override@JsonKey() final  TaskFormStatus status;
@override@JsonKey() final  String title;
@override@JsonKey() final  String notes;
@override final  CalendarDate? due;
@override@JsonKey() final  bool isCompleted;
/// After the first Save.
@override@JsonKey() final  bool showErrors;
/// The task as stored, when editing; `null` for a new one.
@override final  Task? original;
/// Why the last save failed (a database error), shown under the form.
@override final  String? saveError;
/// The user's day: where the date picker opens.
@override final  CalendarDate? today;

/// Create a copy of TaskFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskFormStateCopyWith<_TaskFormState> get copyWith => __$TaskFormStateCopyWithImpl<_TaskFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskFormState&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.due, due) || other.due == due)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.showErrors, showErrors) || other.showErrors == showErrors)&&(identical(other.original, original) || other.original == original)&&(identical(other.saveError, saveError) || other.saveError == saveError)&&(identical(other.today, today) || other.today == today));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,title,notes,due,isCompleted,showErrors,original,saveError,today);
}

@override
String toString() {
    return 'TaskFormState(status: $status, title: $title, notes: $notes, due: $due, isCompleted: $isCompleted, showErrors: $showErrors, original: $original, saveError: $saveError, today: $today)';
}


}

/// @nodoc
abstract mixin class _$TaskFormStateCopyWith<$Res> implements $TaskFormStateCopyWith<$Res> {
  factory _$TaskFormStateCopyWith(_TaskFormState value, $Res Function(_TaskFormState) _then) = __$TaskFormStateCopyWithImpl;
@override @useResult
$Res call({
 TaskFormStatus status, String title, String notes, CalendarDate? due, bool isCompleted, bool showErrors, Task? original, String? saveError, CalendarDate? today
});


@override $TaskCopyWith<$Res>? get original;

}
/// @nodoc
class __$TaskFormStateCopyWithImpl<$Res>
    implements _$TaskFormStateCopyWith<$Res> {
  __$TaskFormStateCopyWithImpl(this._self, this._then);

  final _TaskFormState _self;
  final $Res Function(_TaskFormState) _then;

/// Create a copy of TaskFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? title = null,Object? notes = null,Object? due = freezed,Object? isCompleted = null,Object? showErrors = null,Object? original = freezed,Object? saveError = freezed,Object? today = freezed,}) {
  return _then(_TaskFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskFormStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as CalendarDate?,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Task?,saveError: freezed == saveError ? _self.saveError : saveError // ignore: cast_nullable_to_non_nullable
as String?,today: freezed == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as CalendarDate?,
  ));
}

/// Create a copy of TaskFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $TaskCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
