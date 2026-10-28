import 'package:flutter_clean_starter/core/network/dto/task_dto.dart';
import 'package:flutter_clean_starter/core/network/task_api.dart';

/// A [TaskApi] whose next answers a test scripts: a list of DTOs, or an
/// exception to throw. With nothing scripted it asks [real] (the bundled
/// seed), or answers an empty list.
class ScriptedTaskApi implements TaskApi {
  ScriptedTaskApi([this.real]);

  final TaskApi? real;

  /// The next answers, in order: a `List<TaskDto>` or an `Exception`.
  final answers = <Object>[];

  /// How many times the server was asked.
  var calls = 0;

  /// Answers [tasks] next.
  void answer(List<TaskDto> tasks) => answers.add(tasks);

  /// Throws [exception] next.
  void fail(Exception exception) => answers.add(exception);

  @override
  Future<List<TaskDto>> fetchTasks() async {
    calls++;
    if (answers.isEmpty) return await real?.fetchTasks() ?? [];
    return switch (answers.removeAt(0)) {
      final List<TaskDto> tasks => tasks,
      final Exception exception => throw exception,
      final other => throw StateError('Not an answer: $other'),
    };
  }
}
