import 'package:aedify/core/db/daos/ai_provider_config_dao.dart';
import 'package:aedify/core/storage/secure_storage_service.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/data/provider_key_validator.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:aedify/shared/domain/provider_validation_status.dart';

class ProviderCapabilityRefreshService {
  ProviderCapabilityRefreshService({
    required AiProviderConfigDao configDao,
    required SecureStorageService secureStorage,
    required ProviderCapabilityRepository repository,
    required ProviderKeyValidator validator,
  }) : _configDao = configDao,
       _secureStorage = secureStorage,
       _repository = repository,
       _validator = validator;

  final AiProviderConfigDao _configDao;
  final SecureStorageService _secureStorage;
  final ProviderCapabilityRepository _repository;
  final ProviderKeyValidator _validator;

  Future<ProviderCapabilityViewData> refresh({
    required AiProviderName providerName,
    required String modelName,
  }) async {
    final configs =
        (await _configDao.getAllConfigs())
            .where(
              (row) =>
                  row.providerName == providerName.dbValue &&
                  row.selectedModel == modelName,
            )
            .toList()
          ..sort((a, b) => (b.isActive ? 1 : 0).compareTo(a.isActive ? 1 : 0));
    if (configs.isEmpty) {
      throw const ProviderValidationFailure(AppErrorCodes.invalidKey);
    }
    final config = configs.first;
    final key = await _secureStorage.readProviderApiKey(config.secureKeyAlias);
    try {
      if (key == null || key.isEmpty) {
        throw const ProviderValidationFailure(AppErrorCodes.invalidKey);
      }
      final capability = await _validator.inspectModel(
        providerName: providerName,
        apiKey: key,
        modelName: modelName,
      );
      // A key or model may have changed while the request was in flight.
      final current = await _configDao.getById(config.id);
      final currentKey = await _secureStorage.readProviderApiKey(
        config.secureKeyAlias,
      );
      if (current == null ||
          current.updatedAt != config.updatedAt ||
          current.selectedModel != config.selectedModel ||
          current.providerName != config.providerName ||
          currentKey != key) {
        throw const ProviderValidationFailure(AppErrorCodes.validationFailed);
      }
      await _configDao.transaction(() async {
        await _repository.saveCapability(capability);
        await _configDao.updateValidationState(
          id: config.id,
          validatedAt: capability.checkedAt,
          validationStatus: ProviderValidationStatus.valid.dbValue,
        );
      });
      return capability;
    } on ProviderValidationFailure catch (failure) {
      final current = await _configDao.getById(config.id);
      final currentKey = await _secureStorage.readProviderApiKey(
        config.secureKeyAlias,
      );
      if (current != null &&
          current.updatedAt == config.updatedAt &&
          current.selectedModel == config.selectedModel &&
          current.providerName == config.providerName &&
          currentKey == key &&
          (failure.code == AppErrorCodes.invalidKey ||
              failure.code == AppErrorCodes.unsupportedModel)) {
        await _repository.clearCapability(
          providerName: providerName,
          modelName: modelName,
        );
        await _configDao.updateValidationState(
          id: config.id,
          validatedAt: DateTime.now(),
          validationStatus: ProviderValidationStatus.invalid.dbValue,
          errorCode: failure.code,
        );
      }
      rethrow;
    }
  }
}
