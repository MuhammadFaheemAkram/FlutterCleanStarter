import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:flutter_clean_starter/features/tasks/widgets/task_status_line.dart';
import 'package:material_ui/material_ui.dart';

/// One task in the list: a checkbox, the title, a line of notes, when it's
/// due, and when it was created.
///
/// It only draws [task] and reports taps; what they do is the screen's
/// business ([onTap], [onToggle], [onDelete]).
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.today,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;

  /// The user's day: a task due before it, and not done, is overdue.
  final CalendarDate today;

  final VoidCallback onTap;
  final VoidCallback onToggle;

  /// Swiping is invisible to a screen reader, so the card also offers
  /// Delete as a custom action (in the "Actions" menu of TalkBack and
  /// VoiceOver).
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final notes = _firstLine(task.notes);
    return Semantics(
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Delete'): onDelete,
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.xxSmall,
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxSmall,
              AppSpacing.xSmall,
              AppSpacing.medium,
              AppSpacing.small,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => onToggle(),
                  semanticLabel: 'Done: ${task.title}',
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.small),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? scheme.onSurfaceVariant
                                : null,
                          ),
                        ),
                        if (notes.isNotEmpty)
                          Text(
                            notes,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xxSmall),
                        TaskStatusLine(task: task, today: today),
                        Text(
                          'Created ${shortDate(task.createdAt, today: today)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The notes' first line, for a one-line excerpt.
  static String _firstLine(String notes) =>
      notes.trim().split('\n').first.trim();
}
