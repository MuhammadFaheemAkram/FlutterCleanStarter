/// What the device offers for theming, read once before the first frame (so
/// the first frame is already in the right colors).
final class DeviceColors {
  const DeviceColors({this.wallpaperColor});

  /// The wallpaper's main color (ARGB), on Android 12+.
  final int? wallpaperColor;

  /// Whether Settings offers "Dynamic color".
  bool get supportsDynamicColor => wallpaperColor != null;
}

/// The app's name and version, as About shows them.
final class AppInfo {
  const AppInfo({
    required this.name,
    required this.version,
    required this.buildNumber,
  });

  final String name;
  final String version;
  final String buildNumber;

  /// "1.0.0 (1)".
  String get versionLabel =>
      buildNumber.isEmpty ? version : '$version ($buildNumber)';
}
