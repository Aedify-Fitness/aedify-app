import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/shared/constants/db_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  group('Migration', () {
    test(
      'v7 upgrade creates current training tables and preserves M3 data',
      () async {
        final directory = Directory.systemTemp.createTempSync('m3_upgrade_');
        addTearDown(() => directory.delete(recursive: true));
        final file = File(p.join(directory.path, 'database.sqlite'));
        final original = AppDatabase(NativeDatabase(file));
        final now = DateTime(2026, 10, 24);
        await original
            .into(original.userProfile)
            .insert(
              UserProfileCompanion.insert(
                name: const Value('Migration fixture'),
                experienceLevel: 'beginner',
                preferredUnits: const Value('imperial'),
                onboardingCompleted: const Value(true),
                favoriteExerciseIdsJson: const Value('[42]'),
                createdAt: now,
                updatedAt: now,
              ),
            );
        await original
            .into(original.exercises)
            .insert(
              ExercisesCompanion.insert(
                id: const Value(42),
                source: 'musclewiki',
                name: 'Fixture push-up',
                nameNormalized: 'fixture push-up',
                primaryMusclesJson: '["chest"]',
                muscleGroupsJson: '["chest"]',
                modality: 'strength',
                equipment: const Value('bodyweight'),
                gripsJson: '[]',
                stepsJson: '["Lower and press."]',
                isFavorite: const Value(true),
                createdAt: now,
                updatedAt: now,
              ),
            );
        final originalProfile =
            (await original.select(original.userProfile).get()).single;
        final originalExercise =
            (await original.select(original.exercises).get()).single;
        for (final table in _MigrationFixtures.m4Tables) {
          await original.customStatement('DROP TABLE $table');
        }
        await original.customStatement(
          'ALTER TABLE exercises DROP COLUMN logging_type',
        );
        await original.customStatement('PRAGMA user_version = 7');
        await original.close();

        final upgraded = AppDatabase(NativeDatabase(file));
        addTearDown(upgraded.close);
        final profile =
            (await upgraded.select(upgraded.userProfile).get()).single;
        final exercise =
            (await upgraded.select(upgraded.exercises).get()).single;
        expect(profile, originalProfile);
        expect(
          exercise.toJson()..remove('loggingType'),
          originalExercise.toJson()..remove('loggingType'),
        );
        expect(exercise.loggingType, 'repsOnly');
        for (final table in _MigrationFixtures.m4Tables) {
          final row = await upgraded
              .customSelect('SELECT COUNT(*) AS count FROM $table')
              .getSingle();
          expect(
            row.read<int>('count'),
            0,
            reason: '$table must exist after upgrade',
          );
        }
        final columns = await upgraded
            .customSelect('PRAGMA table_info(set_logs)')
            .get();
        for (final target in [
          'prescribed_rir',
          'prescribed_duration_seconds',
          'prescribed_distance_meters',
        ]) {
          final column = columns
              .where((row) => row.read<String>('name') == target)
              .single;
          expect(column.read<int>('notnull'), 0);
        }
        final sessionColumns = await upgraded
            .customSelect('PRAGMA table_info(workout_session_exercises)')
            .get();
        expect(
          sessionColumns
              .where((row) => row.read<String>('name') == 'logging_type')
              .single
              .read<int>('notnull'),
          0,
        );
        expect(
          (await upgraded.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          18,
        );
        final logs = await upgraded.select(upgraded.schemaMigrationsLog).get();
        expect(
          logs.any((log) => log.fromVersion == 7 && log.toVersion == 18),
          isTrue,
        );
      },
    );

    test(
      'v17 upgrade retains logged actuals and adds nullable target snapshots',
      () async {
        final directory = Directory.systemTemp.createTempSync(
          'set_targets_migration_',
        );
        addTearDown(() => directory.delete(recursive: true));
        final file = File(p.join(directory.path, 'database.sqlite'));
        final original = AppDatabase(NativeDatabase(file));
        final now = DateTime(2026, 10, 24);
        await original
            .into(original.setLogs)
            .insert(
              SetLogsCompanion.insert(
                id: 'historical-set',
                workoutSessionExerciseId: 'exercise',
                exerciseId: 7,
                performedAt: now,
                setIndex: 0,
                createdAt: now,
                updatedAt: now,
                actualReps: const Value(8),
                actualWeightKg: const Value(40),
                actualDurationSeconds: const Value(60),
                actualDistanceMeters: const Value(100),
                actualRpe: const Value(8.5),
                actualRir: const Value(2),
              ),
            );
        await _MigrationFixtures.removeV18Columns(original);
        await original.customStatement('PRAGMA user_version = 17');
        await original.close();
        final upgraded = AppDatabase(NativeDatabase(file));
        addTearDown(upgraded.close);
        final log = (await upgraded.select(upgraded.setLogs).get()).single;
        expect(log.actualReps, 8);
        expect(log.actualWeightKg, 40);
        expect(log.actualDurationSeconds, 60);
        expect(log.actualDistanceMeters, 100);
        expect(log.actualRpe, 8.5);
        expect(log.actualRir, 2);
        expect(log.prescribedRir, isNull);
        expect(log.prescribedDurationSeconds, isNull);
        expect(log.prescribedDistanceMeters, isNull);
        expect(
          await upgraded.select(upgraded.workoutSessionExercises).get(),
          isEmpty,
        );
        expect(upgraded.schemaVersion, 18);
      },
    );

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
      await _MigrationFixtures.removeV18Columns(original);
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
        await _MigrationFixtures.removeV18Columns(original);
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
      await _MigrationFixtures.removeV18Columns(original);
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
        logs.any((entry) => entry.fromVersion == 14 && entry.toVersion == 18),
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
      expect(logRows.first.toVersion, equals(18));

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

abstract final class _MigrationFixtures {
  static const m4Tables = [
    'set_logs',
    'workout_session_exercises',
    'workout_sessions',
    'saved_workout_exercise_sets',
    'saved_workout_exercises',
    'saved_workouts',
    'program_exercise_sets',
    'program_exercises',
    'program_workouts',
    'program_weeks',
    'program_training_blocks',
    'program_template_exercise_sets',
    'program_template_exercises',
    'program_workout_templates',
    'program_revisions',
    'programs',
  ];

  static Future<void> removeV18Columns(AppDatabase db) async {
    for (final column in [
      'prescribed_rir',
      'prescribed_duration_seconds',
      'prescribed_distance_meters',
    ]) {
      await db.customStatement('ALTER TABLE set_logs DROP COLUMN $column');
    }
    await db.customStatement(
      'ALTER TABLE workout_session_exercises DROP COLUMN logging_type',
    );
  }
}
