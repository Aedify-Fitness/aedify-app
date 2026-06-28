// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_exercise_set_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgramExerciseSetDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProgramExerciseSetsTable get programExerciseSets =>
      attachedDatabase.programExerciseSets;
  ProgramExerciseSetDaoManager get managers =>
      ProgramExerciseSetDaoManager(this);
}

class ProgramExerciseSetDaoManager {
  final _$ProgramExerciseSetDaoMixin _db;
  ProgramExerciseSetDaoManager(this._db);
  $$ProgramExerciseSetsTableTableManager get programExerciseSets =>
      $$ProgramExerciseSetsTableTableManager(
        _db.attachedDatabase,
        _db.programExerciseSets,
      );
}
