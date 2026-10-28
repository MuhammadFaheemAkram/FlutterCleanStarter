import 'package:flutter_clean_starter/core/design_system/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// A section's title, with an optional action at the end ("See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final action = this.action;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.xSmall,
        AppSpacing.xxSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              // Its own node: a heading flag on a merged node would make
              // everything around it a heading too.
              container: true,
              header: true,
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
