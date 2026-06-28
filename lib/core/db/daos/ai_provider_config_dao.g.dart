// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_provider_config_dao.dart';

// ignore_for_file: type=lint
mixin _$AiProviderConfigDaoMixin on DatabaseAccessor<AppDatabase> {
  $AiProviderConfigsTable get aiProviderConfigs =>
      attachedDatabase.aiProviderConfigs;
  AiProviderConfigDaoManager get managers => AiProviderConfigDaoManager(this);
}

class AiProviderConfigDaoManager {
  final _$AiProviderConfigDaoMixin _db;
  AiProviderConfigDaoManager(this._db);
  $$AiProviderConfigsTableTableManager get aiProviderConfigs =>
      $$AiProviderConfigsTableTableManager(
        _db.attachedDatabase,
        _db.aiProviderConfigs,
      );
}
