// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_week_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgramWeekDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProgramWeeksTable get programWeeks => attachedDatabase.programWeeks;
  ProgramWeekDaoManager get managers => ProgramWeekDaoManager(this);
}

class ProgramWeekDaoManager {
  final _$ProgramWeekDaoMixin _db;
  ProgramWeekDaoManager(this._db);
  $$ProgramWeeksTableTableManager get programWeeks =>
      $$ProgramWeeksTableTableManager(_db.attachedDatabase, _db.programWeeks);
}
