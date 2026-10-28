import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/navigation/app_routes.dart';
import 'package:material_ui/material_ui.dart';

/// The task form as a full-screen dialog: a new task, or [taskId]'s when
/// editing. A placeholder until Phase 4.
///
/// Its Close button is always there (an app bar adds one only when it can
/// pop), and for a deep link with nothing underneath it goes where the form
/// opens from instead of popping the router's last page (conventions §11.47).
class TaskFormPage extends StatelessWidget {
  const TaskFormPage({super.key, this.taskId});

  /// `null` for a new task.
  final String? taskId;

  bool get _isEditing => taskId != null;

  void _close(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (taskId case final id?) {
      TaskDetailRoute(taskId: id).go(context);
    } else {
      const TasksRoute().go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit task' : 'New task';
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => _close(context)),
        title: Text(title),
      ),
      body: EmptyStateView(
        icon: Icons.edit_note,
        title: title,
        message: 'The title, notes, due date and Save arrive in Phase 4.',
      ),
    );
  }
}
