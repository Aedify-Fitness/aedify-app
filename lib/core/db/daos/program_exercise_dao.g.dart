// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_exercise_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgramExerciseDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProgramExercisesTable get programExercises =>
      attachedDatabase.programExercises;
  ProgramExerciseDaoManager get managers => ProgramExerciseDaoManager(this);
}

class ProgramExerciseDaoManager {
  final _$ProgramExerciseDaoMixin _db;
  ProgramExerciseDaoManager(this._db);
  $$ProgramExercisesTableTableManager get programExercises =>
      $$ProgramExercisesTableTableManager(
        _db.attachedDatabase,
        _db.programExercises,
      );
}
