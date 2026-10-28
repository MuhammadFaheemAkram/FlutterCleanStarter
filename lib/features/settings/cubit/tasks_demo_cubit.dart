import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/common/result.dart';
import 'package:flutter_clean_starter/domain/usecase/task_use_cases.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_state.dart';
import 'package:injectable/injectable.dart';

/// Settings → Data → Reset demo data: the sample feature's part of the
/// Settings screen (removed with it).
///
/// The view asks first; this replaces every task with the server's, in one
/// transaction. Offline nothing changes, and the SnackBar says why.
@injectable
class TasksDemoCubit extends Cubit<TasksDemoState> {
  TasksDemoCubit(this._resetDemoData) : super(const TasksDemoState());

  final ResetDemoDataUseCase _resetDemoData;

  Future<void> reset() async {
    if (state.resetting) return;
    emit(state.copyWith(resetting: true));
    final result = await _resetDemoData();
    if (isClosed) return;
    emit(
      state.copyWith(
        resetting: false,
        message: switch (result) {
          Ok(value: 1) => 'Demo data restored: 1 task.',
          Ok(:final value) => 'Demo data restored: $value tasks.',
          Err(:final exception) => exception.message,
        },
        messageSerial: state.messageSerial + 1,
      ),
    );
  }
}
