import 'package:drift/drift.dart';

class LibraryMeta extends Table {
  TextColumn get id => text().withDefault(const Constant('exercise_library'))();
  TextColumn get source => text()();
  IntColumn get schemaVersion => integer()();
  TextColumn get libraryVersion => text().nullable()();
  DateTimeColumn get generatedAt => dateTime().nullable()();
  DateTimeColumn get downloadedAt => dateTime().nullable()();
  IntColumn get exerciseCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get manifestLastUpdatedAt => dateTime().nullable()();
  TextColumn get manifestFilePath => text().nullable()();
  IntColumn get minAppSchemaVersion => integer().nullable()();
  TextColumn get syncStatus => text()();
  TextColumn get lastSyncErrorCode => text().nullable()();
  TextColumn get lastSyncErrorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
