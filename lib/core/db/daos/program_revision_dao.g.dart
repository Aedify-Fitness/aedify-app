// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_revision_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgramRevisionDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProgramRevisionsTable get programRevisions =>
      attachedDatabase.programRevisions;
  ProgramRevisionDaoManager get managers => ProgramRevisionDaoManager(this);
}

class ProgramRevisionDaoManager {
  final _$ProgramRevisionDaoMixin _db;
  ProgramRevisionDaoManager(this._db);
  $$ProgramRevisionsTableTableManager get programRevisions =>
      $$ProgramRevisionsTableTableManager(
        _db.attachedDatabase,
        _db.programRevisions,
      );
}
