// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_workout_dao.dart';

// ignore_for_file: type=lint
mixin _$SavedWorkoutDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavedWorkoutsTable get savedWorkouts => attachedDatabase.savedWorkouts;
  SavedWorkoutDaoManager get managers => SavedWorkoutDaoManager(this);
}

class SavedWorkoutDaoManager {
  final _$SavedWorkoutDaoMixin _db;
  SavedWorkoutDaoManager(this._db);
  $$SavedWorkoutsTableTableManager get savedWorkouts =>
      $$SavedWorkoutsTableTableManager(_db.attachedDatabase, _db.savedWorkouts);
}
