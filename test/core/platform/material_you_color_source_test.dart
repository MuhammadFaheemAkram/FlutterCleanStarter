import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_starter/core/platform/material_you_color_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DynamicColorPlugin.channel, null);
  });

  test('iOS: no wallpaper colors, and the plugin is never asked', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    var asked = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DynamicColorPlugin.channel, (_) async {
          asked = true;
          return null;
        });

    expect(await const MaterialYouColorSource().wallpaperColor(), isNull);
    expect(asked, isFalse);
  });

  test('Android with no palette (before 12): none', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          DynamicColorPlugin.channel,
          (_) async => null,
        );

    expect(await const MaterialYouColorSource().wallpaperColor(), isNull);
  });

  test('Android, the plugin failing: none, never a throw', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          DynamicColorPlugin.channel,
          (_) async => throw PlatformException(code: 'broken'),
        );

    expect(await const MaterialYouColorSource().wallpaperColor(), isNull);
  });
}
