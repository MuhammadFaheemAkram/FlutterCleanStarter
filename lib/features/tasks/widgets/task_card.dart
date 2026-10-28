import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/domain/calculation/task_rules.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
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
                        _Status(task: task, today: today),
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

/// Done, overdue, or when it's due: an icon *and* words, never color alone.
class _Status extends StatelessWidget {
  const _Status({required this.task, required this.today});

  final Task task;
  final CalendarDate today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final due = task.due;
    final (icon, text, color) = switch (due) {
      _ when task.isCompleted => (Icons.task_alt, 'Done', colors.done),
      final due? when isOverdue(task, today) => (
        Icons.error_outline,
        'Overdue · due ${dayLabel(due, today: today)}',
        colors.overdue,
      ),
      final due? => (
        Icons.event_outlined,
        'Due ${dayLabel(due, today: today)}',
        theme.colorScheme.onSurfaceVariant,
      ),
      null => (null, null, null),
    };
    if (icon == null || text == null) return const SizedBox.shrink();
    final style = theme.textTheme.labelLarge!.copyWith(color: color);
    // The icon grows with the text and sits on its first line, so at large
    // text sizes it still reads as part of "Overdue", not beside the block.
    final scaler = MediaQuery.textScalerOf(context);
    final lineHeight = scaler.scale(style.fontSize!) * (style.height ?? 1.2);
    final iconSize = scaler
        .scale(AppIconSize.small)
        .clamp(AppIconSize.small, AppIconSize.large);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: ((lineHeight - iconSize) / 2).clamp(0, double.infinity),
            ),
            child: Icon(icon, size: iconSize, color: color),
          ),
          const SizedBox(width: AppSpacing.xxSmall),
          Flexible(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
