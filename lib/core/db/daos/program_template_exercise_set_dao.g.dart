// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_template_exercise_set_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgramTemplateExerciseSetDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProgramTemplateExerciseSetsTable get programTemplateExerciseSets =>
      attachedDatabase.programTemplateExerciseSets;
  ProgramTemplateExerciseSetDaoManager get managers =>
      ProgramTemplateExerciseSetDaoManager(this);
}

class ProgramTemplateExerciseSetDaoManager {
  final _$ProgramTemplateExerciseSetDaoMixin _db;
  ProgramTemplateExerciseSetDaoManager(this._db);
  $$ProgramTemplateExerciseSetsTableTableManager
  get programTemplateExerciseSets =>
      $$ProgramTemplateExerciseSetsTableTableManager(
        _db.attachedDatabase,
        _db.programTemplateExerciseSets,
      );
}
