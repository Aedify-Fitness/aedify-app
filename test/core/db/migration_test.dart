import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/shared/constants/db_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  group('Migration', () {
    test('onCreate seeds schema_meta and logs migration', () async {
      final db = AppDatabase(NativeDatabase.memory());

      final metaRows = await db.select(db.schemaMeta).get();
      expect(
        metaRows.map((row) => row.key).toSet(),
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

      final logRows = await db.select(db.schemaMigrationsLog).get();
      expect(logRows, isNotEmpty);
      expect(logRows.first.fromVersion, equals(0));
      expect(logRows.first.toVersion, equals(12));

      db.close();
    });

    test('all tables are accessible after creation', () async {
      final db = AppDatabase(NativeDatabase.memory());

      final fileRecords = await db.select(db.localFileRecords).get();
      expect(fileRecords, isEmpty);

      final logRows = await db.select(db.schemaMigrationsLog).get();
      expect(logRows, isNotEmpty);

      final libraryMeta = await db.select(db.libraryMeta).get();
      expect(libraryMeta, isEmpty);

      final exerciseVideos = await db.select(db.exerciseVideos).get();
      expect(exerciseVideos, isEmpty);

      final exerciseAudioCache = await db.select(db.exerciseAudioCache).get();
      expect(exerciseAudioCache, isEmpty);

      db.close();
    });

    test('current to current open is a no-op migration', () async {
      final tempDir = Directory.systemTemp.createTempSync('migration_noop_');
      final dbFile = File(p.join(tempDir.path, 'test.sqlite'));

      final firstDb = AppDatabase(NativeDatabase(dbFile));
      await firstDb.readiness();
      await firstDb.close();

      final secondDb = AppDatabase(NativeDatabase(dbFile));
      await secondDb.readiness();
      final logs = await secondDb.select(secondDb.schemaMigrationsLog).get();
      expect(logs, isNotEmpty);
      await secondDb.close();
      await tempDir.delete(recursive: true);
    });

    test('schema v4 tables accessible via in-memory DB', () async {
      final db = AppDatabase(NativeDatabase.memory());

      await expectLater(db.select(db.libraryMeta).get(), completion(isEmpty));
      await expectLater(
        db.select(db.exerciseVideos).get(),
        completion(isEmpty),
      );
      await expectLater(
        db.select(db.exerciseAudioCache).get(),
        completion(isEmpty),
      );
      await expectLater(db.select(db.userProfile).get(), completion(isEmpty));

      db.close();
    });
  });
}
