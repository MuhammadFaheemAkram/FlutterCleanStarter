import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/network/asset_json_loader.dart';
import 'package:flutter_clean_starter/core/network/dto/task_dto.dart';
import 'package:flutter_clean_starter/core/network/fake_task_api.dart';
import 'package:flutter_clean_starter/core/network/network_simulator.dart';
import 'package:flutter_clean_starter/data/mapper/task_mappers.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/task_fixtures.dart';

/// A bundle that serves [json] as the seed file.
class _SeedBundle extends CachingAssetBundle {
  _SeedBundle(this.json);

  final String json;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(utf8.encode(json));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final clock = Clock.fixed(demoNow);

  FakeTaskApi api({NetworkSimulator? network, AssetBundle? bundle}) =>
      FakeTaskApi(
        AssetJsonLoader(bundle ?? rootBundle),
        network ?? NetworkSimulator(latency: Duration.zero),
        clock,
      );

  group('the bundled seed', () {
    late List<TaskDto> seed;

    setUp(() async => seed = await api().fetchTasks());

    test('has the five sample tasks, and every one maps', () {
      expect(seed, hasLength(5));
      final tasks = seed.toTasks();
      expect(tasks.first.title, 'Welcome to Flutter Clean Starter');
      expect(tasks.where((task) => task.isCompleted), hasLength(1));
    });

    test('due dates are counted from today', () {
      final dues = {for (final dto in seed) dto.title: dto.due};

      expect(dues['Explore the architecture'], '2026-10-30');
      // One is overdue, so the demo shows what "Overdue" looks like.
      expect(dues['Swap the fake API for a real one'], '2026-10-27');
      expect(dues['Welcome to Flutter Clean Starter'], isNull);
    });

    test(
      'a later day moves the server\'s dates, not the stored ones',
      () async {
        final tomorrow = FakeTaskApi(
          AssetJsonLoader(rootBundle),
          NetworkSimulator(latency: Duration.zero),
          Clock.fixed(demoNow.add(const Duration(days: 1))),
        );

        final dto = (await tomorrow.fetchTasks()).firstWhere(
          (dto) => dto.title == 'Explore the architecture',
        );
        expect(CalendarDate.parse(dto.due!), demoToday.addDays(3));
      },
    );
  });

  test('answers after the simulated latency', () {
    fakeAsync((async) {
      // The default latency: 600 ms.
      final network = NetworkSimulator()..failRequests = true;
      Object? error;
      api(network: network).fetchTasks().catchError((Object e) {
        error = e;
        return <TaskDto>[];
      });

      async.elapse(const Duration(milliseconds: 599));
      expect(error, isNull);
      async.elapse(const Duration(milliseconds: 1));
      expect(error, isA<NetworkException>());
    });
  });

  test('the default latency is 600 ms', () {
    expect(NetworkSimulator().latency, const Duration(milliseconds: 600));
    expect(NetworkSimulator.shouldThrowError, isFalse);
  });

  test('a failing network is a NetworkException', () async {
    final network = NetworkSimulator(latency: Duration.zero)
      ..failRequests = true;

    expect(
      api(network: network).fetchTasks(),
      throwsA(isA<NetworkException>()),
    );
  });

  group('a damaged seed is a DataFormatException', () {
    const valid =
        '"id": "x", "title": "T", "notes": "", "isCompleted": false, '
        '"createdAt": "2026-07-20T09:00:00Z", "updatedAt": "2026-07-20T09:00:00Z"';

    for (final (name, json) in [
      ('not JSON', '{"tasks": ['),
      ('no task list', '{"items": []}'),
      ('a record that is not an object', '{"tasks": [1]}'),
      ('a missing field', '{"tasks": [{"id": "x"}]}'),
      ('a wrong type', '{"tasks": [{$valid, "dueInDays": "3"}]}'),
      (
        'a time that is not a time',
        '{"tasks": [{"id": "x", "title": "T", "notes": "", '
            '"isCompleted": false, "createdAt": "July", '
            '"updatedAt": "July"}]}',
      ),
    ]) {
      test(name, () {
        expect(
          api(bundle: _SeedBundle(json)).fetchTasks(),
          throwsA(isA<DataFormatException>()),
        );
      });
    }

    test('(a valid record decodes)', () async {
      final tasks = await api(
        bundle: _SeedBundle('{"tasks": [{$valid, "dueInDays": 0}]}'),
      ).fetchTasks();
      expect(tasks.single.due, '2026-10-28');
    });
  });
}
