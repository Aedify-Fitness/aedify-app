import 'package:drift/drift.dart';

/// Immutable copies of optional measurements attached to progress sessions.
@DataClassName('ProgressMeasurementSnapshotRow')
class ProgressMeasurementSnapshots extends Table {
  TextColumn get id => text()();
  DateTimeColumn get measuredAt => dateTime()();
  RealColumn get bodyweightKg => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get hipsCm => real().nullable()();
  RealColumn get leftArmCm => real().nullable()();
  RealColumn get rightArmCm => real().nullable()();
  RealColumn get leftThighCm => real().nullable()();
  RealColumn get rightThighCm => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Private local session metadata. Media bytes belong in the file store.
@DataClassName('ProgressMediaSessionRow')
class ProgressMediaSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get mediaType => text()();
  BoolColumn get isBaseline => boolean().withDefault(const Constant(false))();
  BoolColumn get isCompletePoseSet =>
      boolean().withDefault(const Constant(false))();
  RealColumn get bodyweightKg => real().nullable()();
  TextColumn get bodyMeasurementSnapshotId =>
      text().nullable().references(ProgressMeasurementSnapshots, #id)();
  TextColumn get notes => text().nullable()();
  TextColumn get reminderCadenceAtCapture => text().nullable()();
  IntColumn get storageSizeBytes => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Originals and derived files share one ownership graph, as in data plan §4.
@DataClassName('ProgressMediaItemRow')
class ProgressMediaItems extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(ProgressMediaSessions, #id)();
  TextColumn get type => text()();
  TextColumn get pose => text()();
  TextColumn get localRelativePath => text().unique()();
  TextColumn get thumbnailRelativePath => text().nullable()();
  TextColumn get source => text()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get fileSizeBytes => integer()();
  TextColumn get contentHash => text().nullable()();
  TextColumn get sourceMediaItemId =>
      text().nullable().references(ProgressMediaItems, #id)();
  DateTimeColumn get capturedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Durable reminder state; scheduling and cadence policy arrive in M6-005.
@DataClassName('ProgressMediaReminderSettingsRow')
class ProgressMediaReminderSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('default'))();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  TextColumn get cadence => text().nullable()();
  DateTimeColumn get lastSessionAt => dateTime().nullable()();
  DateTimeColumn get nextReminderAt => dateTime().nullable()();
  DateTimeColumn get lastPromptedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
