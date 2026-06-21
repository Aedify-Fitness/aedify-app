// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_file_record_dao.dart';

// ignore_for_file: type=lint
mixin _$LocalFileRecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalFileRecordsTable get localFileRecords =>
      attachedDatabase.localFileRecords;
  LocalFileRecordDaoManager get managers => LocalFileRecordDaoManager(this);
}

class LocalFileRecordDaoManager {
  final _$LocalFileRecordDaoMixin _db;
  LocalFileRecordDaoManager(this._db);
  $$LocalFileRecordsTableTableManager get localFileRecords =>
      $$LocalFileRecordsTableTableManager(
        _db.attachedDatabase,
        _db.localFileRecords,
      );
}
