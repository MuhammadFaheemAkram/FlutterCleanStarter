import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Asks before something that can't simply be undone. Returns `true` only
/// if the user chose [confirmLabel]; [cancelLabel] says what the other
/// choice keeps ("Keep it").
///
/// Adaptive: a Material dialog on Android, an iOS alert (with its own
/// buttons and the red destructive action) on iOS, through
/// `showAdaptiveDialog` and `AlertDialog.adaptive`. [destructive] marks the
/// confirming action as dangerous; Cancel is always the other one.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final confirmed = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: Text(message),
      actions: [
        _action(
          context,
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        _action(
          context,
          label: confirmLabel,
          destructive: destructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Widget _action(
  BuildContext context, {
  required String label,
  required VoidCallback onPressed,
  bool destructive = false,
}) {
  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS || TargetPlatform.macOS:
      return CupertinoDialogAction(
        isDestructiveAction: destructive,
        onPressed: onPressed,
        child: Text(label),
      );
    case _:
      return TextButton(
        style: destructive
            ? TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              )
            : null,
        onPressed: onPressed,
        child: Text(label),
      );
  }
}
