import 'package:flutter_clean_starter/domain/model/app_settings.dart';

/// The device's preferences.
abstract interface class SettingsRepository {
  /// The settings now, synchronously: they were loaded before the first
  /// frame, so the app opens in the right theme without waiting.
  AppSettings get current;

  /// The current settings on listen, then every change.
  Stream<AppSettings> watch();

  /// Applies [change] to the current settings, and saves what it changed.
  Future<void> update(AppSettings Function(AppSettings settings) change);
}
