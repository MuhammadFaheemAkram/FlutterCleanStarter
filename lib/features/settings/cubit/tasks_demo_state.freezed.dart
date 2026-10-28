// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tasks_demo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TasksDemoState {

 bool get resetting;/// A one-time SnackBar: how the reset went.
 String? get message; int get messageSerial;
/// Create a copy of TasksDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TasksDemoStateCopyWith<TasksDemoState> get copyWith => _$TasksDemoStateCopyWithImpl<TasksDemoState>(this as TasksDemoState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TasksDemoState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TasksDemoState&&(identical(other.resetting, _this.resetting) || other.resetting == _this.resetting)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.messageSerial, _this.messageSerial) || other.messageSerial == _this.messageSerial));
}


@override
int get hashCode {
  final _this = this as TasksDemoState;
  return Object.hash(runtimeType,_this.resetting,_this.message,_this.messageSerial);
}

@override
String toString() {
  final _this = this as TasksDemoState;
  return 'TasksDemoState(resetting: ${_this.resetting}, message: ${_this.message}, messageSerial: ${_this.messageSerial})';
}


}

/// @nodoc
abstract mixin class $TasksDemoStateCopyWith<$Res>  {
  factory $TasksDemoStateCopyWith(TasksDemoState value, $Res Function(TasksDemoState) _then) = _$TasksDemoStateCopyWithImpl;
@useResult
$Res call({
 bool resetting, String? message, int messageSerial
});




}
/// @nodoc
class _$TasksDemoStateCopyWithImpl<$Res>
    implements $TasksDemoStateCopyWith<$Res> {
  _$TasksDemoStateCopyWithImpl(this._self, this._then);

  final TasksDemoState _self;
  final $Res Function(TasksDemoState) _then;

/// Create a copy of TasksDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resetting = null,Object? message = freezed,Object? messageSerial = null,}) {
  return _then(TasksDemoState(
resetting: null == resetting ? _self.resetting : resetting // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,messageSerial: null == messageSerial ? _self.messageSerial : messageSerial // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TasksDemoState].
extension TasksDemoStatePatterns on TasksDemoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TasksDemoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TasksDemoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TasksDemoState value)  $default,){
final _that = this;
switch (_that) {
case _TasksDemoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TasksDemoState value)?  $default,){
final _that = this;
switch (_that) {
case _TasksDemoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool resetting,  String? message,  int messageSerial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TasksDemoState() when $default != null:
return $default(_that.resetting,_that.message,_that.messageSerial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool resetting,  String? message,  int messageSerial)  $default,) {final _that = this;
switch (_that) {
case _TasksDemoState():
return $default(_that.resetting,_that.message,_that.messageSerial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool resetting,  String? message,  int messageSerial)?  $default,) {final _that = this;
switch (_that) {
case _TasksDemoState() when $default != null:
return $default(_that.resetting,_that.message,_that.messageSerial);case _:
  return null;

}
}

}

/// @nodoc


class _TasksDemoState implements TasksDemoState {
  const _TasksDemoState({this.resetting = false, this.message, this.messageSerial = 0});
  

@override@JsonKey() final  bool resetting;
/// A one-time SnackBar: how the reset went.
@override final  String? message;
@override@JsonKey() final  int messageSerial;

/// Create a copy of TasksDemoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TasksDemoStateCopyWith<_TasksDemoState> get copyWith => __$TasksDemoStateCopyWithImpl<_TasksDemoState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TasksDemoState&&(identical(other.resetting, resetting) || other.resetting == resetting)&&(identical(other.message, message) || other.message == message)&&(identical(other.messageSerial, messageSerial) || other.messageSerial == messageSerial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,resetting,message,messageSerial);
}

@override
String toString() {
    return 'TasksDemoState(resetting: $resetting, message: $message, messageSerial: $messageSerial)';
}


}

/// @nodoc
abstract mixin class _$TasksDemoStateCopyWith<$Res> implements $TasksDemoStateCopyWith<$Res> {
  factory _$TasksDemoStateCopyWith(_TasksDemoState value, $Res Function(_TasksDemoState) _then) = __$TasksDemoStateCopyWithImpl;
@override @useResult
$Res call({
 bool resetting, String? message, int messageSerial
});




}
/// @nodoc
class __$TasksDemoStateCopyWithImpl<$Res>
    implements _$TasksDemoStateCopyWith<$Res> {
  __$TasksDemoStateCopyWithImpl(this._self, this._then);

  final _TasksDemoState _self;
  final $Res Function(_TasksDemoState) _then;

/// Create a copy of TasksDemoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resetting = null,Object? message = freezed,Object? messageSerial = null,}) {
  return _then(_TasksDemoState(
resetting: null == resetting ? _self.resetting : resetting // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,messageSerial: null == messageSerial ? _self.messageSerial : messageSerial // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
