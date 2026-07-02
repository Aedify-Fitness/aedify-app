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

class DriftByokRepository implements ByokRepository {
  DriftByokRepository({
    required AiProviderConfigDao configDao,
    required SecureStorageService secureStorageService,
  }) : _configDao = configDao,
       _secureStorageService = secureStorageService;

  static final _logger = AppLogger(name: 'DriftByokRepository');

  final AiProviderConfigDao _configDao;
  final SecureStorageService _secureStorageService;

  static const _builtInProviders = [
    ByokProviderOption(
      id: 'openai',
      providerName: AiProviderName.openai,
      displayName: 'OpenAI',
      description: AppStrings.byokProviderOpenAiDescription,
      models: [
        ByokModelOption(
          id: 'gpt-4o',
          displayName: 'GPT-4o',
          inputCostPer1kTokens: 0.0025,
          outputCostPer1kTokens: 0.01,
        ),
        ByokModelOption(
          id: 'gpt-4o-mini',
          displayName: 'GPT-4o mini',
          inputCostPer1kTokens: 0.00015,
          outputCostPer1kTokens: 0.0006,
        ),
        ByokModelOption(
          id: 'o1',
          displayName: 'o1',
          inputCostPer1kTokens: 0.015,
          outputCostPer1kTokens: 0.06,
        ),
        ByokModelOption(
          id: 'o1-mini',
          displayName: 'o1-mini',
          inputCostPer1kTokens: 0.003,
          outputCostPer1kTokens: 0.012,
        ),
      ],
    ),
    ByokProviderOption(
      id: 'anthropic',
      providerName: AiProviderName.anthropic,
      displayName: 'Anthropic',
      description: AppStrings.byokProviderAnthropicDescription,
      models: [
        ByokModelOption(
          id: 'claude-sonnet-4-20250514',
          displayName: 'Claude Sonnet 4.6',
          inputCostPer1kTokens: 0.003,
          outputCostPer1kTokens: 0.015,
        ),
        ByokModelOption(
          id: 'claude-3-5-haiku-20241022',
          displayName: 'Claude Haiku 4.5',
          inputCostPer1kTokens: 0.0008,
          outputCostPer1kTokens: 0.004,
        ),
        ByokModelOption(
          id: 'claude-opus-4-20250514',
          displayName: 'Claude Opus 4.7',
          inputCostPer1kTokens: 0.015,
          outputCostPer1kTokens: 0.075,
        ),
      ],
    ),
    ByokProviderOption(
      id: 'google',
      providerName: AiProviderName.google,
      displayName: 'Google',
      description: AppStrings.byokProviderGoogleDescription,
      models: [
        ByokModelOption(
          id: 'gemini-2.5-pro',
          displayName: 'Gemini 2.5 Pro',
          inputCostPer1kTokens: 0.00125,
          outputCostPer1kTokens: 0.005,
        ),
        ByokModelOption(
          id: 'gemini-2.5-flash',
          displayName: 'Gemini 2.5 Flash',
          inputCostPer1kTokens: 0.000075,
          outputCostPer1kTokens: 0.0003,
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
    _logger.info('saveConfig — provider: ${draft.providerName?.name}');
    final now = DateTime.now();
    final configId = draft.configId ?? const Uuid().v4();
    final alias = configId;

    if (draft.apiKey != null && draft.apiKey!.isNotEmpty) {
      await _secureStorageService.saveProviderApiKey(alias, draft.apiKey!);
    }

    await _configDao.upsertConfig(
      AiProviderConfigsCompanion(
        id: Value(configId),
        providerName: Value(draft.providerName!.dbValue),
        secureKeyAlias: Value(alias),
        selectedModel: Value(draft.selectedModel),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    if (draft.makeActive) {
      await _configDao.setActiveConfig(configId);
    }

    return configId;
  }

  @override
  Future<void> rotateKey({
    required String configId,
    required AiProviderName providerName,
    required String newApiKey,
  }) async {
    _logger.info('rotateKey — configId: $configId');
    final alias = configId;
    await _secureStorageService.rotateProviderApiKey(alias, newApiKey);
    final now = DateTime.now();
    await _configDao.upsertConfig(
      AiProviderConfigsCompanion(
        id: Value(configId),
        providerName: Value(providerName.dbValue),
        secureKeyAlias: Value(alias),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteConfig(String configId) async {
    _logger.info('deleteConfig — configId: $configId');
    final alias = configId;
    await _secureStorageService.deleteProviderApiKey(alias);
    await _configDao.deleteConfig(configId);
  }

  @override
  Future<void> setActiveConfig(String configId) async {
    await _configDao.setActiveConfig(configId);
  }

  @override
  Future<bool> hasKey(String configId) async {
    return _secureStorageService.hasProviderApiKey(configId);
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
      final result = await ProviderKeyValidator.validate(
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
