import 'dart:convert';
import 'dart:io';

import 'package:flutter_clean_starter/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database.dart';

// The database as a whole: its pragmas and its exported schema. Each
// feature tests its own tables' rules (the Tasks sample's:
// `tasks_schema_test.dart`).
void main() {
  late AppDatabase db;

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  test('foreign keys are on, for the first table that has one', () async {
    final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(result.data.values.single, 1);
  });

  // A schema change must bump `schemaVersion` and export the new version
  // (`fvm dart run drift_dev make-migrations`), so the next version has
  // something to migrate from. This catches a forgotten export.
  test('the current schema version is exported, with every table', () {
    final file = File(
      'drift_schemas/app_database/drift_schema_v${db.schemaVersion}.json',
    );
    expect(file.existsSync(), isTrue, reason: 'run make-migrations');

    final schema = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final exported = [
      for (final entity in schema['entities'] as List<dynamic>)
        ((entity as Map<String, dynamic>)['data']
            as Map<String, dynamic>)['name'],
    ];
    expect(
      exported,
      unorderedEquals(db.allTables.map((t) => t.actualTableName)),
    );
  });
}
