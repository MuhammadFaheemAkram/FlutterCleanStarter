import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(getIt.reset);

  // A smoke test of the real composition root. A dependency injectable can't
  // resolve only fails when its type is first resolved, at runtime; resolving
  // the top of each graph here catches it in CI. Every new Cubit, repository
  // and service belongs here.
  test('the real container builds', () async {
    configureDependencies();

    await expectLater(getIt.allReady(), completes);
  });
}
