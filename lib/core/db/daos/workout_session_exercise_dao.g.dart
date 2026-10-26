// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_exercise_dao.dart';

// ignore_for_file: type=lint
mixin _$WorkoutSessionExerciseDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkoutSessionExercisesTable get workoutSessionExercises =>
      attachedDatabase.workoutSessionExercises;
  WorkoutSessionExerciseDaoManager get managers =>
      WorkoutSessionExerciseDaoManager(this);
}

class WorkoutSessionExerciseDaoManager {
  final _$WorkoutSessionExerciseDaoMixin _db;
  WorkoutSessionExerciseDaoManager(this._db);
  $$WorkoutSessionExercisesTableTableManager get workoutSessionExercises =>
      $$WorkoutSessionExercisesTableTableManager(
        _db.attachedDatabase,
        _db.workoutSessionExercises,
      );
}
