import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Tasks feature's one preference: whether the first launch's seed has
/// been written.
///
/// Kept apart from the user's settings, so removing the sample feature
/// removes this file (and its keys from `AppModule`'s allow list).
@lazySingleton
class TasksPreferences {
  const TasksPreferences(this._preferences);

  static const seededKey = 'tasks.seeded';

  static const allowList = {seededKey};

  final SharedPreferencesWithCache _preferences;

  /// Set once the seed's transaction has committed, never before: a seed
  /// that failed halfway runs again on the next launch.
  bool get seeded => _preferences.getBool(seededKey) ?? false;

  Future<void> markSeeded() => _preferences.setBool(seededKey, true);
}
