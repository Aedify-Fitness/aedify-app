import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/data/default_provider_gate_service.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/domain/byok_config_view_data.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/features/settings/domain/provider_gate_decision.dart';
import 'package:aedify/features/settings/domain/provider_operation_type.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockByokRepository implements ByokRepository {
  _MockByokRepository({this.activeConfig, this.hasKeyValue = true});

  final ByokConfigViewData? activeConfig;
  final bool hasKeyValue;

  @override
  Future<ByokConfigViewData?> getActiveConfig() async => activeConfig;

  @override
  Future<bool> hasKey(String configId) async => hasKeyValue;

  @override
  Future<List<ByokConfigViewData>> getConfigs() async => [];

  @override
  Future<List<ByokProviderOption>> getProviderOptions() async => [];

  @override
  Future<String> saveConfig(ByokEditDraft draft) async => '';

  @override
  Future<void> rotateKey({
    required String configId,
    required String providerName,
    required String newApiKey,
  }) async {}

  @override
  Future<void> deleteConfig(String configId) async {}

  @override
  Future<void> setActiveConfig(String configId) async {}

  @override
  Future<void> clearActiveConfig() async {}

  @override
  Future<bool> validateKey({
    required String providerName,
    required String apiKey,
  }) async => true;
}

class _MockCapabilityRepository implements ProviderCapabilityRepository {
  _MockCapabilityRepository({this.capability});

  final ProviderCapabilityViewData? capability;

  @override
  Future<ProviderCapabilityViewData?> getCapability({
    required String providerName,
    required String modelName,
  }) async => capability;

  @override
  Future<void> saveCapability(ProviderCapabilityViewData capability) async {}

  @override
  Future<void> clearCapability({
    required String providerName,
    required String modelName,
  }) async {}
}

class _MockNetworkStatus extends NetworkStatus {
  _MockNetworkStatus({required this.isOnline}) : super();

  @override
  final bool isOnline;

  @override
  Future<bool> check() async => isOnline;
}

ByokConfigViewData _config({
  String id = 'test-config',
  String providerName = 'openai',
  String? selectedModel = 'gpt-4o',
  bool hasKey = true,
}) {
  return ByokConfigViewData(
    id: id,
    providerName: providerName,
    displayName: 'OpenAI',
    selectedModel: selectedModel,
    hasKey: hasKey,
    isActive: true,
    lastValidationStatus: null,
    lastErrorCode: null,
  );
}

