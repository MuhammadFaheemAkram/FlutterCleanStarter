import 'dart:developer';

import 'package:flutter_clean_starter/core/common/app_exception.dart';
import 'package:flutter_clean_starter/core/common/result.dart';

/// Runs a write and maps every failure to an [AppException] the UI can show:
/// the app's own exceptions pass through, anything else (a database error)
/// is logged and becomes an [UnknownException].
///
/// Repositories wrap each write in it, so no exception reaches a Cubit.
Future<Result<T>> guardWrite<T>(String what, Future<T> Function() write) async {
  try {
    return Ok(await write());
  } on AppException catch (exception) {
    return Err(exception);
  } on Object catch (error, stackTrace) {
    log('$what failed', error: error, stackTrace: stackTrace);
    return const Err(UnknownException());
  }
}
