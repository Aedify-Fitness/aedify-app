import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:aedify/shared/constants/db_constants.dart';
import 'tables/schema_meta.dart';
import 'tables/exercises.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [SchemaMeta, Exercises])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(schemaMeta).insert(
        SchemaMetaCompanion.insert(key: DbConstants.driftSchemaVersionKey, value: DbConstants.initialDriftSchemaVersion),
      );
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, DbConstants.databaseFileName));
    return NativeDatabase(file);
  });
}
