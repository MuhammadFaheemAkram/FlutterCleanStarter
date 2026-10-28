import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/navigation/app_routes.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/features/tasks/cubit/tasks_cubit.dart';
import 'package:flutter_clean_starter/features/tasks/cubit/tasks_state.dart';
import 'package:flutter_clean_starter/features/tasks/widgets/task_card.dart';
import 'package:material_ui/material_ui.dart';

/// The Tasks tab. The *Page* creates the screen's Cubit (from DI) and
/// starts it; the *View* only renders state, so a test can pump the view
/// with a mocked Cubit in any state.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TasksCubit>()..load(),
      child: const TasksView(),
    );
  }
}

/// The task list: tap a task to open it, tick it off, swipe it away (with
/// Undo), pull to refresh.
class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TasksCubit>();
    final state = context.watch<TasksCubit>().state;
    final canAdd =
        state.status == TasksStatus.ready || state.status == TasksStatus.empty;
    // Its own messenger: the app's would show SnackBars in the tab shell's
    // outer Scaffold, which knows nothing of this screen's FAB, and "Task
    // deleted · Undo" would cover the Add button. Here they sit above it.
    return ScaffoldMessenger(
      child: MultiBlocListener(
        listeners: [
          BlocListener<TasksCubit, TasksState>(
            listenWhen: (previous, current) =>
                previous.messageSerial != current.messageSerial,
            listener: (context, state) => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message ?? ''))),
          ),
          BlocListener<TasksCubit, TasksState>(
            listenWhen: (previous, current) =>
                previous.undoSerial != current.undoSerial,
            listener: (context, state) {
              final deleted = state.undoable;
              if (deleted == null) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: const Text('Task deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => cubit.undo(deleted),
                    ),
                  ),
                );
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(title: const Text('Tasks')),
          body: switch (state.status) {
            TasksStatus.loading => const LoadingView(
              message: 'Loading your tasks…',
            ),
            TasksStatus.error => ErrorView(
              message: state.errorMessage ?? '',
              onRetry: cubit.retry,
            ),
            TasksStatus.empty => EmptyStateView(
              icon: Icons.checklist_outlined,
              title: 'No tasks yet',
              message:
                  'Add your first one. Settings → Reset demo data brings the '
                  'sample tasks back.',
              action: FilledButton.tonal(
                onPressed: () => _add(context),
                child: const Text('Add task'),
              ),
            ),
            TasksStatus.ready => _TaskList(state: state),
          },
          // A task can only be added once the store has answered: on a first
          // launch that failed offline, the seed comes first.
          floatingActionButton: canAdd
              ? FloatingActionButton(
                  tooltip: 'Add task',
                  onPressed: () => _add(context),
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }

  static void _add(BuildContext context) =>
      const NewTaskRoute().push<void>(context);
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.state});

  final TasksState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TasksCubit>();
    final today = state.today!;
    return RefreshIndicator.adaptive(
      onRefresh: cubit.refresh,
      child: ListView.builder(
        // Pullable even when the list is shorter than the screen.
        physics: const AlwaysScrollableScrollPhysics(),
        // Room for the FAB under the last card.
        padding: const EdgeInsets.only(
          top: AppSpacing.xSmall,
          bottom: AppSpacing.xLarge * 3,
        ),
        itemCount: state.tasks.length,
        itemBuilder: (context, index) {
          final task = state.tasks[index];
          return Dismissible(
            key: ValueKey(task.id),
            direction: DismissDirection.endToStart,
            background: const _DeleteBackground(),
            onDismissed: (_) => cubit.delete(task),
            child: TaskCard(
              task: task,
              today: today,
              onTap: () => _open(context, task),
              onToggle: () => cubit.toggle(task),
              onDelete: () => cubit.delete(task),
            ),
          );
        },
      ),
    );
  }

  static void _open(BuildContext context, Task task) =>
      TaskDetailRoute(taskId: task.id).push<void>(context);
}

/// Behind a card being swiped away: what the swipe does.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.errorContainer,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: scheme.onErrorContainer),
              const SizedBox(width: AppSpacing.xSmall),
              Text('Delete', style: TextStyle(color: scheme.onErrorContainer)),
            ],
          ),
        ),
      ),
    );
  }
}
