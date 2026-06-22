// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_meta_dao.dart';

// ignore_for_file: type=lint
mixin _$LibraryMetaDaoMixin on DatabaseAccessor<AppDatabase> {
  $LibraryMetaTable get libraryMeta => attachedDatabase.libraryMeta;
  LibraryMetaDaoManager get managers => LibraryMetaDaoManager(this);
}

class LibraryMetaDaoManager {
  final _$LibraryMetaDaoMixin _db;
  LibraryMetaDaoManager(this._db);
  $$LibraryMetaTableTableManager get libraryMeta =>
      $$LibraryMetaTableTableManager(_db.attachedDatabase, _db.libraryMeta);
}
