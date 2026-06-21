import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';

void main() {
  group('AppDatabase', () {
    test('schema version is 2', () {
      final db = AppDatabase(NativeDatabase.memory());
      expect(db.schemaVersion, equals(2));
      db.close();
    });

    test('schema_meta contains drift_schema_version on creation', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final rows = await db.select(db.schemaMeta).get();
      expect(rows, isNotEmpty);
      final versionRow = rows.where(
        (r) => r.key == 'drift_schema_version',
      );
      expect(versionRow, isNotEmpty);
      db.close();
    });

    test('localFileRecords table is accessible', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final rows = await db.select(db.localFileRecords).get();
      expect(rows, isEmpty);
      db.close();
    });

    test('schemaMigrationsLog table is accessible', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final rows = await db.select(db.schemaMigrationsLog).get();
      expect(rows, isNotEmpty);
      db.close();
    });

    test('readiness returns without error', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await expectLater(db.readiness(), completes);
      db.close();
    });

    test('inTransaction runs successfully', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final result = await db.inTransaction(() async => 42);
      expect(result, equals(42));
      db.close();
    });
  });
}
