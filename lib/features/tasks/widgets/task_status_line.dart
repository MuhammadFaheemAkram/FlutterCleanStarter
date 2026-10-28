import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/domain/calculation/task_rules.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_clean_starter/domain/model/task.dart';
import 'package:material_ui/material_ui.dart';

/// Done, overdue, or when it's due: an icon *and* words, never color alone.
/// Nothing for an open task with no due date. Shared by the list's cards and
/// the task's own screen.
class TaskStatusLine extends StatelessWidget {
  const TaskStatusLine({super.key, required this.task, required this.today});

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
