// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_workout_exercise_set_dao.dart';

// ignore_for_file: type=lint
mixin _$SavedWorkoutExerciseSetDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavedWorkoutExerciseSetsTable get savedWorkoutExerciseSets =>
      attachedDatabase.savedWorkoutExerciseSets;
  SavedWorkoutExerciseSetDaoManager get managers =>
      SavedWorkoutExerciseSetDaoManager(this);
}

class SavedWorkoutExerciseSetDaoManager {
  final _$SavedWorkoutExerciseSetDaoMixin _db;
  SavedWorkoutExerciseSetDaoManager(this._db);
  $$SavedWorkoutExerciseSetsTableTableManager get savedWorkoutExerciseSets =>
      $$SavedWorkoutExerciseSetsTableTableManager(
        _db.attachedDatabase,
        _db.savedWorkoutExerciseSets,
      );
}
