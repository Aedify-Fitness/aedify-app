import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/data/provider_gate_service.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/features/settings/domain/provider_gate_decision.dart';
import 'package:aedify/features/settings/domain/provider_operation_type.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class DefaultProviderGateService implements ProviderGateService {
  DefaultProviderGateService({
    required ByokRepository byokRepository,
    required ProviderCapabilityRepository capabilityRepository,
    required NetworkStatus networkStatus,
  }) : _byokRepository = byokRepository,
       _capabilityRepository = capabilityRepository,
       _networkStatus = networkStatus;

  final ByokRepository _byokRepository;
  final ProviderCapabilityRepository _capabilityRepository;
  final NetworkStatus _networkStatus;

  @override
  Future<ProviderGateDecision> evaluate({
    required ProviderOperationType operation,
  }) async {
    final activeConfig = await _byokRepository.getActiveConfig();
    if (activeConfig == null) {
      return ProviderGateDecision.blocked(
        operation: operation,
        reason: ProviderGateFailureReason.missingProviderConfig,
        message: AppStrings.providerSetupRequired,
      );
    }

    final hasKey = await _byokRepository.hasKey(activeConfig.id);
    if (!hasKey) {
      return ProviderGateDecision.blocked(
        operation: operation,
        reason: ProviderGateFailureReason.missingKey,
        message: AppStrings.providerKeyRequired,
      );
    }

    if (activeConfig.selectedModel == null) {
      return ProviderGateDecision.blocked(
        operation: operation,
        reason: ProviderGateFailureReason.unsupportedModel,
        message: AppStrings.providerSetupRequired,
      );
    }

    final isOnline = await _networkStatus.check();
    if (!isOnline) {
      return ProviderGateDecision.blocked(
        operation: operation,
        reason: ProviderGateFailureReason.offline,
        message: AppStrings.providerOfflineBlocked,
      );
    }

    final capability = await _capabilityRepository.getCapability(
      providerName: activeConfig.providerName,
      modelName: activeConfig.selectedModel!,
    );

    if (capability == null) {
      return ProviderGateDecision.blocked(
        operation: operation,
        reason: ProviderGateFailureReason.capabilityUnknown,
        message: AppStrings.providerCapabilityUnavailable,
      );
    }

    final missingCapability = _checkRequiredCapability(operation, capability);
    if (missingCapability != null) {
      return ProviderGateDecision.blocked(
        operation: operation,
        reason: missingCapability,
        message: _messageForMissingCapability(missingCapability),
      );
    }

    return ProviderGateDecision.allowed(operation: operation);
  }

  ProviderGateFailureReason? _checkRequiredCapability(
    ProviderOperationType operation,
    ProviderCapabilityViewData capability,
  ) {
    switch (operation) {
      case ProviderOperationType.aiChat:
      case ProviderOperationType.externalTextImportParse:
        if (!capability.supportsTextInput) {
          return ProviderGateFailureReason.missingTextCapability;
        }
      case ProviderOperationType.aiWorkoutGeneration:
      case ProviderOperationType.aiProgrammeGeneration:
        if (!capability.supportsTextInput) {
          return ProviderGateFailureReason.missingTextCapability;
        }
        if (!capability.supportsJsonSchemaMode) {
          return ProviderGateFailureReason.missingJsonSchemaCapability;
        }
      case ProviderOperationType.structuredSaveFlow:
        if (!capability.supportsJsonSchemaMode) {
          return ProviderGateFailureReason.missingJsonSchemaCapability;
        }
      case ProviderOperationType.imageImport:
      case ProviderOperationType.physiqueAnalysis:
        if (!capability.supportsImageInput) {
          return ProviderGateFailureReason.missingImageCapability;
        }
    }
    return null;
  }

  String _messageForMissingCapability(ProviderGateFailureReason reason) {
    return switch (reason) {
      ProviderGateFailureReason.missingTextCapability =>
        AppStrings.providerTextOnly,
      ProviderGateFailureReason.missingImageCapability =>
        AppStrings.providerImageUnsupported,
      ProviderGateFailureReason.missingJsonSchemaCapability =>
        AppStrings.providerJsonUnsupported,
      _ => AppStrings.providerCapabilityUnavailable,
    };
  }
}
