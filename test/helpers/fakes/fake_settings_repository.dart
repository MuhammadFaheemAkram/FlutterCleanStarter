import 'dart:async';

import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/repository/settings_repository.dart';

/// Settings in memory, with the real repository's watch behaviour, and a
/// count of the writes.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this._current = const AppSettings()]);

  AppSettings _current;
  final _changes = StreamController<AppSettings>.broadcast(sync: true);

  /// How many times [update] ran.
  var writes = 0;

  @override
  AppSettings get current => _current;

  @override
  Stream<AppSettings> watch() => Stream.multi((watcher) {
    final subscription = _changes.stream.listen(watcher.add);
    watcher
      ..onCancel = subscription.cancel
      ..add(_current);
  });

  @override
  Future<void> update(AppSettings Function(AppSettings settings) change) async {
    writes++;
    _current = change(_current);
    _changes.add(_current);
  }
}
