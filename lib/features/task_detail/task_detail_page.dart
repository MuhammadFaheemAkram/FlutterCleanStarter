import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/navigation/app_routes.dart';
import 'package:flutter_clean_starter/core/navigation/fallback_close_button.dart';
import 'package:material_ui/material_ui.dart';

/// One task ([taskId]): a placeholder until Phase 4. Opened by a link it has
/// nothing to go back to, so it offers Close.
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: fallbackCloseButton(
          context,
          () => const TasksRoute().go(context),
        ),
        title: const Text('Task'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => EditTaskRoute(taskId: taskId).push<void>(context),
          ),
        ],
      ),
      body: const EmptyStateView(
        icon: Icons.task_alt,
        title: 'Task',
        message: 'Its notes, due date and Done arrive in Phase 4.',
      ),
    );
  }
}
