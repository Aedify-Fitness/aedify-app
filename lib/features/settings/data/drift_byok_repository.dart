import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/ai_provider_config_dao.dart';
import 'package:aedify/core/storage/secure_storage_service.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/domain/byok_config_view_data.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_model_option.dart';
import 'package:aedify/features/settings/data/provider_key_validator.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:aedify/shared/domain/provider_validation_status.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:aedify/core/db/daos/ai_model_capability_dao.dart';
import 'package:aedify/features/settings/data/drift_provider_capability_repository.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';

class DriftByokRepository implements ByokRepository {
  DriftByokRepository({
    required AiProviderConfigDao configDao,
    required SecureStorageService secureStorageService,
    ProviderKeyValidator? keyValidator,
    ProviderCapabilityRepository? capabilityRepository,
  }) : _configDao = configDao,
       _secureStorageService = secureStorageService,
       _keyValidator = keyValidator ?? ProviderKeyValidator(),
       _capabilityRepository =
           capabilityRepository ??
           DriftProviderCapabilityRepository(
             capabilityDao: AiModelCapabilityDao(configDao.attachedDatabase),
           );

  static final _logger = AppLogger(name: 'DriftByokRepository');

  final AiProviderConfigDao _configDao;
  final SecureStorageService _secureStorageService;
  final ProviderKeyValidator _keyValidator;
  final ProviderCapabilityRepository _capabilityRepository;

  static const _builtInProviders = [
    ByokProviderOption(
      id: 'openai',
      providerName: AiProviderName.openai,
      displayName: AppStrings.byokProviderNameOpenAi,
      description: AppStrings.byokProviderOpenAiDescription,
      models: [
        ByokModelOption(
          id: 'gpt-4o',
          displayName: AppStrings.byokModelGpt4o,
          inputCostPer1kTokens: 0.0025,
          outputCostPer1kTokens: 0.01,
        ),
        ByokModelOption(
          id: 'gpt-4o-mini',
          displayName: AppStrings.byokModelGpt4oMini,
          inputCostPer1kTokens: 0.00015,
          outputCostPer1kTokens: 0.0006,
        ),
        ByokModelOption(
          id: 'o1',
          displayName: AppStrings.byokModelO1,
          inputCostPer1kTokens: 0.015,
          outputCostPer1kTokens: 0.06,
        ),
        ByokModelOption(
          id: 'o1-mini',
          displayName: AppStrings.byokModelO1Mini,
          inputCostPer1kTokens: 0.003,
          outputCostPer1kTokens: 0.012,
        ),
      ],
    ),
    ByokProviderOption(
      id: 'anthropic',
      providerName: AiProviderName.anthropic,
      displayName: AppStrings.byokProviderNameAnthropic,
      description: AppStrings.byokProviderAnthropicDescription,
      models: [
        ByokModelOption(
          id: 'claude-sonnet-4-6',
          displayName: AppStrings.byokModelClaudeSonnet46,
          inputCostPer1kTokens: 0.003,
          outputCostPer1kTokens: 0.015,
        ),
        ByokModelOption(
          id: 'claude-haiku-4-5-20251001',
          displayName: AppStrings.byokModelClaudeHaiku45,
          inputCostPer1kTokens: 0.001,
          outputCostPer1kTokens: 0.005,
        ),
        ByokModelOption(
          id: 'claude-opus-4-7',
          displayName: AppStrings.byokModelClaudeOpus47,
          inputCostPer1kTokens: 0.005,
          outputCostPer1kTokens: 0.025,
        ),
      ],
    ),
    ByokProviderOption(
      id: 'google',
      providerName: AiProviderName.google,
      displayName: AppStrings.byokProviderNameGoogle,
      description: AppStrings.byokProviderGoogleDescription,
      models: [
        ByokModelOption(
          id: 'gemini-2.5-pro',
          displayName: AppStrings.byokModelGemini25Pro,
          inputCostPer1kTokens: 0.00125,
          outputCostPer1kTokens: 0.005,
        ),
        ByokModelOption(
          id: 'gemini-2.5-flash',
          displayName: AppStrings.byokModelGemini25Flash,
          inputCostPer1kTokens: 0.0003,
          outputCostPer1kTokens: 0.0025,
        ),
      ],
    ),
  ];

  @override
  Future<List<ByokConfigViewData>> getConfigs() async {
    final rows = await _configDao.getAllConfigs();
    final result = <ByokConfigViewData>[];
    for (final row in rows) {
      final hasKey = await _secureStorageService.hasProviderApiKey(
        row.secureKeyAlias,
      );
      result.add(_toViewData(row, hasKey));
    }
    return result;
  }

  @override
  Future<List<ByokProviderOption>> getProviderOptions() async {
    return _builtInProviders;
  }

  @override
  Future<ByokConfigViewData?> getActiveConfig() async {
    final row = await _configDao.getActiveConfig();
    if (row == null) return null;
    final hasKey = await _secureStorageService.hasProviderApiKey(
      row.secureKeyAlias,
    );
    return _toViewData(row, hasKey);
  }

