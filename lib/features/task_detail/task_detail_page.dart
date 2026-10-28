import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/navigation/app_routes.dart';
import 'package:flutter_clean_starter/core/navigation/fallback_close_button.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/features/task_detail/cubit/task_detail_cubit.dart';
import 'package:flutter_clean_starter/features/task_detail/cubit/task_detail_state.dart';
import 'package:flutter_clean_starter/features/tasks/widgets/task_status_line.dart';
import 'package:material_ui/material_ui.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskDetailCubit>(param1: taskId)..load(),
      child: TaskDetailView(
        onLeave: () => Navigator.of(context).canPop()
            ? Navigator.of(context).pop()
            : const TasksRoute().go(context),
      ),
    );
  }
}

/// One task: tick it off, edit it, delete it (after asking).
///
/// [onLeave] leaves the screen once the task is deleted. Opened by a link it
/// has nothing to go back to, so its app bar offers Close (to Tasks).
class TaskDetailView extends StatelessWidget {
  const TaskDetailView({super.key, required this.onLeave});

  final VoidCallback onLeave;

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final cubit = context.read<TaskDetailCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete this task?',
      message: '“${task.title}” will be deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed) await cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TaskDetailCubit>().state;
    final task = state.task;
    final ready = state.status == TaskDetailStatus.ready && task != null;
    return MultiBlocListener(
      listeners: [
        BlocListener<TaskDetailCubit, TaskDetailState>(
          listenWhen: (previous, current) =>
              previous.status != TaskDetailStatus.deleted &&
              current.status == TaskDetailStatus.deleted,
          listener: (context, state) => onLeave(),
        ),
        BlocListener<TaskDetailCubit, TaskDetailState>(
          listenWhen: (previous, current) =>
              previous.messageSerial != current.messageSerial,
          listener: (context, state) => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message ?? ''))),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: fallbackCloseButton(
            context,
            () => const TasksRoute().go(context),
          ),
          title: const Text('Task'),
          actions: [
            if (ready) ...[
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    EditTaskRoute(taskId: task.id).push<void>(context),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, task),
              ),
            ],
          ],
        ),
        body: switch ((state.status, task)) {
          (TaskDetailStatus.loading, _) => const LoadingView(),
          (TaskDetailStatus.notFound, _) || (_, null) => EmptyStateView(
            icon: Icons.search_off,
            title: 'Task not found',
            message: 'It may have been deleted, or the link is out of date.',
            action: FilledButton.tonal(
              onPressed: () => const TasksRoute().go(context),
              child: const Text('Go to Tasks'),
            ),
          ),
          (_, final Task task) => _Details(
            task: task,
            today: state.today!,
            enabled: ready,
          ),
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.task,
    required this.today,
    required this.enabled,
  });

  final Task task;
  final CalendarDate today;

  /// Off while it's being deleted.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaskDetailCubit>();
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final due = task.due;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.large),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.medium,
            AppSpacing.medium,
            AppSpacing.xSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                container: true,
                child: Text(
                  task.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              TaskStatusLine(task: task, today: today),
            ],
          ),
        ),
        SwitchListTile.adaptive(
          title: const Text('Done'),
          value: task.isCompleted,
          onChanged: enabled ? (_) => cubit.toggle() : null,
        ),
        const SectionHeader('Notes'),
        _Paragraph(
          task.notes.trim().isEmpty ? 'No notes' : task.notes,
          style: task.notes.trim().isEmpty ? muted : theme.textTheme.bodyLarge,
        ),
        const SectionHeader('Due date'),
        _Paragraph(
          due == null ? 'No due date' : longDayLabel(due),
          style: due == null ? muted : theme.textTheme.bodyLarge,
        ),
        const SectionHeader('History'),
        _Paragraph(
          'Created ${dateTimeLabel(task.createdAt, use24HourFormat: use24)}',
          style: muted,
        ),
        if (task.updatedAt != task.createdAt)
          _Paragraph(
            'Updated ${dateTimeLabel(task.updatedAt, use24HourFormat: use24)}',
            style: muted,
          ),
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.medium,
      vertical: AppSpacing.xxSmall,
    ),
    child: Text(text, style: style),
  );
}
