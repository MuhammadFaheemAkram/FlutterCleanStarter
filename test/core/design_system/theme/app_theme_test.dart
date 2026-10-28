import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

double contrast(Color a, Color b) {
  final (hi, lo) = (a.computeLuminance(), b.computeLuminance());
  return hi > lo ? (hi + 0.05) / (lo + 0.05) : (lo + 0.05) / (hi + 0.05);
}

void main() {
  group('AppTheme', () {
    test('builds Material 3 light and dark themes from the seed', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();

      expect(light.useMaterial3, isTrue);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
    });

    test('the seed stays close to the primary color (fidelity)', () {
      final primary = AppTheme.light().colorScheme.primary;
      // A muted variant would drift far from the seed's hue.
      final hue = HSLColor.fromColor(primary).hue;
      final seedHue = HSLColor.fromColor(AppTheme.seedColor).hue;
      expect((hue - seedHue).abs(), lessThan(10));
    });

    test('registers the matching AppColors extension for each brightness', () {
      expect(AppTheme.light().extension<AppColors>(), same(AppColors.light));
      expect(AppTheme.dark().extension<AppColors>(), same(AppColors.dark));
    });

    test('any seed can drive it (dynamic color will)', () {
      const wallpaper = Color(0xFF6750A4);

      final theme = AppTheme.fromSeed(wallpaper, Brightness.dark);

      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(
        theme.colorScheme.primary,
        isNot(AppTheme.dark().colorScheme.primary),
      );
      expect(theme.extension<AppColors>(), same(AppColors.dark));
    });

    test('any scheme can drive it', () {
      final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4));

      final theme = AppTheme.fromScheme(scheme);

      expect(theme.colorScheme, scheme);
      expect(theme.extension<AppColors>(), same(AppColors.light));
    });
  });

  group('AppColors', () {
    test('lerp interpolates every token', () {
      final mid = AppColors.light.lerp(AppColors.dark, 0.5);

      Color? halfway(Color Function(AppColors) token) =>
          Color.lerp(token(AppColors.light), token(AppColors.dark), 0.5);
      expect(mid.overdue, halfway((c) => c.overdue));
      expect(mid.done, halfway((c) => c.done));
    });

    test('lerp towards a missing extension keeps the current colors', () {
      expect(AppColors.light.lerp(null, 0.5), same(AppColors.light));
    });

    test('copyWith replaces only the given tokens', () {
      const purple = Color(0xFF7B1FA2);
      final copy = AppColors.light.copyWith(done: purple);

      expect(copy.done, purple);
      expect(copy.overdue, AppColors.light.overdue);
    });

    testWidgets('context.appColors reads the current theme', (tester) async {
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Builder(
            builder: (context) {
              colors = context.appColors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors, same(AppColors.dark));
    });
  });

  // WCAG contrast checks, so a color tweak can't silently make a label
  // unreadable. The meaning colors are text and icon colors on the page, on
  // cards and on filled fields, so each must reach AA (4.5:1) on all of
  // them.
  group('Contrast in both themes', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final name = theme.colorScheme.brightness.name;
      final colors = theme.extension<AppColors>()!;
      final scheme = theme.colorScheme;
      final surfaces = {
        'the page': scheme.surface,
        'a card': scheme.surfaceContainerLow,
        'a filled field': scheme.surfaceContainerHighest,
      };

      for (final (token, color) in [
        ('overdue', colors.overdue),
        ('done', colors.done),
      ]) {
        for (final MapEntry(key: surface, value: background)
            in surfaces.entries) {
          test('$name: $token text on $surface meets AA (4.5:1)', () {
            expect(contrast(color, background), greaterThanOrEqualTo(4.5));
          });
        }
      }
    }
  });
}
