import 'package:flutter_clean_starter/core/design_system/theme/app_icon_size.dart';
import 'package:flutter_clean_starter/core/design_system/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Full-screen empty state: an icon, a title, an optional message and an
/// optional [action] (e.g. a button).
///
/// Used for genuinely empty data: "No tasks yet", or nothing matching a
/// filter.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = this.message;
    final action = this.action;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppIconSize.large,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.medium),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
