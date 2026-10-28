import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed [MaterialApp] and [Scaffold], which is
  /// enough context for any single design-system widget or screen view.
  Future<void> pumpThemed(Widget widget, {ThemeData? theme}) {
    return pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light(),
        home: Scaffold(body: widget),
      ),
    );
  }

  /// Renders at a phone-sized 390×844 logical surface (instead of the default
  /// 800×600 test window), so layouts behave as they do on a device. The
  /// original size is restored when the test ends.
  void usePhoneSurface() {
    view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(view.reset);
  }
}
