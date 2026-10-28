// Renames the app built from this template, in one go:
//
//   fvm dart run tool/rename.dart \
//     --package my_app --app-id com.example.myapp --name "My App" [--dry-run]
//
// - the Dart package (`pubspec.yaml`, and every `package:` import in lib/,
//   test/ and tool/);
// - the Android application ID and namespace (`build.gradle.kts`), and the
//   Kotlin package of `MainActivity` (its folder moves);
// - the iOS bundle ID (`project.pbxproj`, the app and its tests);
// - the display name (Android's label, iOS's `CFBundleDisplayName` and
//   `CFBundleName`, `MaterialApp`'s title).
//
// The current names are read from the project itself, so it can run again
// (a second run with the same names changes nothing) and from any earlier
// rename. `--dry-run` lists what would change and writes nothing.
//
// Pure Dart, no packages: it runs before `pub get` would even matter.

import 'dart:io';

Future<void> main(List<String> arguments) async {
  final RenameOptions options;
  try {
    options = RenameOptions.parse(arguments);
  } on FormatException catch (error) {
    stderr
      ..writeln(error.message)
      ..writeln()
      ..writeln(RenameOptions.usage);
    exitCode = 64;
    return;
  }
  try {
    final changes = renameProject(Directory.current, options);
    final verb = options.dryRun ? 'Would change' : 'Changed';
    if (changes.isEmpty) {
      stdout.writeln('Nothing to change: the project already has these names.');
    } else {
      stdout.writeln('$verb ${changes.length} file(s):');
      for (final change in changes) {
        stdout.writeln('  $change');
      }
      if (!options.dryRun) {
        // The new package name changes the imports' alphabetical order and
        // some line lengths: `dart fix` sorts them (that fix only: others
        // would rewrite test stubs), `dart format` rewraps.
        stdout.writeln(
          '\nNext: fvm dart fix --apply --code=directives_ordering && '
          'fvm dart format . && '
          'fvm dart run build_runner build --delete-conflicting-outputs && '
          'fvm flutter test',
        );
      }
    }
  } on RenameException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

/// What to rename the project to.
final class RenameOptions {
  const RenameOptions({
    required this.package,
    required this.appId,
    required this.name,
    this.dryRun = false,
  });

  /// Reads `--package`, `--app-id`, `--name` and `--dry-run`; throws a
  /// [FormatException] that says what's wrong.
  factory RenameOptions.parse(List<String> arguments) {
    String? package;
    String? appId;
    String? name;
    var dryRun = false;
    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      String value() {
        if (i + 1 >= arguments.length) {
          throw FormatException('$argument needs a value.');
        }
        return arguments[++i];
      }

      switch (argument) {
        case '--package':
          package = value();
        case '--app-id':
          appId = value();
        case '--name':
          name = value();
        case '--dry-run':
          dryRun = true;
        default:
          throw FormatException('Unknown option: $argument');
      }
    }
    if (package == null || appId == null || name == null) {
      throw const FormatException(
        '--package, --app-id and --name are all required.',
      );
    }
    if (!_packagePattern.hasMatch(package)) {
      throw FormatException(
        'Not a Dart package name: "$package" (lower case, digits and '
        'underscores, starting with a letter).',
      );
    }
    if (!_appIdPattern.hasMatch(appId)) {
      throw FormatException(
        'Not an application ID: "$appId" (at least two dot-separated '
        'parts, each starting with a letter: com.example.myapp).',
      );
    }
    if (name.trim().isEmpty || name.contains(RegExp(r'''["'<>&\\]'''))) {
      throw FormatException(
        'Not a display name: "$name" (not empty, and no quotes, <, > or &).',
      );
    }
    return RenameOptions(
      package: package,
      appId: appId,
      name: name.trim(),
      dryRun: dryRun,
    );
  }

  final String package;
  final String appId;
  final String name;
  final bool dryRun;

  static final _packagePattern = RegExp(r'^[a-z][a-z0-9_]*$');
  static final _appIdPattern = RegExp(
    r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$',
  );

  static const usage =
      'Usage: fvm dart run tool/rename.dart --package <name> '
      '--app-id <id> --name "<Display Name>" [--dry-run]\n'
      '  --package  the Dart package (my_app)\n'
      '  --app-id   the Android application ID and iOS bundle ID '
      '(com.example.myapp)\n'
      '  --name     the name under the app icon ("My App")\n'
      '  --dry-run  list what would change, and write nothing';
}

