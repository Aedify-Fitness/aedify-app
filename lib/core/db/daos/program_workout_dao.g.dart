// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_workout_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgramWorkoutDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProgramWorkoutsTable get programWorkouts => attachedDatabase.programWorkouts;
  ProgramWorkoutDaoManager get managers => ProgramWorkoutDaoManager(this);
}

class ProgramWorkoutDaoManager {
  final _$ProgramWorkoutDaoMixin _db;
  ProgramWorkoutDaoManager(this._db);
  $$ProgramWorkoutsTableTableManager get programWorkouts =>
      $$ProgramWorkoutsTableTableManager(
        _db.attachedDatabase,
        _db.programWorkouts,
      );
}
