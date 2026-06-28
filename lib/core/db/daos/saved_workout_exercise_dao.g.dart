// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_workout_exercise_dao.dart';

// ignore_for_file: type=lint
mixin _$SavedWorkoutExerciseDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavedWorkoutExercisesTable get savedWorkoutExercises =>
      attachedDatabase.savedWorkoutExercises;
  SavedWorkoutExerciseDaoManager get managers =>
      SavedWorkoutExerciseDaoManager(this);
}

class SavedWorkoutExerciseDaoManager {
  final _$SavedWorkoutExerciseDaoMixin _db;
  SavedWorkoutExerciseDaoManager(this._db);
  $$SavedWorkoutExercisesTableTableManager get savedWorkoutExercises =>
      $$SavedWorkoutExercisesTableTableManager(
        _db.attachedDatabase,
        _db.savedWorkoutExercises,
      );
}
