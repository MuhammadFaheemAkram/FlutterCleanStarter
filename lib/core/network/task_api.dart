import 'package:flutter_clean_starter/core/network/dto/task_dto.dart';

/// The server's side of the Tasks feature.
///
/// The app talks to this interface only. Today [FakeTaskApi] answers it
/// from bundled JSON; a real implementation would be a `dio` call, and the
/// rest of the app wouldn't change.
abstract interface class TaskApi {
  /// The server's tasks.
  ///
  /// Throws a `NetworkException` when the server can't be reached, and a
  /// `DataFormatException` when its answer can't be read.
  Future<List<TaskDto>> fetchTasks();
}
