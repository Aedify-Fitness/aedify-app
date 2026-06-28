import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/ai_provider_configs.dart';

part 'ai_provider_config_dao.g.dart';

@DriftAccessor(tables: [AiProviderConfigs])
class AiProviderConfigDao extends DatabaseAccessor<AppDatabase>
    with _$AiProviderConfigDaoMixin {
  AiProviderConfigDao(super.db);

  Future<List<AiProviderConfig>> getAllConfigs() {
    return select(aiProviderConfigs).get();
  }

  Future<AiProviderConfig?> getById(String id) {
    return (select(
      aiProviderConfigs,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<AiProviderConfig?> getActiveConfig() {
    return (select(
      aiProviderConfigs,
    )..where((t) => t.isActive.equals(true))).getSingleOrNull();
  }

  Future<void> upsertConfig(AiProviderConfigsCompanion entry) {
    return into(aiProviderConfigs).insertOnConflictUpdate(entry);
  }

  Future<void> setActiveConfig(String id) async {
    await transaction(() async {
      await customUpdate(
        'UPDATE ai_provider_configs SET is_active = 0 WHERE is_active = 1',
      );
      await (update(aiProviderConfigs)..where((t) => t.id.equals(id))).write(
        const AiProviderConfigsCompanion(isActive: Value(true)),
      );
    });
  }

  Future<void> clearActiveConfig() async {
    await customUpdate(
      'UPDATE ai_provider_configs SET is_active = 0 WHERE is_active = 1',
    );
  }

  Future<void> deleteConfig(String id) async {
    await (delete(aiProviderConfigs)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateValidationState({
    required String id,
    required DateTime validatedAt,
    required String validationStatus,
    String? errorCode,
  }) async {
    await (update(aiProviderConfigs)..where((t) => t.id.equals(id))).write(
      AiProviderConfigsCompanion(
        lastValidatedAt: Value(validatedAt),
        lastValidationStatus: Value(validationStatus),
        lastErrorCode: Value(errorCode),
        updatedAt: Value(validatedAt),
      ),
    );
  }
}
