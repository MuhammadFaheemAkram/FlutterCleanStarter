import 'package:material_ui/material_ui.dart';

/// The app bar's way out for a screen opened by a link: an `AppBar` adds
/// Back only when there is a screen underneath (conventions §11.47).
///
/// Returns `null` when Back exists, so `AppBar(leading: …)` keeps its
/// default; otherwise a Close button that runs [onClose] (a `go` to the
/// screen this one normally opens from).
///
/// It asks the same question the `AppBar` asks: does *this screen's* route
/// have one below it. `Navigator.canPop()` would answer for the whole
/// stack, so a screen rebuilt while another covers it would lose Close,
/// and be left with no way out after Back (conventions §11.96).
Widget? fallbackCloseButton(BuildContext context, VoidCallback onClose) =>
    ModalRoute.of(context)?.impliesAppBarDismissal ?? false
    ? null
    : IconButton(
        tooltip: 'Close',
        icon: const Icon(Icons.close),
        onPressed: onClose,
      );
