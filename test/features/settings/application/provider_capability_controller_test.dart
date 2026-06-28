import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import '../../../support/privacy/privacy_sentinel_values.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockCapabilityRepository implements ProviderCapabilityRepository {
  _MockCapabilityRepository({this.capability, this.shouldThrow = false});

  final ProviderCapabilityViewData? capability;
  final bool shouldThrow;

  @override
  Future<ProviderCapabilityViewData?> getCapability({
    required String providerName,
    required String modelName,
  }) async {
    if (shouldThrow) {
      throw Exception('Database error');
    }
    return capability;
  }

  @override
  Future<void> saveCapability(ProviderCapabilityViewData capability) async {}

  @override
  Future<void> clearCapability({
    required String providerName,
    required String modelName,
  }) async {}
}

void main() {
  group('ProviderCapabilityController', () {
    test('initial build loads cached capability', () async {
      final capability = ProviderCapabilityViewData(
        providerName: 'openai',
        modelName: 'gpt-4o',
        supportsTextInput: true,
        supportsImageInput: false,
        supportsJsonSchemaMode: true,
        supportsStreaming: true,
        maxContextTokens: 128000,
        maxOutputTokens: null,
        maxImagesPerRequest: null,
        checkedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          AppProviders.providerCapabilityRepositoryProvider.overrideWith(
            (ref) => _MockCapabilityRepository(capability: capability),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.providerCapabilityControllerProvider((
          providerName: 'openai',
          modelName: 'gpt-4o',
        )).notifier,
      );

      final state = await controller.future;

      expect(state.isLoading, isFalse);
      expect(state.capability, isNotNull);
      expect(state.capability!.providerName, equals('openai'));
      expect(state.capability!.modelName, equals('gpt-4o'));
      expect(state.capability!.supportsTextInput, isTrue);
      expect(state.capability!.supportsJsonSchemaMode, isTrue);
      expect(state.capability!.maxContextTokens, equals(128000));
      expect(state.hasError, isFalse);
    });

    test('build surfaces error when repository fails', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.providerCapabilityRepositoryProvider.overrideWith(
            (ref) => _MockCapabilityRepository(shouldThrow: true),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.providerCapabilityControllerProvider((
          providerName: 'openai',
          modelName: 'gpt-4o',
        )).notifier,
      );

      final state = await controller.future;

      expect(state.isLoading, isFalse);
      expect(state.capability, isNull);
      expect(state.hasError, isTrue);
      expect(state.errorCode, equals('capability_load_failed'));
    });

    test('capability load failure exposes safe error code only', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.providerCapabilityRepositoryProvider.overrideWith(
            (ref) => _MockCapabilityRepository(shouldThrow: true),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.providerCapabilityControllerProvider((
          providerName: 'openai',
          modelName: 'gpt-4o',
        )).notifier,
      );

      final state = await controller.future;

      expect(state.hasError, isTrue);
      expect(state.errorCode, equals('capability_load_failed'));
      expect(state.errorCode, isNot(contains('Database')));
      expect(
        state.errorCode,
        isNot(contains(PrivacySentinelValues.fakeApiKey)),
      );
    });

    test('capability state does not expose provider secrets', () async {
      final capability = ProviderCapabilityViewData(
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

      final container = ProviderContainer(
        overrides: [
          AppProviders.providerCapabilityRepositoryProvider.overrideWith(
            (ref) => _MockCapabilityRepository(capability: capability),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.providerCapabilityControllerProvider((
          providerName: 'openai',
          modelName: 'gpt-4o',
        )).notifier,
      );

      final state = await controller.future;

      expect(state.capability, isNotNull);
      expect(state.capability!.providerName, equals('openai'));
      expect(state.capability!.supportsTextInput, isTrue);
      expect(state.capability!.maxContextTokens, isNull);
      expect(
        state.capability!.providerName,
        isNot(contains(PrivacySentinelValues.fakeApiKey)),
      );
      expect(
        state.capability!.modelName,
        isNot(contains(PrivacySentinelValues.fakeApiKey)),
      );
    });

    test('reload refreshes capability state', () async {
      final initial = _MockCapabilityRepository(
        capability: ProviderCapabilityViewData(
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
        ),
      );

      final container = ProviderContainer(
        overrides: [
          AppProviders.providerCapabilityRepositoryProvider.overrideWith(
            (ref) => initial,
          ),
        ],
      );

      final controller = container.read(
        AppProviders.providerCapabilityControllerProvider((
          providerName: 'openai',
          modelName: 'gpt-4o',
        )).notifier,
      );

      // Verify initial state
      var state = await controller.future;
      expect(state.capability, isNotNull);
      expect(state.capability!.supportsJsonSchemaMode, isFalse);

      await controller.reload();

      state = await controller.future;
      expect(state.capability, isNotNull);
    });
  });
}
