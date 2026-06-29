import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/ai_model_capability_dao.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:drift/drift.dart';

class DriftProviderCapabilityRepository
    implements ProviderCapabilityRepository {
  DriftProviderCapabilityRepository({
    required AiModelCapabilityDao capabilityDao,
  }) : _capabilityDao = capabilityDao;

  final AiModelCapabilityDao _capabilityDao;

  @override
  Future<ProviderCapabilityViewData?> getCapability({
    required AiProviderName providerName,
    required String modelName,
  }) async {
    final row = await _capabilityDao.getCapability(
      providerName: providerName.dbValue,
      modelName: modelName,
    );
    if (row == null) return null;
    return ProviderCapabilityViewData(
      providerName: AiProviderName.fromDb(row.providerName),
      modelName: row.modelName,
      supportsTextInput: row.supportsTextInput,
      supportsImageInput: row.supportsImageInput,
      supportsJsonSchemaMode: row.supportsJsonSchemaMode,
      supportsStreaming: row.supportsStreaming,
      supportsToolCalling: row.supportsToolCalling,
      maxContextTokens: row.maxContextTokens,
      maxOutputTokens: row.maxOutputTokens,
      maxImagesPerRequest: row.maxImagesPerRequest,
      checkedAt: row.checkedAt,
    );
  }

  @override
  Future<void> saveCapability(ProviderCapabilityViewData capability) async {
    await _capabilityDao.upsertCapability(
      AiModelCapabilitiesCompanion(
        id: Value(_capabilityId(capability.providerName, capability.modelName)),
        providerName: Value(capability.providerName.dbValue),
        modelName: Value(capability.modelName),
        supportsTextInput: Value(capability.supportsTextInput),
        supportsImageInput: Value(capability.supportsImageInput),
        supportsJsonSchemaMode: Value(capability.supportsJsonSchemaMode),
        supportsStreaming: Value(capability.supportsStreaming),
        supportsToolCalling: Value(capability.supportsToolCalling),
        maxContextTokens: Value(capability.maxContextTokens),
        maxOutputTokens: Value(capability.maxOutputTokens),
        maxImagesPerRequest: Value(capability.maxImagesPerRequest),
        checkedAt: Value(capability.checkedAt),
      ),
    );
  }

  @override
  Future<void> clearCapability({
    required AiProviderName providerName,
    required String modelName,
  }) async {
    await _capabilityDao.deleteCapability(
      providerName: providerName.dbValue,
      modelName: modelName,
    );
  }

  String _capabilityId(AiProviderName providerName, String modelName) {
    return '${providerName.dbValue}_$modelName';
  }
}
