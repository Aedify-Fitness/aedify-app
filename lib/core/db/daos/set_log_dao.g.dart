// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_log_dao.dart';

// ignore_for_file: type=lint
mixin _$SetLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $SetLogsTable get setLogs => attachedDatabase.setLogs;
  SetLogDaoManager get managers => SetLogDaoManager(this);
}

class SetLogDaoManager {
  final _$SetLogDaoMixin _db;
  SetLogDaoManager(this._db);
  $$SetLogsTableTableManager get setLogs =>
      $$SetLogsTableTableManager(_db.attachedDatabase, _db.setLogs);
}