void main() {
  group('DefaultProviderGateService', () {
    final textCapability = ProviderCapabilityViewData(
      providerName: 'openai',
      modelName: 'gpt-4o',
      supportsTextInput: true,
      supportsImageInput: false,
      supportsJsonSchemaMode: false,
      supportsStreaming: true,
      maxContextTokens: null,
      maxOutputTokens: null,
      maxImagesPerRequest: null,
      checkedAt: DateTime.now(),
    );

    final imageCapability = ProviderCapabilityViewData(
      providerName: 'openai',
      modelName: 'gpt-4o',
      supportsTextInput: true,
      supportsImageInput: true,
      supportsJsonSchemaMode: true,
      supportsStreaming: true,
      maxContextTokens: null,
      maxOutputTokens: null,
      maxImagesPerRequest: null,
      checkedAt: DateTime.now(),
    );

    test('blocks when no active provider config exists', () async {
      final gate = DefaultProviderGateService(
        byokRepository: _MockByokRepository(activeConfig: null),
        capabilityRepository: _MockCapabilityRepository(),
        networkStatus: _MockNetworkStatus(isOnline: true),
      );

      final decision = await gate.evaluate(
        operation: ProviderOperationType.aiChat,
      );

      expect(decision.isAllowed, isFalse);
      expect(
        decision.reason,
        equals(ProviderGateFailureReason.missingProviderConfig),
      );
      expect(decision.message, equals(AppStrings.providerSetupRequired));
    });

    test('blocks when active config has no key', () async {
      final gate = DefaultProviderGateService(
        byokRepository: _MockByokRepository(
          activeConfig: _config(),
          hasKeyValue: false,
        ),
        capabilityRepository: _MockCapabilityRepository(),
        networkStatus: _MockNetworkStatus(isOnline: true),
      );

      final decision = await gate.evaluate(
        operation: ProviderOperationType.aiChat,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.reason, equals(ProviderGateFailureReason.missingKey));
      expect(decision.message, equals(AppStrings.providerKeyRequired));
    });

    test('blocks when offline', () async {
      final gate = DefaultProviderGateService(
        byokRepository: _MockByokRepository(activeConfig: _config()),
        capabilityRepository: _MockCapabilityRepository(),
        networkStatus: _MockNetworkStatus(isOnline: false),
      );

      final decision = await gate.evaluate(
        operation: ProviderOperationType.aiChat,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.reason, equals(ProviderGateFailureReason.offline));
      expect(decision.message, equals(AppStrings.providerOfflineBlocked));
    });

    test('blocks image operation when image capability missing', () async {
      final gate = DefaultProviderGateService(
        byokRepository: _MockByokRepository(activeConfig: _config()),
        capabilityRepository: _MockCapabilityRepository(
          capability: textCapability,
        ),
        networkStatus: _MockNetworkStatus(isOnline: true),
      );

      final decision = await gate.evaluate(
        operation: ProviderOperationType.imageImport,
      );

      expect(decision.isAllowed, isFalse);
      expect(
        decision.reason,
        equals(ProviderGateFailureReason.missingImageCapability),
      );
      expect(decision.message, equals(AppStrings.providerImageUnsupported));
    });

    test(
      'blocks structured save flow when JSON/schema capability missing',
      () async {
        final gate = DefaultProviderGateService(
          byokRepository: _MockByokRepository(activeConfig: _config()),
          capabilityRepository: _MockCapabilityRepository(
            capability: textCapability,
          ),
          networkStatus: _MockNetworkStatus(isOnline: true),
        );

        final decision = await gate.evaluate(
          operation: ProviderOperationType.structuredSaveFlow,
        );

        expect(decision.isAllowed, isFalse);
        expect(
          decision.reason,
          equals(ProviderGateFailureReason.missingJsonSchemaCapability),
        );
        expect(decision.message, equals(AppStrings.providerJsonUnsupported));
      },
    );

    test('allows text-only operation when text capability exists', () async {
      final gate = DefaultProviderGateService(
        byokRepository: _MockByokRepository(activeConfig: _config()),
        capabilityRepository: _MockCapabilityRepository(
          capability: textCapability,
        ),
        networkStatus: _MockNetworkStatus(isOnline: true),
      );

      final decision = await gate.evaluate(
        operation: ProviderOperationType.aiChat,
      );

      expect(decision.isAllowed, isTrue);
    });

    test('allows image operation when image capability exists', () async {
      final gate = DefaultProviderGateService(
        byokRepository: _MockByokRepository(activeConfig: _config()),
        capabilityRepository: _MockCapabilityRepository(
          capability: imageCapability,
        ),
        networkStatus: _MockNetworkStatus(isOnline: true),
      );

      final decision = await gate.evaluate(
        operation: ProviderOperationType.imageImport,
      );

      expect(decision.isAllowed, isTrue);
    });

    test('returns capabilityUnknown when capability cache missing', () async {
      final gate = DefaultProviderGateService(
        byokRepository: _MockByokRepository(activeConfig: _config()),
        capabilityRepository: _MockCapabilityRepository(capability: null),
        networkStatus: _MockNetworkStatus(isOnline: true),
      );

      final decision = await gate.evaluate(
        operation: ProviderOperationType.aiChat,
      );

      expect(decision.isAllowed, isFalse);
      expect(
        decision.reason,
        equals(ProviderGateFailureReason.capabilityUnknown),
      );
      expect(
        decision.message,
        equals(AppStrings.providerCapabilityUnavailable),
      );
    });

    test(
      'all block messages are safe AppStrings — no internal details leaked',
      () async {
        const safeMessages = [
          AppStrings.providerSetupRequired,
          AppStrings.providerKeyRequired,
          AppStrings.providerOfflineBlocked,
          AppStrings.providerCapabilityUnavailable,
          AppStrings.providerTextOnly,
          AppStrings.providerImageUnsupported,
          AppStrings.providerJsonUnsupported,
        ];

        final forbiddenPatterns = [
          RegExp(r'openai|anthropic|google', caseSensitive: false),
          RegExp(
            r'gpt|claude|gemini|o1|o1-mini|o1-mini|sonnet|haiku|opus',
            caseSensitive: false,
          ),
          RegExp(r'sk-[a-zA-Z0-9]+|api[-_]?key|secret', caseSensitive: false),
          RegExp(
            r'/etc/|/var/|C:\\|file://|\.db$|\.sqlite',
            caseSensitive: false,
          ),
          RegExp(r'exception|error|failure|stack|trace', caseSensitive: false),
          RegExp(
            r'provider_name|model_name|providerName|modelName',
            caseSensitive: false,
          ),
        ];

        // Evaluate every failure path to collect all messages
        final noConfigGate = DefaultProviderGateService(
          byokRepository: _MockByokRepository(activeConfig: null),
          capabilityRepository: _MockCapabilityRepository(),
          networkStatus: _MockNetworkStatus(isOnline: true),
        );
        final noKeyGate = DefaultProviderGateService(
          byokRepository: _MockByokRepository(
            activeConfig: _config(),
            hasKeyValue: false,
          ),
          capabilityRepository: _MockCapabilityRepository(),
          networkStatus: _MockNetworkStatus(isOnline: true),
        );
        final offlineGate = DefaultProviderGateService(
          byokRepository: _MockByokRepository(activeConfig: _config()),
          capabilityRepository: _MockCapabilityRepository(),
          networkStatus: _MockNetworkStatus(isOnline: false),
        );
        final missingCapGate = DefaultProviderGateService(
          byokRepository: _MockByokRepository(activeConfig: _config()),
          capabilityRepository: _MockCapabilityRepository(capability: null),
          networkStatus: _MockNetworkStatus(isOnline: true),
        );
        final textOnlyGate = DefaultProviderGateService(
          byokRepository: _MockByokRepository(activeConfig: _config()),
          capabilityRepository: _MockCapabilityRepository(
            capability: textCapability,
          ),
          networkStatus: _MockNetworkStatus(isOnline: true),
        );

        final decisions = await Future.wait([
          noConfigGate.evaluate(operation: ProviderOperationType.aiChat),
          noKeyGate.evaluate(operation: ProviderOperationType.aiChat),
          offlineGate.evaluate(operation: ProviderOperationType.aiChat),
          missingCapGate.evaluate(operation: ProviderOperationType.aiChat),
          textOnlyGate.evaluate(operation: ProviderOperationType.imageImport),
          textOnlyGate.evaluate(
            operation: ProviderOperationType.structuredSaveFlow,
          ),
        ]);

        for (final decision in decisions) {
          expect(decision.isAllowed, isFalse);
          expect(
            safeMessages,
            contains(decision.message),
            reason:
                'Message "${decision.message}" (reason: ${decision.reason}) '
                'is not a known safe AppStrings constant',
          );
          for (final pattern in forbiddenPatterns) {
            expect(
              decision.message,
              isNot(matches(pattern)),
              reason:
                  'Message "${decision.message}" (reason: ${decision.reason}) '
                  'contains forbidden pattern $pattern',
            );
          }
        }
      },
    );
  });
}
