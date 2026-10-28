import 'package:flutter_clean_starter/core/design_system/theme/app_icon_size.dart';
import 'package:flutter_clean_starter/core/design_system/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Full-screen error state with an optional retry action.
///
/// Screens turn their failures into a plain [message] and hand recovery back
/// through [onRetry], so this widget stays free of business logic.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;

  /// Shows a "Try again" button when non-null.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: AppIconSize.large,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.medium),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
