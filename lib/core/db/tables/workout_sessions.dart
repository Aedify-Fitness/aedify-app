import 'package:drift/drift.dart';

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get source => text()();
  TextColumn get programId => text().nullable()();
  TextColumn get programWorkoutId => text().nullable()();
  TextColumn get savedWorkoutId => text().nullable()();
  TextColumn get name => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get status => text()();
  RealColumn get bodyweightKgAtSession => real().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get energyLevel => integer().nullable()();
  IntColumn get perceivedDifficulty => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
