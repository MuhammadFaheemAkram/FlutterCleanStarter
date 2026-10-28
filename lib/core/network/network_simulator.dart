import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:injectable/injectable.dart';

/// Plays the network for the fake API: a delay, and an optional failure.
///
/// Turn [shouldThrowError] on to see every screen's offline handling while
/// developing; tests flip [failRequests] instead. A real API (`dio`) has
/// neither: its failures are real.
@lazySingleton
class NetworkSimulator {
  NetworkSimulator({
    @ignoreParam this.latency = const Duration(milliseconds: 600),
  });

  /// The developer switch: every request fails while it's `true`.
  static const bool shouldThrowError = false;

  /// How long a request takes. Tests use zero.
  final Duration latency;

  /// Fails every request while `true` (for tests, and a developer menu).
  bool failRequests = false;

  /// Waits [latency], then throws a [NetworkException] if requests fail.
  Future<void> call() async {
    await Future<void>.delayed(latency);
    if (failRequests || shouldThrowError) throw const NetworkException();
  }
}
