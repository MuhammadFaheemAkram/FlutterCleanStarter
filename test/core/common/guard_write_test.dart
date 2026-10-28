import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/common/guard_write.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/result_matchers.dart';

void main() {
  test('a write that succeeds is Ok, with its value', () async {
    expect(await guardWrite('Saving', () async => 42), isOk(42));
  });

  test("the app's own exceptions pass through", () async {
    expect(
      await guardWrite<void>('Saving', () => throw const NetworkException()),
      isErr<NetworkException>(),
    );
  });

  test('anything else becomes an UnknownException, never a throw', () async {
    expect(
      await guardWrite<void>('Saving', () => throw StateError('disk full')),
      isErr<UnknownException>(),
    );
  });
}
