// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_template_exercise_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgramTemplateExerciseDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProgramTemplateExercisesTable get programTemplateExercises =>
      attachedDatabase.programTemplateExercises;
  ProgramTemplateExerciseDaoManager get managers =>
      ProgramTemplateExerciseDaoManager(this);
}

class ProgramTemplateExerciseDaoManager {
  final _$ProgramTemplateExerciseDaoMixin _db;
  ProgramTemplateExerciseDaoManager(this._db);
  $$ProgramTemplateExercisesTableTableManager get programTemplateExercises =>
      $$ProgramTemplateExercisesTableTableManager(
        _db.attachedDatabase,
        _db.programTemplateExercises,
      );
}
