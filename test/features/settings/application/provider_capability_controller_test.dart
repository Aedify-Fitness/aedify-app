import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/data/provider_key_validator.dart';
import 'package:drift/native.dart';
import '../../../support/settings/provider_metadata_adapter.dart';
import '../data/fake_dependencies.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import '../../../support/privacy/privacy_sentinel_values.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockCapabilityRepository implements ProviderCapabilityRepository {
  _MockCapabilityRepository({this.capability, this.shouldThrow = false});

  final ProviderCapabilityViewData? capability;
  final bool shouldThrow;

  @override
  Future<ProviderCapabilityViewData?> getCapability({
    required AiProviderName providerName,
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
    required AiProviderName providerName,
    required String modelName,
  }) async {}
}

void main() {
  group('ProviderCapabilityController', () {
    test('initial build loads cached capability', () async {
      final capability = ProviderCapabilityViewData(
        providerName: AiProviderName.openai,
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
          providerName: AiProviderName.openai,
          modelName: 'gpt-4o',
        )).notifier,
      );

      final state = await controller.future;

      expect(state.isLoading, isFalse);
      expect(state.capability, isNotNull);
      expect(state.capability!.providerName, equals(AiProviderName.openai));
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
          providerName: AiProviderName.openai,
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
          providerName: AiProviderName.openai,
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
        providerName: AiProviderName.openai,
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
          providerName: AiProviderName.openai,
          modelName: 'gpt-4o',
        )).notifier,
      );

      final state = await controller.future;

      expect(state.capability, isNotNull);
      expect(state.capability!.providerName, equals(AiProviderName.openai));
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

    test(
      'reload checks selected model over HTTP and populates the cache',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        final transport = ProviderMetadataAdapter();
        final container = ProviderContainer(
          overrides: [
            AppProviders.appDatabaseProvider.overrideWithValue(db),
            AppProviders.secureStorageProvider.overrideWithValue(
              FakeSecureStorage(),
            ),
            AppProviders.providerKeyValidatorProvider.overrideWithValue(
              ProviderKeyValidator(dio: transport.client()),
            ),
          ],
        );
        addTearDown(() async {
          container.dispose();
          await db.close();
        });
        await container
            .read(AppProviders.byokRepositoryProvider)
            .saveConfig(
              const ByokEditDraft(
                providerName: AiProviderName.openai,
                selectedModel: 'gpt-4o',
                apiKey: 'synthetic-key',
              ),
            );
        await container
            .read(AppProviders.providerCapabilityRepositoryProvider)
            .clearCapability(
              providerName: AiProviderName.openai,
              modelName: 'gpt-4o',
            );
        final controller = container.read(
          AppProviders.providerCapabilityControllerProvider((
            providerName: AiProviderName.openai,
            modelName: 'gpt-4o',
          )).notifier,
        );
        expect((await controller.future).capability, isNull);
        await controller.reload();
        expect(
          (await controller.future).capability!.supportsJsonSchemaMode,
          isTrue,
        );
        expect(transport.requests.length, 2);
        expect(transport.requests.last.uri.path, '/v1/models/gpt-4o');
        expect(
          await container
              .read(AppProviders.providerCapabilityRepositoryProvider)
              .getCapability(
                providerName: AiProviderName.openai,
                modelName: 'gpt-4o',
              ),
          isNotNull,
        );
      },
    );
  });
}
