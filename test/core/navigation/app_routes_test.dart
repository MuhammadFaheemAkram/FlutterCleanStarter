import 'package:flutter_clean_starter/core/navigation/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Settings has its own path', () {
    expect(const SettingsRoute().location, '/settings');
  });
}
