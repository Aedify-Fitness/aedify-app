import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:aedify/shared/domain/provider_validation_status.dart';

class ByokConfigViewData {
  const ByokConfigViewData({
    required this.id,
    required this.providerName,
    required this.displayName,
    required this.selectedModel,
    required this.hasKey,
    required this.isActive,
    required this.lastValidationStatus,
    required this.lastErrorCode,
  });

  final String id;
  final AiProviderName providerName;
  final String? displayName;
  final String? selectedModel;
  final bool hasKey;
  final bool isActive;
  final ProviderValidationStatus? lastValidationStatus;
  final String? lastErrorCode;
}
