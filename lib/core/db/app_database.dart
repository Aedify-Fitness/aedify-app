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

part 'app_database.g.dart';

@DriftDatabase(
  tables: [SchemaMeta, Exercises, LocalFileRecords, SchemaMigrationsLog],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedSchemaMeta(m);
      await _logMigration(m, fromVersion: 0, toVersion: 2);
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(localFileRecords);
        await m.createTable(schemaMigrationsLog);
        await _seedSchemaMeta(m);
        await _logMigration(m, fromVersion: from, toVersion: to);
      }
    },
  );

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, DbConstants.databaseFileName));
    return NativeDatabase(file);
  });
}
