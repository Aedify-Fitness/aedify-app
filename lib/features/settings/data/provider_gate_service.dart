import 'package:aedify/features/settings/domain/provider_gate_decision.dart';
import 'package:aedify/features/settings/domain/provider_operation_type.dart';

abstract class ProviderGateService {
  Future<ProviderGateDecision> evaluate({
    required ProviderOperationType operation,
  });
}
