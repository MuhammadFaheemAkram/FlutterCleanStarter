import 'package:material_ui/material_ui.dart';

/// The app's large-text rule, in one place.
///
/// Text grows with the user's setting everywhere. Controls laid out side by
/// side (two buttons, three segments) switch to a stacked layout once the
/// text passes about 130 %: beyond that, a two-word label no longer fits in
/// half a phone's width, and would break mid-word.
extension LargeTextContext on BuildContext {
  bool get prefersStackedLayout =>
      MediaQuery.textScalerOf(this).scale(_bodySize) / _bodySize > 1.3;
}

const _bodySize = 14.0;
