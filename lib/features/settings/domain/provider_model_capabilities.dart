import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';

/// Conservative registry for the models exposed by Aedify's provider picker.
/// Metadata proves access; it does not imply support for every operation.
class ProviderModelCapabilities {
  ProviderModelCapabilities._();

  static const _models = {
    AiProviderName.openai: {'gpt-4o', 'gpt-4o-mini', 'o1', 'o1-mini'},
    AiProviderName.anthropic: {
      'claude-sonnet-4-6',
      'claude-haiku-4-5-20251001',
      'claude-opus-4-7',
    },
    AiProviderName.google: {'gemini-2.5-pro', 'gemini-2.5-flash'},
  };

  static bool isKnown(AiProviderName provider, String model) =>
      _models[provider]?.contains(model) ?? false;

  static bool matchesModel(String selected, String returned) =>
      returned == selected || returned == 'models/$selected';

  static ProviderCapabilityViewData fromMetadata(
    AiProviderName provider,
    String model,
    Map<String, dynamic> metadata,
  ) {
    final known = isKnown(provider, model);
    final legacyReasoning = model == 'o1-mini';
    final google = provider == AiProviderName.google;
    final methods = metadata['supportedGenerationMethods'];
    final text =
        known &&
        (!google || (methods is List && methods.contains('generateContent')));
    final capabilities = metadata['capabilities'];
    bool supported(String name, bool fallback) {
      if (capabilities is! Map || !capabilities.containsKey(name)) {
        return fallback;
      }
      final capability = capabilities[name];
      return capability is Map && capability['supported'] == true;
    }

    return ProviderCapabilityViewData(
      providerName: provider,
      modelName: model,
      supportsTextInput: text,
      supportsImageInput:
          text && !legacyReasoning && supported('image_input', true),
      supportsJsonSchemaMode:
          text && !legacyReasoning && supported('structured_outputs', true),
      supportsStreaming: text,
      supportsToolCalling: text && !legacyReasoning,
      maxContextTokens: metadata['inputTokenLimit'] is int
          ? metadata['inputTokenLimit'] as int
          : null,
      maxOutputTokens: metadata['outputTokenLimit'] is int
          ? metadata['outputTokenLimit'] as int
          : null,
      maxImagesPerRequest: null,
      checkedAt: DateTime.now(),
    );
  }
}
