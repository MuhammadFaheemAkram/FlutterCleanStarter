import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Reads JSON files that ship inside the app bundle.
///
/// Wraps Flutter's [AssetBundle] so the fake API depends on one small
/// class, not on the global `rootBundle`. Tests can construct it with a fake
/// bundle.
///
/// Files are read with `cache: false`: the fake API reads its seed only now
/// and then, so a cached copy would only sit in memory. Worse, in widget
/// tests a cached future belongs to the previous test's fake-async zone and
/// never completes in the next test (conventions §11.19).
@lazySingleton
class AssetJsonLoader {
  const AssetJsonLoader(this._bundle);

  final AssetBundle _bundle;

  /// Loads [path] and decodes it as a single JSON object.
  ///
  /// Throws a [FormatException] if the file isn't valid JSON or isn't an
  /// object.
  Future<Map<String, dynamic>> loadObject(String path) async {
    final Object? decoded = jsonDecode(
      await _bundle.loadString(path, cache: false),
    );
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected a JSON object in $path');
    }
    return decoded;
  }
}
