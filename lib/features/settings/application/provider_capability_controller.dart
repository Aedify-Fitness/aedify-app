import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/application/provider_capability_state.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderCapabilityController
    extends AsyncNotifier<ProviderCapabilityState> {
  ProviderCapabilityController(this._providerName, this._modelName);

  final AiProviderName _providerName;
  final String _modelName;

  @override
  Future<ProviderCapabilityState> build() async {
    final repository = ref.read(
      AppProviders.providerCapabilityRepositoryProvider,
    );
    try {
      final capability = await repository.getCapability(
        providerName: _providerName,
        modelName: _modelName,
      );
      return ProviderCapabilityState(isLoading: false, capability: capability);
    } catch (e) {
      return ProviderCapabilityState(
        isLoading: false,
        errorCode: AppErrorCodes.capabilityLoadFailed,
        errorMessage: AppErrorStrings.providerCapabilityLoadFailedMessage,
      );
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
