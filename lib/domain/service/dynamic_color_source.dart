/// Where Material You colors come from: the wallpaper, on Android 12+.
///
/// An interface in the domain, so the app (and its tests) depend on "a
/// source of the wallpaper's color", not on the plugin that reads it.
abstract interface class DynamicColorSource {
  /// The wallpaper's main color (ARGB), or `null` where the device offers
  /// none (iOS, older Android).
  Future<int?> wallpaperColor();
}
