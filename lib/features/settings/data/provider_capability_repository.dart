import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';

abstract class ProviderCapabilityRepository {
  Future<ProviderCapabilityViewData?> getCapability({
    required String providerName,
    required String modelName,
  });

  Future<void> saveCapability(ProviderCapabilityViewData capability);

  Future<void> clearCapability({
    required String providerName,
    required String modelName,
  });
}
