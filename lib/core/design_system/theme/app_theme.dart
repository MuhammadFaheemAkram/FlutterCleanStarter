import 'package:flutter_clean_starter/core/design_system/theme/app_colors.dart';
import 'package:flutter_clean_starter/core/design_system/theme/app_radius.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the app's Material 3 light and dark themes.
///
/// Screens style themselves through `Theme.of(context)`, never with
/// hard-coded colors, so restyling an app built from this template means
/// changing [seedColor] and the component themes here, and nothing else.
/// [fromSeed] takes any seed: the wallpaper-based "dynamic color" of
/// Android 12+ passes the wallpaper's color without touching a screen.
abstract final class AppTheme {
  /// A teal: one color the whole palette is derived from.
  static const Color seedColor = Color(0xFF00696E);

  static ThemeData light() => fromSeed(seedColor, Brightness.light);

  static ThemeData dark() => fromSeed(seedColor, Brightness.dark);

  static ThemeData fromSeed(Color seed, Brightness brightness) => fromScheme(
    ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      // `fidelity` keeps the primary color close to the seed; the default
      // variant (`tonalSpot`) would noticeably mute it.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );

  static ThemeData fromScheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      extensions: [
        if (colorScheme.brightness == Brightness.light)
          AppColors.light
        else
          AppColors.dark,
      ],
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