  @override
  Future<String> saveConfig(ByokEditDraft draft) async {
    final provider = draft.providerName;
    if (provider == null) {
      throw const ProviderValidationFailure(AppErrorCodes.unsupportedProvider);
    }
    final existing = draft.configId == null
        ? null
        : await _configDao.getById(draft.configId!);
    if (draft.configId != null && existing == null) {
      throw const ProviderValidationFailure(AppErrorCodes.validationFailed);
    }
    final configId = existing?.id ?? const Uuid().v4();
    final alias = existing?.secureKeyAlias ?? configId;
    final oldKey = await _secureStorageService.readProviderApiKey(alias);
    final supplied = draft.apiKey?.trim();
    if (existing != null &&
        existing.providerName != provider.dbValue &&
        (supplied == null || supplied.isEmpty)) {
      throw const ProviderValidationFailure(AppErrorCodes.invalidKey);
    }
    final key = (supplied == null || supplied.isEmpty) ? oldKey : supplied;
    if (key == null || key.isEmpty) {
      throw const ProviderValidationFailure(AppErrorCodes.invalidKey);
    }
    final capability = await _inspect(provider, key, draft.selectedModel);
    if (existing != null) {
      final current = await _configDao.getById(existing.id);
      if (current == null ||
          current.updatedAt != existing.updatedAt ||
          current.selectedModel != existing.selectedModel ||
          current.providerName != existing.providerName ||
          await _secureStorageService.readProviderApiKey(alias) != oldKey) {
        throw const ProviderValidationFailure(AppErrorCodes.validationFailed);
      }
    }
    final now = DateTime.now();
    await _secureStorageService.saveProviderApiKey(alias, key);
    try {
      await _configDao.transaction(() async {
        await _configDao.upsertConfig(
          AiProviderConfigsCompanion(
            id: Value(configId),
            providerName: Value(provider.dbValue),
            secureKeyAlias: Value(alias),
            selectedModel: Value(draft.selectedModel),
            isActive: Value(existing?.isActive ?? false),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
            lastValidatedAt: Value(now),
            lastValidationStatus: Value(ProviderValidationStatus.valid.dbValue),
            lastErrorCode: const Value(null),
          ),
        );
        if (capability != null) {
          await _capabilityRepository.saveCapability(capability);
        }
        if (draft.makeActive) await _configDao.setActiveConfig(configId);
      });
    } catch (_) {
      if (await _secureStorageService.readProviderApiKey(alias) == key) {
        await _restoreKey(alias, oldKey);
      }
      rethrow;
    }
    return configId;
  }

  Future<ProviderCapabilityViewData?> _inspect(
    AiProviderName provider,
    String key,
    String? model,
  ) async {
    if (model != null) {
      return _keyValidator.inspectModel(
        providerName: provider,
        apiKey: key,
        modelName: model,
      );
    }
    final result = await _keyValidator.checkKey(
      providerName: provider,
      apiKey: key,
    );
    if (!result.isValid) {
      throw ProviderValidationFailure(
        result.errorCode ?? AppErrorCodes.invalidKey,
      );
    }
    return null;
  }

  Future<void> _restoreKey(String alias, String? oldKey) async {
    if (oldKey == null) {
      await _secureStorageService.deleteProviderApiKey(alias);
    } else {
      await _secureStorageService.saveProviderApiKey(alias, oldKey);
    }
  }

  @override
  Future<void> rotateKey({
    required String configId,
    required AiProviderName providerName,
    required String newApiKey,
  }) async {
    final existing = await _configDao.getById(configId);
    if (existing == null || existing.providerName != providerName.dbValue) {
      throw const ProviderValidationFailure(AppErrorCodes.validationFailed);
    }
    await saveConfig(
      ByokEditDraft(
        configId: configId,
        providerName: providerName,
        selectedModel: existing.selectedModel,
        apiKey: newApiKey,
        makeActive: existing.isActive,
      ),
    );
  }

  @override
  Future<void> deleteConfig(String configId) async {
    _logger.info('deleteConfig — configId: $configId');
    final row = await _configDao.getById(configId);
    if (row == null) return;
    await _secureStorageService.deleteProviderApiKey(row.secureKeyAlias);
    await _configDao.deleteConfig(configId);
  }

  @override
  Future<void> setActiveConfig(String configId) async {
    await _configDao.setActiveConfig(configId);
  }

  @override
  Future<bool> hasKey(String configId) async {
    final row = await _configDao.getById(configId);
    return row != null &&
        await _secureStorageService.hasProviderApiKey(row.secureKeyAlias);
  }

  @override
  Future<void> clearActiveConfig() async {
    await _configDao.clearActiveConfig();
  }

  @override
  Future<bool> validateKey({
    required AiProviderName providerName,
    required String apiKey,
  }) async {
    _logger.info('validateKey — provider: ${providerName.name}');
    try {
      final result = await _keyValidator.checkKey(
        providerName: providerName,
        apiKey: apiKey,
      );
      return result.isValid;
    } catch (e) {
      _logger.error('validateKey — failed: ${providerName.name}', error: e);
      rethrow;
    }
  }

  ByokConfigViewData _toViewData(AiProviderConfig row, bool hasKey) {
    return ByokConfigViewData(
      id: row.id,
      providerName: AiProviderName.fromDb(row.providerName),
      displayName: row.displayName,
      selectedModel: row.selectedModel,
      hasKey: hasKey,
      isActive: row.isActive,
      lastValidationStatus: row.lastValidationStatus == null
          ? null
          : ProviderValidationStatus.fromDb(row.lastValidationStatus!),
      lastErrorCode: row.lastErrorCode,
    );
  }
}
