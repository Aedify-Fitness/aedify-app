import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/local_file_record_dao.dart';
import 'package:aedify/shared/constants/db_constants.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(
        rows.map((row) => row.key).toSet(),
        containsAll({
          DbConstants.driftSchemaVersionKey,
          DbConstants.firebaseExerciseSupportedSchemaMinKey,
          DbConstants.firebaseExerciseSupportedSchemaMaxKey,
          DbConstants.lastSuccessfulExerciseLibraryVersionKey,
          DbConstants.shareSchemaSupportedVersionKey,
          DbConstants.aiOutputSchemaSupportedMinKey,
          DbConstants.aiOutputSchemaSupportedMaxKey,
          DbConstants.instructionSetVersionKey,
          DbConstants.dataModelPlanVersionKey,
        }),
      );
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

    test('inTransaction rolls back on failure', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final dao = LocalFileRecordDao(db);

      await expectLater(
        () => db.inTransaction(() async {
          await dao.insertFileRecord(
            LocalFileRecordsCompanion.insert(
              category: 'temp',
              ownerType: 'rollback-test',
              ownerId: const Value('owner-1'),
              localRelativePath: 'temp/test.txt',
              fileSizeBytes: 5,
              createdAt: DateTime.now(),
            ),
          );
          throw StateError('force rollback');
        }),
        throwsA(isA<StateError>()),
      );

      final rows = await dao.getByOwner('rollback-test', ownerId: 'owner-1');
      expect(rows, isEmpty);
      db.close();
    });
  });
}
