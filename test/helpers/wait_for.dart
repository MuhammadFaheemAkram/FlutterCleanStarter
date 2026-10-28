import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Waits until [bloc]'s state satisfies [test] (it may already), failing
/// after [timeout] instead of hanging.
Future<S> waitFor<S>(
  BlocBase<S> bloc,
  bool Function(S state) test, {
  Duration timeout = const Duration(seconds: 2),
}) {
  if (test(bloc.state)) return Future.value(bloc.state);
  return bloc.stream.firstWhere(test).timeout(timeout);
}
