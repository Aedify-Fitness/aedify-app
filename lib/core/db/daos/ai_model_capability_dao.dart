import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/ai_model_capabilities.dart';

part 'ai_model_capability_dao.g.dart';

@DriftAccessor(tables: [AiModelCapabilities])
class AiModelCapabilityDao extends DatabaseAccessor<AppDatabase>
    with _$AiModelCapabilityDaoMixin {
  AiModelCapabilityDao(super.db);

  Future<AiModelCapability?> getCapability({
    required String providerName,
    required String modelName,
  }) {
    return (select(aiModelCapabilities)..where(
          (t) =>
              t.providerName.equals(providerName) &
              t.modelName.equals(modelName),
        ))
        .getSingleOrNull();
  }

  Future<void> upsertCapability(AiModelCapabilitiesCompanion capability) {
    return into(aiModelCapabilities).insertOnConflictUpdate(capability);
  }

  Future<void> deleteCapability({
    required String providerName,
    required String modelName,
  }) async {
    await (delete(aiModelCapabilities)..where(
          (t) =>
              t.providerName.equals(providerName) &
              t.modelName.equals(modelName),
        ))
        .go();
  }
}
