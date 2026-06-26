import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';

class ProviderCapabilityState {
  const ProviderCapabilityState({
    required this.isLoading,
    this.capability,
    this.errorCode,
    this.errorMessage,
  });

  final bool isLoading;
  final ProviderCapabilityViewData? capability;
  final String? errorCode;
  final String? errorMessage;

  bool get hasError => errorCode != null || errorMessage != null;

  ProviderCapabilityState copyWith({
    bool? isLoading,
    ProviderCapabilityViewData? capability,
    String? errorCode,
    String? errorMessage,
    bool clearCapability = false,
    bool clearError = false,
  }) {
    return ProviderCapabilityState(
      isLoading: isLoading ?? this.isLoading,
      capability: clearCapability ? null : (capability ?? this.capability),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  const ProviderCapabilityState.initial() : this(isLoading: false);
}
