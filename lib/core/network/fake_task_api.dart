import 'package:clock/clock.dart';
import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/network/asset_json_loader.dart';
import 'package:flutter_clean_starter/core/network/dto/task_dto.dart';
import 'package:flutter_clean_starter/core/network/network_simulator.dart';
import 'package:flutter_clean_starter/core/network/task_api.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:injectable/injectable.dart';
import 'package:json_annotation/json_annotation.dart';

/// An in-memory server: no network, no key, the same answers offline.
///
/// It serves `assets/json/seed_tasks.json` after the [NetworkSimulator]'s
/// delay. The seed's due dates are *relative* (`"dueInDays": 3`), so a fresh
/// demo is never all overdue; the server turns them into days counted from
/// today, as a real server would send dates. Once stored, a task's due date
/// never moves: a refresh never overwrites a stored task.
@LazySingleton(as: TaskApi)
class FakeTaskApi implements TaskApi {
  const FakeTaskApi(this._assets, this._network, this._clock);

  static const seedPath = 'assets/json/seed_tasks.json';

  final AssetJsonLoader _assets;
  final NetworkSimulator _network;
  final Clock _clock;

  @override
  Future<List<TaskDto>> fetchTasks() async {
    await _network();
    try {
      final seed = await _assets.loadObject(seedPath);
      final today = CalendarDate.fromDateTime(_clock.now());
      final records = seed['tasks'];
      if (records is! List<Object?>) throw const DataFormatException();
      return [
        for (final record in records) TaskDto.fromJson(_render(record, today)),
      ];
    } on FormatException {
      throw const DataFormatException();
    } on CheckedFromJsonException {
      throw const DataFormatException();
    }
  }

  /// The seed's [record] as the API sends it: `dueInDays` becomes `due`.
  static Map<String, dynamic> _render(Object? record, CalendarDate today) {
    if (record is! Map<String, dynamic>) throw const DataFormatException();
    final dueInDays = record['dueInDays'];
    if (dueInDays is! int?) throw const DataFormatException();
    return {
      ...Map.of(record)..remove('dueInDays'),
      'due': dueInDays == null ? null : today.addDays(dueInDays).toIso(),
    };
  }
}
