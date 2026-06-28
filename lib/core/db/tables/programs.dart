import 'package:drift/drift.dart';

class Programs extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get source => text()();
  TextColumn get creationMethod => text()();
  TextColumn get importOrigin => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  BoolColumn get active => boolean().withDefault(const Constant(false))();
  TextColumn get startDateLocal => text().nullable()();
  TextColumn get endDateLocal => text().nullable()();
  IntColumn get weeksTotal => integer().nullable()();
  IntColumn get daysPerWeek => integer().nullable()();
  IntColumn get sessionLengthMinutes => integer().nullable()();
  TextColumn get goalTagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get equipmentJson => text().withDefault(const Constant('[]'))();
  TextColumn get experienceLevelAtCreation => text().nullable()();
  TextColumn get preferredUnitsAtCreation => text().nullable()();
  TextColumn get periodisationModel => text().nullable()();
  TextColumn get trainingStyle => text().nullable()();
  TextColumn get referenceStrategy => text().nullable()();
  TextColumn get blockType => text().nullable()();
  TextColumn get progressionRulesJson => text().nullable()();
  TextColumn get deloadRulesJson => text().nullable()();
  TextColumn get warmupPolicyJson => text().nullable()();
  TextColumn get fatigueManagementJson => text().nullable()();
  TextColumn get aiGenerationSnapshotId => text().nullable()();
  IntColumn get aiOutputSchemaVersion => integer().nullable()();
  BoolColumn get imported => boolean().withDefault(const Constant(false))();
  DateTimeColumn get importedAt => dateTime().nullable()();
  TextColumn get importSourceFileType => text().nullable()();
  TextColumn get importReviewStatus => text().nullable()();
  BoolColumn get sourceFileRetained =>
      boolean().withDefault(const Constant(false))();
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
