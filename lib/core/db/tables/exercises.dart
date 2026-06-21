import 'package:drift/drift.dart';

class Exercises extends Table {
  IntColumn get id => integer()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get customExerciseUuid => text().nullable().unique()();

  TextColumn get source => text()();
  TextColumn get sourceDatasetVersion => text().nullable()();
  IntColumn get sourceSchemaVersion => integer().nullable()();

  TextColumn get name => text()();
  TextColumn get nameNormalized => text()();
  TextColumn get difficulty => text().nullable()();
  TextColumn get primaryMusclesJson => text()();
  TextColumn get muscleGroupsJson => text()();
  TextColumn get category => text().nullable()();
  TextColumn get modality => text()();
  TextColumn get equipment => text().nullable()();
  TextColumn get force => text().nullable()();
  TextColumn get mechanic => text().nullable()();
  TextColumn get gripsJson => text()();
  TextColumn get stepsJson => text()();

  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isSubstitutedOut =>
      boolean().withDefault(const Constant(false))();
  TextColumn get userNotes => text().nullable()();

  BoolColumn get importedFromShare =>
      boolean().withDefault(const Constant(false))();
  TextColumn get originalShareKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
