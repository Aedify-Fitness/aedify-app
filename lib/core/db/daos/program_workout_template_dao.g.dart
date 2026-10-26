// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_workout_template_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgramWorkoutTemplateDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProgramWorkoutTemplatesTable get programWorkoutTemplates =>
      attachedDatabase.programWorkoutTemplates;
  ProgramWorkoutTemplateDaoManager get managers =>
      ProgramWorkoutTemplateDaoManager(this);
}

class ProgramWorkoutTemplateDaoManager {
  final _$ProgramWorkoutTemplateDaoMixin _db;
  ProgramWorkoutTemplateDaoManager(this._db);
  $$ProgramWorkoutTemplatesTableTableManager get programWorkoutTemplates =>
      $$ProgramWorkoutTemplatesTableTableManager(
        _db.attachedDatabase,
        _db.programWorkoutTemplates,
      );
}
