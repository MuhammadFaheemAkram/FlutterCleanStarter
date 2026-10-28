import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/navigation/app_routes.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/features/task_form/cubit/task_form_cubit.dart';
import 'package:flutter_clean_starter/features/task_form/cubit/task_form_state.dart';
import 'package:material_ui/material_ui.dart';

/// The task form as a full-screen dialog: a new task, or [taskId]'s when
/// editing.
class TaskFormPage extends StatelessWidget {
  const TaskFormPage({super.key, this.taskId});

  /// `null` for a new task.
  final String? taskId;

  /// Leaves the form. The edit form is a child route of its task, so even
  /// a link opens it with the task underneath, and it pops. `/tasks/new`
  /// opened by a link has nothing underneath: it goes to Tasks instead of
  /// popping the router's last page (conventions §11.47).
  void _close(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      const TasksRoute().go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskFormCubit>(param1: taskId)..load(),
      child: TaskFormView(onClose: () => _close(context)),
    );
  }
}

/// The form. [onClose] leaves it, after a save or a confirmed discard.
/// Leaving with unsaved changes any other way (Close, the system back
/// gesture) first asks "Discard changes?", through [PopScope].
class TaskFormView extends StatelessWidget {
  const TaskFormView({super.key, required this.onClose});

  final VoidCallback onClose;

  /// Reads the Cubit's state *now*, not the last build's: a tap can come
  /// between a keystroke and the rebuild it causes.
  Future<void> _closeAsked(BuildContext context) async {
    final state = context.read<TaskFormCubit>().state;
    if (!state.hasChanges || await _confirmDiscard(context, state)) onClose();
  }

  Future<bool> _confirmDiscard(BuildContext context, TaskFormState state) =>
      showConfirmDialog(
        context,
        title: 'Discard changes?',
        message: state.isEditing
            ? "Your changes to this task won't be saved."
            : "This task won't be saved.",
        confirmLabel: 'Discard',
        cancelLabel: 'Keep editing',
        destructive: true,
      );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaskFormCubit>();
    return BlocConsumer<TaskFormCubit, TaskFormState>(
      // The one-time effect: saved, so close (once).
      listenWhen: (previous, current) =>
          previous.status != TaskFormStatus.saved &&
          current.status == TaskFormStatus.saved,
      listener: (context, state) => onClose(),
      builder: (context, state) {
        final saving = state.status == TaskFormStatus.saving;
        final title = cubit.taskId == null ? 'New task' : 'Edit task';
        return PopScope(
          // Nothing to lose, or already saved: leave freely.
          canPop: !state.hasChanges || state.status == TaskFormStatus.saved,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirmDiscard(context, state)) onClose();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: CloseButton(onPressed: () => _closeAsked(context)),
              title: Text(title),
              actions: [
                if (state.status != TaskFormStatus.notFound)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xSmall),
                    child: FilledButton(
                      onPressed: state.status == TaskFormStatus.editing
                          ? cubit.save
                          : null,
                      child: saving
                          ? Semantics(
                              label: 'Saving',
                              child: const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
              ],
            ),
            body: switch (state.status) {
              TaskFormStatus.loading => const LoadingView(),
              TaskFormStatus.notFound => EmptyStateView(
                icon: Icons.search_off,
                title: 'Task not found',
                message:
                    'It may have been deleted, or the link is out of date.',
                action: FilledButton.tonal(
                  onPressed: () => const TasksRoute().go(context),
                  child: const Text('Go to Tasks'),
                ),
              ),
              _ => _TaskFields(state: state),
            },
          ),
        );
      },
    );
  }
}

/// The fields. Stateful only for the text controllers, which start from the
/// stored task; every change goes to the Cubit.
class _TaskFields extends StatefulWidget {
  const _TaskFields({required this.state});

  final TaskFormState state;

  @override
  State<_TaskFields> createState() => _TaskFieldsState();
}

class _TaskFieldsState extends State<_TaskFields> {
  late final _title = TextEditingController(text: widget.state.title);
  late final _notes = TextEditingController(text: widget.state.notes);

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaskFormCubit>();
    final state = widget.state;
    final enabled = state.status == TaskFormStatus.editing;
    final saveError = state.saveError;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        TextField(
          controller: _title,
          enabled: enabled,
          // A new task starts typing at once; an edit opens on the text.
          autofocus: !state.isEditing,
          onChanged: cubit.titleChanged,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Title',
            errorText: state.titleError,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        TextField(
          controller: _notes,
          enabled: enabled,
          onChanged: cubit.notesChanged,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: 'Notes (optional)',
            alignLabelWithHint: true,
            errorText: state.notesError,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        DatePickerField(
          label: 'Due date',
          value: state.due,
          today: state.today!,
          enabled: enabled,
          onChanged: cubit.dueChanged,
        ),
        if (state.isEditing) ...[
          const SizedBox(height: AppSpacing.xSmall),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Done'),
            value: state.isCompleted,
            onChanged: enabled
                ? (value) => cubit.completedChanged(completed: value)
                : null,
          ),
        ],
        if (saveError != null) ...[
          const SizedBox(height: AppSpacing.medium),
          Semantics(
            liveRegion: true,
            child: Text(
              saveError,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }
}
