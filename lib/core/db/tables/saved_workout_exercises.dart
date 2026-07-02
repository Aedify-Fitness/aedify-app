import 'package:drift/drift.dart';

class SavedWorkoutExercises extends Table {
  TextColumn get id => text()();
  TextColumn get savedWorkoutId => text()();
  IntColumn get exerciseId => integer()();
  TextColumn get exerciseRef => text().nullable()();
  TextColumn get exerciseRole => text().nullable()();
  TextColumn get supersetGroupId => text().nullable()();
  IntColumn get supersetOrder => integer().nullable()();
  IntColumn get sortOrder => integer()();
  IntColumn get restBetweenExercisesSeconds => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get cuesJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
