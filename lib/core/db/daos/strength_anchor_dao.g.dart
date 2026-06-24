// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strength_anchor_dao.dart';

// ignore_for_file: type=lint
mixin _$StrengthAnchorDaoMixin on DatabaseAccessor<AppDatabase> {
  $StrengthAnchorsTable get strengthAnchors => attachedDatabase.strengthAnchors;
  StrengthAnchorDaoManager get managers => StrengthAnchorDaoManager(this);
}

class StrengthAnchorDaoManager {
  final _$StrengthAnchorDaoMixin _db;
  StrengthAnchorDaoManager(this._db);
  $$StrengthAnchorsTableTableManager get strengthAnchors =>
      $$StrengthAnchorsTableTableManager(
        _db.attachedDatabase,
        _db.strengthAnchors,
      );
}
