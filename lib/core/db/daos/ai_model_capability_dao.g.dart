// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_model_capability_dao.dart';

// ignore_for_file: type=lint
mixin _$AiModelCapabilityDaoMixin on DatabaseAccessor<AppDatabase> {
  $AiModelCapabilitiesTable get aiModelCapabilities =>
      attachedDatabase.aiModelCapabilities;
  AiModelCapabilityDaoManager get managers => AiModelCapabilityDaoManager(this);
}

class AiModelCapabilityDaoManager {
  final _$AiModelCapabilityDaoMixin _db;
  AiModelCapabilityDaoManager(this._db);
  $$AiModelCapabilitiesTableTableManager get aiModelCapabilities =>
      $$AiModelCapabilitiesTableTableManager(
        _db.attachedDatabase,
        _db.aiModelCapabilities,
      );
}
