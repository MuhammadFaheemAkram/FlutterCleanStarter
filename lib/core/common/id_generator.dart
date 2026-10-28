import 'dart:math';

import 'package:injectable/injectable.dart';

/// Makes ids for records created on the device: random (version 4) UUIDs,
/// such as `3f2b8c1e-9a4d-4c7e-b1f0-6d2e8a9c4b17`.
///
/// Random ids need no server and never collide in practice, so a task can
/// be created offline. Injected, so a test can predict the next id.
@lazySingleton
class IdGenerator {
  IdGenerator() : _random = Random.secure();

  /// For tests: a seeded [random] repeats its ids from run to run.
  IdGenerator.seeded(Random random) : _random = random;

  final Random _random;

  String call() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    // RFC 9562: the version (4) and the variant (10xx) bits.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = [
      for (final byte in bytes) byte.toRadixString(16).padLeft(2, '0'),
    ].join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
