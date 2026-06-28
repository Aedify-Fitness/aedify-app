import 'package:aedify/features/settings/domain/byok_config_view_data.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';

abstract class ByokRepository {
  Future<List<ByokConfigViewData>> getConfigs();

  Future<List<ByokProviderOption>> getProviderOptions();

  Future<ByokConfigViewData?> getActiveConfig();

  Future<String> saveConfig(ByokEditDraft draft);

  Future<void> rotateKey({
    required String configId,
    required String providerName,
    required String newApiKey,
  });

  Future<void> deleteConfig(String configId);

  Future<void> setActiveConfig(String configId);

  Future<bool> hasKey(String configId);

  Future<void> clearActiveConfig();

  Future<bool> validateKey({
    required String providerName,
    required String apiKey,
  });
}
