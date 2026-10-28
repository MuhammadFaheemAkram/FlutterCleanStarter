import 'package:material_ui/material_ui.dart';

/// Colors with a meaning that Material's [ColorScheme] has no slot for.
///
/// A [ThemeExtension] travels inside [ThemeData], so the light and dark
/// variants switch automatically (and animate via [lerp]) when the theme
/// changes. Widgets ask for an *intent* (`overdue`, `done`) instead of
/// hard-coding raw colors. A new app replaces these two with its own.
///
/// Both are text and icon colors on the page and on cards, so each must
/// reach WCAG AA (4.5:1) against those surfaces in both themes (checked by a
/// test). Color is never the only signal: "Overdue" also has an icon and the
/// word.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.overdue, required this.done});

  /// A task past its due date and not done yet.
  final Color overdue;

  /// A finished task.
  final Color done;

  static const light = AppColors(
    overdue: Color(0xFFB3261E),
    done: Color(0xFF146C2E),
  );

  static const dark = AppColors(
    overdue: Color(0xFFFF9C92),
    done: Color(0xFF86D993),
  );

  @override
  AppColors copyWith({Color? overdue, Color? done}) {
    return AppColors(overdue: overdue ?? this.overdue, done: done ?? this.done);
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      overdue: Color.lerp(overdue, other.overdue, t)!,
      done: Color.lerp(done, other.done, t)!,
    );
  }
}

/// Shorthand for `Theme.of(context).extension<AppColors>()!`.
extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