/// A project that doesn't look like this template (a file missing, a name
/// not found).
final class RenameException implements Exception {
  const RenameException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Renames the project at [root]; the files changed (or that would be,
/// with [RenameOptions.dryRun]), relative to [root].
List<String> renameProject(Directory root, RenameOptions options) {
  final project = _Project(root, dryRun: options.dryRun);

  // The current names, read from the project.
  final oldPackage = project.match(
    'pubspec.yaml',
    RegExp(r'^name:\s*(\S+)', multiLine: true),
  );
  final oldAppId = project.match(
    _gradle,
    RegExp(r'applicationId\s*=\s*"([^"]+)"'),
  );
  final oldName = project.match(_manifest, RegExp(r'android:label="([^"]+)"'));

  if (oldPackage != options.package) {
    project.edit(
      'pubspec.yaml',
      (text) => text.replaceFirst(
        RegExp('^name:\\s*${RegExp.escape(oldPackage)}\\s*\$', multiLine: true),
        'name: ${options.package}',
      ),
    );
    for (final path in project.dartFiles(['lib', 'test', 'tool'])) {
      project.edit(
        path,
        (text) => text.replaceAll(
          'package:$oldPackage/',
          'package:${options.package}/',
        ),
      );
    }
  }

  if (oldAppId != options.appId) {
    project
      ..edit(_gradle, (text) => _replaceQuoted(text, oldAppId, options.appId))
      ..edit(
        _pbxproj,
        (text) => text.replaceAllMapped(
          RegExp(
            'PRODUCT_BUNDLE_IDENTIFIER = ${RegExp.escape(oldAppId)}'
            r'(\.RunnerTests)?;',
          ),
          (m) => 'PRODUCT_BUNDLE_IDENTIFIER = ${options.appId}${m[1] ?? ''};',
        ),
      )
      ..moveMainActivity(oldAppId, options.appId);
  }

  if (oldName != options.name) {
    project
      ..edit(
        _manifest,
        (text) => text.replaceFirst(
          'android:label="$oldName"',
          'android:label="${options.name}"',
        ),
      )
      ..edit(
        _infoPlist,
        (text) => text.replaceAllMapped(
          RegExp(
            r'(<key>CFBundle(?:Display)?Name</key>\s*<string>)'
            '${RegExp.escape(oldName)}'
            '(</string>)',
          ),
          (m) => '${m[1]}${options.name}${m[2]}',
        ),
      )
      ..edit(
        _app,
        (text) => text.replaceFirst(
          "title: '$oldName',",
          "title: '${options.name.replaceAll(r'$', r'\$')}',",
        ),
      );
  }

  return project.changed;
}

const _gradle = 'android/app/build.gradle.kts';
const _manifest = 'android/app/src/main/AndroidManifest.xml';
const _pbxproj = 'ios/Runner.xcodeproj/project.pbxproj';
const _infoPlist = 'ios/Runner/Info.plist';
const _app = 'lib/app/starter_app.dart';

/// [text] with every `"old"` (in double quotes) as `"new"`: the namespace
/// and the application ID, not a longer ID that starts with the old one.
String _replaceQuoted(String text, String old, String replacement) =>
    text.replaceAll('"$old"', '"$replacement"');

/// The project's files, read and (unless [dryRun]) written.
final class _Project {
  _Project(this.root, {required this.dryRun});

  final Directory root;
  final bool dryRun;

  /// The files changed so far, relative to [root], each once.
  final changed = <String>[];

  File _file(String path) => File('${root.path}/$path');

  String _read(String path) {
    final file = _file(path);
    if (!file.existsSync()) {
      throw RenameException('Missing $path: run this from the project root.');
    }
    return file.readAsStringSync();
  }

  /// The first group of [pattern] in [path].
  String match(String path, RegExp pattern) {
    final found = pattern.firstMatch(_read(path))?[1];
    if (found == null) {
      throw RenameException('Could not find ${pattern.pattern} in $path.');
    }
    return found;
  }

  /// Applies [change] to [path], noting it if anything changed.
  void edit(String path, String Function(String text) change) {
    final before = _read(path);
    final after = change(before);
    if (after == before) return;
    if (!dryRun) _file(path).writeAsStringSync(after);
    if (!changed.contains(path)) changed.add(path);
  }

  /// Every `.dart` file under [folders], relative to [root].
  Iterable<String> dartFiles(List<String> folders) sync* {
    for (final folder in folders) {
      final directory = Directory('${root.path}/$folder');
      if (!directory.existsSync()) continue;
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          yield entity.path.substring(root.path.length + 1);
        }
      }
    }
  }

  /// Moves `MainActivity.kt` from the [oldId]'s package folder to the
  /// [newId]'s, rewrites its `package` line, and removes the folders left
  /// empty.
  void moveMainActivity(String oldId, String newId) {
    const kotlin = 'android/app/src/main/kotlin';
    final from = '$kotlin/${oldId.replaceAll('.', '/')}/MainActivity.kt';
    final to = '$kotlin/${newId.replaceAll('.', '/')}/MainActivity.kt';
    final text = _read(from).replaceFirst(
      RegExp(r'^package\s+\S+', multiLine: true),
      'package $newId',
    );
    changed
      ..add(from)
      ..add(to);
    if (dryRun) return;
    _file(to)
      ..createSync(recursive: true)
      ..writeAsStringSync(text);
    _file(from).deleteSync();
    var folder = _file(from).parent;
    while (folder.path != _file(kotlin).path &&
        folder.existsSync() &&
        folder.listSync().isEmpty) {
      folder.deleteSync();
      folder = folder.parent;
    }
  }
}
