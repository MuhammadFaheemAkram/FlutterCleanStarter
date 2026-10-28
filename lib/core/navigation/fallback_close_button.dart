import 'package:material_ui/material_ui.dart';

/// The app bar's way out for a screen opened by a link: an `AppBar` adds
/// Back only when there is a screen underneath (conventions §11.47).
///
/// Returns `null` when Back exists, so `AppBar(leading: …)` keeps its
/// default; otherwise a Close button that runs [onClose] (a `go` to the
/// screen this one normally opens from).
Widget? fallbackCloseButton(BuildContext context, VoidCallback onClose) =>
    Navigator.of(context).canPop()
    ? null
    : IconButton(
        tooltip: 'Close',
        icon: const Icon(Icons.close),
        onPressed: onClose,
      );
