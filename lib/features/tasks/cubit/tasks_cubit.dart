import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_clean_starter/features/tasks/cubit/tasks_state.dart';
import 'package:injectable/injectable.dart';

/// The Tasks screen's logic: watch the stored tasks, seed on first launch,
/// refresh, toggle, delete with Undo.
///
/// A Cubit, not a Bloc: every action is a plain method call with no timing
/// rules (no debounce, no dropping of overlapping calls), and a Bloc's
/// events would only add ceremony. A search box with a debounce is where a
/// Bloc earns its place.
///
/// It never navigates and never shows anything itself: it emits state, and
/// the view decides what that looks like (a SnackBar, a route).
@injectable
class TasksCubit extends Cubit<TasksState> {
  TasksCubit(
    this._watchTasks,
    this._seedTasks,
    this._refreshTasks,
    this._setCompleted,
    this._deleteTask,
    this._restoreTask,
    this._clock,
  ) : super(const TasksState());

  final WatchTasksUseCase _watchTasks;
  final SeedTasksUseCase _seedTasks;
  final RefreshTasksUseCase _refreshTasks;
  final SetTaskCompletedUseCase _setCompleted;
  final DeleteTaskUseCase _deleteTask;
  final RestoreTaskUseCase _restoreTask;
  final Clock _clock;

  StreamSubscription<List<Task>>? _subscription;

  /// What drift last said; `null` before its first answer.
  List<Task>? _stored;

  /// Tasks swiped away whose deletion drift hasn't reported yet. They leave
  /// the list at once: a swiped-away row rebuilt into the list would throw
  /// (conventions §11.13).
  final _hidden = <String>{};

  var _seeding = false;
  AppException? _seedError;

  /// Starts watching the store, then seeds it on first launch (a no-op
  /// afterwards).
  Future<void> load() async {
    _subscription ??= _watchTasks().listen((tasks) {
      _stored = tasks;
      // Drift agrees now: a hidden task it no longer lists is gone.
      _hidden.removeWhere((id) => !tasks.any((task) => task.id == id));
      _publish();
    });
    await _seed();
  }

  /// The error state's Try again.
  Future<void> retry() => _seed();

  Future<void> _seed() async {
    _seeding = true;
    _seedError = null;
    _publish();
    final result = await _seedTasks();
    if (isClosed) return;
    // The store as it is *now*: drift's stream may not have reported the
    // seed's rows yet, and deciding on its older answer (no tasks) would
    // flash "No tasks yet" (conventions §11.32, §11.33).
    final stored = await _watchTasks().first;
    if (isClosed) return;
    _stored = stored;
    _seeding = false;
    _seedError = switch (result) {
      Ok() => null,
      Err(:final exception) => exception,
    };
    _publish();
  }

  /// Pull to refresh: the server's new tasks are added; offline, the list
  /// stays and a SnackBar says why.
  Future<void> refresh() async {
    if (state.refreshing) return;
    emit(state.copyWith(refreshing: true));
    final result = await _refreshTasks();
    if (isClosed) return;
    emit(state.copyWith(refreshing: false));
    _say(switch (result) {
      Ok(value: 0) => "You're up to date.",
      Ok(value: 1) => '1 new task from the server.',
      Ok(:final value) => '$value new tasks from the server.',
      Err(:final exception) => exception.message,
    });
  }

  /// Marks [task] done, or not done.
  Future<void> toggle(Task task) async {
    final result = await _setCompleted(task.id, completed: !task.isCompleted);
    if (isClosed) return;
    if (result case Err(:final exception)) _say(exception.message);
  }

  /// Deletes [task], offering Undo.
  Future<void> delete(Task task) async {
    _hidden.add(task.id);
    _publish();
    final result = await _deleteTask(task.id);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(undoable: value, undoSerial: state.undoSerial + 1));
      case Err(:final exception):
        // Nothing was deleted: the row comes back.
        _hidden.remove(task.id);
        _publish();
        _say(exception.message);
    }
  }

  /// The SnackBar's Undo: puts [task] back exactly as it was.
  Future<void> undo(Task task) async {
    // Shown again at once, whether or not drift has reported the delete.
    _hidden.remove(task.id);
    _publish();
    final result = await _restoreTask(task);
    if (isClosed) return;
    if (result case Err(:final exception)) _say(exception.message);
  }

  void _publish() {
    final visible = _stored
        ?.where((task) => !_hidden.contains(task.id))
        .toList();
    final status = switch (visible) {
      _ when _seeding => TasksStatus.loading,
      null => TasksStatus.loading,
      [_, ...] => TasksStatus.ready,
      [] when _seedError != null => TasksStatus.error,
      [] => TasksStatus.empty,
    };
    emit(
      state.copyWith(
        status: status,
        tasks: visible ?? const [],
        today: CalendarDate.fromDateTime(_clock.now()),
        errorMessage: _seedError?.message,
      ),
    );
  }

  void _say(String message) => emit(
    state.copyWith(message: message, messageSerial: state.messageSerial + 1),
  );

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
