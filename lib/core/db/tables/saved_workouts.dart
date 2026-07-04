import 'package:drift/drift.dart';

class SavedWorkouts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get source => text()();
  TextColumn get creationMethod => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get estimatedDurationMinutes => integer().nullable()();
  IntColumn get restBetweenExercisesSeconds => integer().nullable()();
  TextColumn get goalTagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get equipmentJson => text().withDefault(const Constant('[]'))();
  TextColumn get aiGenerationSnapshotId => text().nullable()();
  IntColumn get aiOutputSchemaVersion => integer().nullable()();
  BoolColumn get imported => boolean().withDefault(const Constant(false))();
  DateTimeColumn get importedAt => dateTime().nullable()();
  TextColumn get importOrigin => text().nullable()();
  TextColumn get importSourceFileType => text().nullable()();
  TextColumn get importReviewStatus => text().nullable()();
  IntColumn get shareSchemaVersion => integer().nullable()();
  TextColumn get externalShareId => text().nullable()();
  TextColumn get exportPrivacyMode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
