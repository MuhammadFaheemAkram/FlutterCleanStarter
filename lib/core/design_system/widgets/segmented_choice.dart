import 'package:flutter_clean_starter/core/design_system/large_text.dart';
import 'package:flutter_clean_starter/core/design_system/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// One of a few values: a `SegmentedButton`, or chips that wrap when large
/// text wouldn't fit the segments across (`prefersStackedLayout`).
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.values,
    required this.labelOf,
    required this.selected,
    required this.onSelected,
  });

  final List<T> values;
  final String Function(T value) labelOf;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    if (context.prefersStackedLayout) {
      return Wrap(
        spacing: AppSpacing.xSmall,
        runSpacing: AppSpacing.xSmall,
        children: [
          for (final value in values)
            ChoiceChip(
              label: Text(labelOf(value)),
              selected: value == selected,
              onSelected: (_) => onSelected(value),
            ),
        ],
      );
    }
    return SegmentedButton<T>(
      showSelectedIcon: false,
      segments: [
        for (final value in values)
          ButtonSegment(value: value, label: Text(labelOf(value))),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.single),
    );
  }
}
