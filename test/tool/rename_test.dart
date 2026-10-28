import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/rename.dart';

/// The project's current names, read from its files as the tool reads them,
/// so these tests pass before and after the project is renamed.
final _package = RegExp(
  r'^name:\s*(\S+)',
  multiLine: true,
).firstMatch(File('pubspec.yaml').readAsStringSync())![1]!;
final _appId = RegExp(r'applicationId\s*=\s*"([^"]+)"')
    .firstMatch(File(_gradle).readAsStringSync())![1]!;
final _name = RegExp(r'android:label="([^"]+)"')
    .firstMatch(File(_manifest).readAsStringSync())![1]!;

const _gradle = 'android/app/build.gradle.kts';
const _manifest = 'android/app/src/main/AndroidManifest.xml';
const _kotlin = 'android/app/src/main/kotlin';

String _activity(String appId) =>
    '$_kotlin/${appId.replaceAll('.', '/')}/MainActivity.kt';

/// The files the rename touches, copied from this project into a temporary
/// folder, so each test renames a real copy.
final _files = [
  'pubspec.yaml',
  _gradle,
  _manifest,
  _activity(_appId),
  'ios/Runner.xcodeproj/project.pbxproj',
  'ios/Runner/Info.plist',
  'lib/app/starter_app.dart',
  'lib/main.dart',
  'test/helpers/app_harness.dart',
];

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('rename_test_');
    for (final path in _files) {
      File('${root.path}/$path')
        ..createSync(recursive: true)
        ..writeAsStringSync(File(path).readAsStringSync());
    }
  });

  tearDown(() => root.deleteSync(recursive: true));

  String read(String path) => File('${root.path}/$path').readAsStringSync();

  // Names no project starts with.
  const options = RenameOptions(
    package: 'renamed_app',
    appId: 'org.example.renamedapp',
    name: 'Renamed App',
  );

  group('a rename', () {
    setUp(() => renameProject(root, options));

    test('renames the package and every import', () {
      expect(read('pubspec.yaml'), contains('name: renamed_app\n'));
      expect(read('lib/main.dart'), contains('package:renamed_app/'));
      expect(read('lib/main.dart'), isNot(contains('package:$_package/')));
      expect(
        read('test/helpers/app_harness.dart'),
        contains('package:renamed_app/'),
      );
    });

    test("changes Android's application ID, namespace and label", () {
      final gradle = read('android/app/build.gradle.kts');
      expect(gradle, contains('namespace = "org.example.renamedapp"'));
      expect(gradle, contains('applicationId = "org.example.renamedapp"'));
      expect(
        read('android/app/src/main/AndroidManifest.xml'),
        contains('android:label="Renamed App"'),
      );
    });

    test('moves MainActivity to its new package, and tidies the old one', () {
      final moved = File('${root.path}/${_activity(options.appId)}');
      expect(
        moved.readAsStringSync(),
        startsWith('package org.example.renamedapp'),
      );
      expect(File('${root.path}/${_activity(_appId)}').existsSync(), isFalse);
      expect(
        Directory('${root.path}/$_kotlin/${_appId.split('.').first}')
            .existsSync(),
        isFalse,
      );
      expect(
        Directory('${root.path}/android/app/src/main/kotlin').existsSync(),
        isTrue,
      );
    });

    test("changes iOS's bundle IDs (the app and its tests) and names", () {
      final project = read('ios/Runner.xcodeproj/project.pbxproj');
      expect(
        project,
        contains('PRODUCT_BUNDLE_IDENTIFIER = org.example.renamedapp;'),
      );
      expect(
        project,
        contains(
          'PRODUCT_BUNDLE_IDENTIFIER = org.example.renamedapp.RunnerTests;',
        ),
      );
      expect(project, isNot(contains('= $_appId')));
      final plist = read('ios/Runner/Info.plist');
      expect(
        RegExp('<string>Renamed App</string>').allMatches(plist),
        hasLength(2),
      );
      expect(plist, isNot(contains('<string>$_name</string>')));
    });

    test("changes MaterialApp's title", () {
      expect(
        read('lib/app/starter_app.dart'),
        contains("title: 'Renamed App',"),
      );
    });

    test('a second run changes nothing', () {
      expect(renameProject(root, options), isEmpty);
    });

    test('and renaming again, from the new names, works too', () {
      final changed = renameProject(
        root,
        const RenameOptions(
          package: 'other_app',
          appId: 'org.other.app',
          name: 'Other',
        ),
      );

      expect(changed, isNotEmpty);
      expect(read('lib/main.dart'), contains('package:other_app/'));
      expect(
        read('android/app/build.gradle.kts'),
        contains('applicationId = "org.other.app"'),
      );
    });
  });

  test('a dry run lists every file it would change, and writes nothing', () {
    final before = {for (final path in _files) path: read(path)};

    final listed = renameProject(
      root,
      const RenameOptions(
        package: 'renamed_app',
        appId: 'org.example.renamedapp',
        name: 'Renamed App',
        dryRun: true,
      ),
    );

    expect(listed, containsAll(_files));
    for (final path in _files) {
      expect(read(path), before[path], reason: path);
    }
  });

  test('only what differs changes: a new name alone leaves the rest', () {
    final changed = renameProject(
      root,
      RenameOptions(package: _package, appId: _appId, name: 'Tasks Pro'),
    );

    expect(
      changed,
      unorderedEquals([
        'android/app/src/main/AndroidManifest.xml',
        'ios/Runner/Info.plist',
        'lib/app/starter_app.dart',
      ]),
    );
  });

  test('outside the project root: a clear error, and nothing written', () {
    final empty = Directory.systemTemp.createTempSync('rename_empty_');
    addTearDown(() => empty.deleteSync(recursive: true));

    expect(
      () => renameProject(empty, options),
      throwsA(
        isA<RenameException>().having(
          (e) => e.message,
          'message',
          contains('Missing pubspec.yaml'),
        ),
      ),
    );
  });

  group('the options', () {
    RenameOptions parse(String line) => RenameOptions.parse(
      RegExp(r'"[^"]*"|\S+')
          .allMatches(line)
          .map((m) => m[0]!.replaceAll('"', ''))
          .toList(),
    );

    test('reads every option', () {
      final parsed = parse(
        '--package my_app --app-id com.example.myapp --name "My App" '
        '--dry-run',
      );

      expect(parsed.package, 'my_app');
      expect(parsed.appId, 'com.example.myapp');
      expect(parsed.name, 'My App');
      expect(parsed.dryRun, isTrue);
    });

    for (final (problem, line) in [
      ('a missing option', '--package my_app --app-id com.example.myapp'),
      ('a value missing', '--package my_app --app-id com.example.app --name'),
      ('an unknown option', '--package a --app-id a.b --name A --force'),
      ('a package with capitals', '--package MyApp --app-id a.b --name A'),
      (
        'a package starting with a digit',
        '--package 1app --app-id a.b --name A',
      ),
      ('an app ID with one part', '--package a --app-id myapp --name A'),
      (
        'an app ID part starting with a digit',
        '--package a --app-id com.1x --name A',
      ),
      ('a name with a quote', '--package a --app-id a.b --name "It\'s"'),
      ('an empty name', '--package a --app-id a.b --name "  "'),
    ]) {
      test('refuses $problem', () {
        expect(() => parse(line), throwsFormatException);
      });
    }
  });
}
