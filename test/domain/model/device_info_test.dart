import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dynamic color is offered only with a wallpaper color', () {
    expect(const DeviceColors().supportsDynamicColor, isFalse);
    expect(
      const DeviceColors(wallpaperColor: 0xFF000000).supportsDynamicColor,
      isTrue,
    );
  });

  test('the version label adds the build number when there is one', () {
    expect(
      const AppInfo(name: 'A', version: '1.2.0', buildNumber: '9').versionLabel,
      '1.2.0 (9)',
    );
    expect(
      const AppInfo(name: 'A', version: '1.2.0', buildNumber: '').versionLabel,
      '1.2.0',
    );
  });
}
