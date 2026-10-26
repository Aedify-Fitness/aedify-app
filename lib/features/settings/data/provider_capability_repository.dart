import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';

abstract class ProviderCapabilityRepository {
  Future<ProviderCapabilityViewData?> getCapability({
    required AiProviderName providerName,
    required String modelName,
  });

  Future<void> saveCapability(ProviderCapabilityViewData capability);

  Future<void> clearCapability({
    required AiProviderName providerName,
    required String modelName,
  });
}
