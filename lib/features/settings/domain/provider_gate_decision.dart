import 'package:aedify/features/settings/domain/provider_operation_type.dart';

enum ProviderGateFailureReason {
  missingProviderConfig,
  missingKey,
  unsupportedModel,
  missingTextCapability,
  missingImageCapability,
  missingJsonSchemaCapability,
  offline,
  capabilityUnknown,
}

class ProviderGateDecision {
  const ProviderGateDecision.allowed({required this.operation})
    : isAllowed = true,
      reason = null,
      message = null;

  const ProviderGateDecision.blocked({
    required this.operation,
    required this.reason,
    required this.message,
  }) : isAllowed = false;

  final ProviderOperationType operation;
  final bool isAllowed;
  final ProviderGateFailureReason? reason;
  final String? message;
}
