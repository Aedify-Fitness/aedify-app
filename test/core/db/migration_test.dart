import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/shared/constants/db_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  group('Migration', () {
    test('v16 upgrade retains templates with empty workout goals', () async {
      final directory = Directory.systemTemp.createTempSync(
        'workout_goals_migration_',
      );
      final file = File(p.join(directory.path, 'database.sqlite'));
      final original = AppDatabase(NativeDatabase(file));
      final now = DateTime(2026);
      await original
          .into(original.programWorkoutTemplates)
          .insert(
            ProgramWorkoutTemplatesCompanion.insert(
              id: 'template',
              programId: 'programme',
              templateKey: 'template',
              name: 'Push',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await original.customStatement(
        'ALTER TABLE program_workout_templates DROP COLUMN goal_tags_json',
      );
      await original.customStatement('PRAGMA user_version = 16');
      await original.close();
      final upgraded = AppDatabase(NativeDatabase(file));
      final template =
          (await upgraded.select(upgraded.programWorkoutTemplates).get())
              .single;
      expect(template.name, 'Push');
      expect(template.goalTagsJson, '[]');
      await upgraded.close();
      await directory.delete(recursive: true);
    });

    test(
      'v15 upgrade preserves blocks and starts with optional days unset',
      () async {
        final directory = Directory.systemTemp.createTempSync(
          'block_days_migration_',
        );
        final file = File(p.join(directory.path, 'database.sqlite'));
        final original = AppDatabase(NativeDatabase(file));
        await original
            .into(original.programTrainingBlocks)
            .insert(
              ProgramTrainingBlocksCompanion.insert(
                id: 'block',
                programId: 'programme',
                sortOrder: 0,
                name: 'Strength',
                weekCount: 3,
                focus: 'strength_biased',
              ),
            );
        await original.customStatement(
          'ALTER TABLE program_training_blocks DROP COLUMN training_days_json',
        );
        await original.customStatement(
          'ALTER TABLE program_workout_templates DROP COLUMN goal_tags_json',
        );
        await original.customStatement('PRAGMA user_version = 15');
        await original.close();
        final upgraded = AppDatabase(NativeDatabase(file));
        final block =
            (await upgraded.select(upgraded.programTrainingBlocks).get())
                .single;
        expect(block.name, 'Strength');
        expect(block.weekCount, 3);
        expect(block.trainingDaysJson, '[]');
        await upgraded.close();
        await directory.delete(recursive: true);
      },
    );

    test('v14 upgrade adds blocks and preserves existing programmes', () async {
      final directory = Directory.systemTemp.createTempSync(
        'blocks_migration_',
      );
      final file = File(p.join(directory.path, 'database.sqlite'));
      final original = AppDatabase(NativeDatabase(file));
      final now = DateTime.now();
      await original
          .into(original.programs)
          .insert(
            ProgramsCompanion.insert(
              id: 'existing',
              name: 'Existing programme',
              source: 'manual',
              creationMethod: 'manual',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await original.customStatement('DROP TABLE program_training_blocks');
      await original.customStatement(
        'ALTER TABLE program_workout_templates DROP COLUMN goal_tags_json',
      );
      await original.customStatement('PRAGMA user_version = 14');
      await original.close();
      final upgraded = AppDatabase(NativeDatabase(file));
      expect(
        (await upgraded.select(upgraded.programs).get()).single.name,
        'Existing programme',
      );
      expect(
        await upgraded.select(upgraded.programTrainingBlocks).get(),
        isEmpty,
      );
      final logs = await upgraded.select(upgraded.schemaMigrationsLog).get();
      expect(
        logs.any((entry) => entry.fromVersion == 14 && entry.toVersion == 17),
        isTrue,
      );
      await upgraded.close();
      await directory.delete(recursive: true);
    });

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
      expect(logRows.first.toVersion, equals(17));

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
