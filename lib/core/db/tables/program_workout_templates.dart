import 'package:drift/drift.dart';

class ProgramWorkoutTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get programId => text()();
  TextColumn get templateKey => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get dayType => text().nullable()();
  IntColumn get estimatedDurationMinutes => integer().nullable()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
