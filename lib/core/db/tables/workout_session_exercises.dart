import 'package:drift/drift.dart';

class WorkoutSessionExercises extends Table {
  TextColumn get id => text()();
  TextColumn get workoutSessionId => text()();
  TextColumn get sourceProgramExerciseId => text().nullable()();
  TextColumn get sourceSavedWorkoutExerciseId => text().nullable()();
  IntColumn get exerciseId => integer()();
  TextColumn get exerciseNameSnapshot => text()();
  IntColumn get sortOrder => integer()();
  IntColumn get restBetweenExercisesSeconds => integer().nullable()();
  TextColumn get supersetGroupId => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
