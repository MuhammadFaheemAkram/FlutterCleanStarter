import 'package:flutter_clean_starter/core/design_system/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Full-screen loading state shared by every screen.
///
/// Because every screen renders the same widget, changing the loading
/// treatment later (e.g. to skeleton placeholders) happens in one place.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Loading…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Semantics(
        liveRegion: true,
        label: message,
        excludeSemantics: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.medium),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
