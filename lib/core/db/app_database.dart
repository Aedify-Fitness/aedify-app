import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:aedify/shared/constants/db_constants.dart';
import 'tables/schema_meta.dart';
import 'tables/exercises.dart';
import 'tables/local_file_records.dart';
import 'tables/schema_migrations_log.dart';
import 'tables/library_meta.dart';
import 'tables/exercise_videos.dart';
import 'tables/exercise_audio_cache.dart';
import 'tables/user_profile.dart';
import 'tables/strength_anchors.dart';
import 'tables/body_measurements.dart';
import 'tables/app_settings.dart';
import 'tables/ai_model_capabilities.dart';
import 'tables/ai_provider_configs.dart';
import 'tables/programs.dart';
import 'tables/program_workout_templates.dart';
import 'tables/program_template_exercises.dart';
import 'tables/program_template_exercise_sets.dart';
import 'tables/program_weeks.dart';
import 'tables/program_workouts.dart';
import 'tables/program_exercises.dart';
import 'tables/program_exercise_sets.dart';
import 'tables/saved_workouts.dart';
import 'tables/saved_workout_exercises.dart';
import 'tables/saved_workout_exercise_sets.dart';
import 'tables/workout_sessions.dart';
import 'tables/workout_session_exercises.dart';
import 'tables/set_logs.dart';
import 'tables/program_revisions.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SchemaMeta,
    Exercises,
    LocalFileRecords,
    SchemaMigrationsLog,
    LibraryMeta,
    ExerciseVideos,
    ExerciseAudioCache,
    UserProfile,
    StrengthAnchors,
    BodyMeasurements,
    AppSettings,
    AiModelCapabilities,
    AiProviderConfigs,
    Programs,
    ProgramWorkoutTemplates,
    ProgramTemplateExercises,
    ProgramTemplateExerciseSets,
    ProgramWeeks,
    ProgramWorkouts,
    ProgramExercises,
    ProgramExerciseSets,
    SavedWorkouts,
    SavedWorkoutExercises,
    SavedWorkoutExerciseSets,
    WorkoutSessions,
    WorkoutSessionExercises,
    SetLogs,
    ProgramRevisions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? AppDatabase._openConnection());

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedSchemaMeta(m);
      await _logMigration(m, fromVersion: 0, toVersion: 12);
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(localFileRecords);
        await m.createTable(schemaMigrationsLog);
        await _seedSchemaMeta(m);
      }
      if (from < 3) {
        await m.createTable(libraryMeta);
        await m.createTable(exerciseVideos);
        await m.createTable(exerciseAudioCache);
        await _addExerciseColumns(m);
      }
      if (from < 4) {
        await m.createTable(userProfile);
      }
      if (from < 5) {
        await m.createTable(strengthAnchors);
        await m.createTable(bodyMeasurements);
        await m.createTable(appSettings);
      }
      if (from < 6) {
        await m.createTable(aiProviderConfigs);
      }
      if (from < 7) {
        await m.createTable(aiModelCapabilities);
      }
      if (from < 8) {
        await m.createTable(programs);
        await m.createTable(savedWorkouts);
        await m.createTable(programWorkoutTemplates);
        await m.createTable(programTemplateExercises);
        await m.createTable(programTemplateExerciseSets);
        await m.createTable(programWeeks);
        await m.createTable(programWorkouts);
        await m.createTable(programExercises);
        await m.createTable(programExerciseSets);
        await m.createTable(savedWorkoutExercises);
        await m.createTable(savedWorkoutExerciseSets);
        await m.createTable(workoutSessions);
        await m.createTable(workoutSessionExercises);
        await m.createTable(setLogs);
        await m.createTable(programRevisions);
      }
      if (from < 9) {
        await customStatement(
          'ALTER TABLE saved_workouts '
          'ADD COLUMN rest_between_exercises_seconds INTEGER',
        );
        await customStatement(
          'ALTER TABLE saved_workout_exercises '
          'ADD COLUMN rest_between_exercises_seconds INTEGER',
        );
        await customStatement(
          'ALTER TABLE program_workout_templates '
          'ADD COLUMN rest_between_exercises_seconds INTEGER',
        );
        await customStatement(
          'ALTER TABLE program_template_exercises '
          'ADD COLUMN rest_between_exercises_seconds INTEGER',
        );
      }
      if (from < 10) {
        await m.addColumn(setLogs, setLogs.restSeconds);
        await m.addColumn(
          workoutSessionExercises,
          workoutSessionExercises.restBetweenExercisesSeconds,
        );
      }
      if (from < 11) {
        await customStatement(
          'ALTER TABLE saved_workouts ADD COLUMN deleted_at TEXT NULL',
        );
      }
      if (from < 12) {
        await customStatement(
          'ALTER TABLE set_logs ADD COLUMN prescribed_reps_exact INTEGER',
        );
      }
      if (from < to) {
        await _logMigration(m, fromVersion: from, toVersion: to);
      }
    },
  );

  Future<void> _addExerciseColumns(Migrator m) async {
    await m.addColumn(exercises, exercises.isCustom);
    await m.addColumn(exercises, exercises.customExerciseUuid);
    await m.addColumn(exercises, exercises.sourceDatasetVersion);
    await m.addColumn(exercises, exercises.sourceSchemaVersion);
    await customStatement(
      'ALTER TABLE exercises ADD COLUMN name_normalized TEXT NOT NULL DEFAULT \'\'',
    );
    await customStatement(
      'ALTER TABLE exercises ADD COLUMN primary_muscles_json TEXT NOT NULL DEFAULT \'[]\'',
    );
    await customStatement(
      'ALTER TABLE exercises ADD COLUMN muscle_groups_json TEXT NOT NULL DEFAULT \'[]\'',
    );
    await customStatement(
      'ALTER TABLE exercises ADD COLUMN grips_json TEXT NOT NULL DEFAULT \'[]\'',
    );
    await customStatement(
      'ALTER TABLE exercises ADD COLUMN steps_json TEXT NOT NULL DEFAULT \'[]\'',
    );
    await m.addColumn(exercises, exercises.isSubstitutedOut);
    await m.addColumn(exercises, exercises.userNotes);
    await m.addColumn(exercises, exercises.importedFromShare);
    await m.addColumn(exercises, exercises.originalShareKey);
    await customStatement(
      'ALTER TABLE exercises ADD COLUMN created_at TEXT NOT NULL DEFAULT \'2024-01-01T00:00:00.000\'',
    );
    await customStatement(
      'ALTER TABLE exercises ADD COLUMN updated_at TEXT NOT NULL DEFAULT \'2024-01-01T00:00:00.000\'',
    );
    await m.addColumn(exercises, exercises.deletedAt);
  }

  Future<void> _seedSchemaMeta(Migrator m) async {
    final seedRows = <String, String>{
      DbConstants.driftSchemaVersionKey: DbConstants.initialDriftSchemaVersion,
      DbConstants.firebaseExerciseSupportedSchemaMinKey:
          DbConstants.defaultFirebaseExerciseSupportedSchemaMin,
      DbConstants.firebaseExerciseSupportedSchemaMaxKey:
          DbConstants.defaultFirebaseExerciseSupportedSchemaMax,
      DbConstants.lastSuccessfulExerciseLibraryVersionKey:
          DbConstants.defaultExerciseLibraryVersion,
      DbConstants.shareSchemaSupportedVersionKey:
          DbConstants.defaultShareSchemaSupportedVersion,
      DbConstants.aiOutputSchemaSupportedMinKey:
          DbConstants.defaultAiOutputSchemaSupportedMin,
      DbConstants.aiOutputSchemaSupportedMaxKey:
          DbConstants.defaultAiOutputSchemaSupportedMax,
      DbConstants.instructionSetVersionKey:
          DbConstants.defaultInstructionSetVersion,
      DbConstants.dataModelPlanVersionKey:
          DbConstants.defaultDataModelPlanVersion,
    };
    for (final entry in seedRows.entries) {
      await into(schemaMeta).insertOnConflictUpdate(
        SchemaMetaCompanion.insert(key: entry.key, value: entry.value),
      );
    }
  }

  Future<void> _logMigration(
    Migrator m, {
    required int fromVersion,
    required int toVersion,
  }) async {
    await into(schemaMigrationsLog).insert(
      SchemaMigrationsLogCompanion.insert(
        fromVersion: fromVersion,
        toVersion: toVersion,
        appliedAt: DateTime.now(),
      ),
    );
  }

  Future<T> inTransaction<T>(Future<T> Function() action) async {
    return await transaction(action);
  }

  Future<void> readiness() async {
    await customSelect('SELECT 1').get();
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, DbConstants.databaseFileName));
      return NativeDatabase(file);
    });
  }
}
