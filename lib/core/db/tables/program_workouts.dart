import 'package:drift/drift.dart';

class ProgramWorkouts extends Table {
  TextColumn get id => text()();
  TextColumn get programId => text()();
  TextColumn get programWeekId => text().nullable()();
  TextColumn get workoutTemplateId => text().nullable()();
  TextColumn get occurrenceRef => text()();
  TextColumn get name => text()();
  TextColumn get scheduledDateLocal => text().nullable()();
  IntColumn get scheduledDayIndex => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
  TextColumn get revisionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
