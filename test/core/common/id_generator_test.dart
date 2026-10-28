import 'dart:math';

import 'package:flutter_clean_starter/core/common/id_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('makes version 4 UUIDs', () {
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final ids = IdGenerator();

    for (var i = 0; i < 100; i++) {
      expect(ids(), matches(pattern));
    }
  });

  test('never repeats in practice', () {
    final ids = IdGenerator();

    expect({for (var i = 0; i < 1000; i++) ids()}, hasLength(1000));
  });

  test('a seeded generator repeats its ids from run to run', () {
    expect(IdGenerator.seeded(Random(1))(), IdGenerator.seeded(Random(1))());
  });
}
