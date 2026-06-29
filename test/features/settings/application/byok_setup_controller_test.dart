import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/data/drift_byok_repository.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import '../../../support/privacy/privacy_sentinel_values.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../data/fake_dependencies.dart';

class _ValidatingFakeRepository extends DriftByokRepository {
  _ValidatingFakeRepository({
    required super.configDao,
    required super.secureStorageService,
    this.shouldThrowOnSave = false,
    this.shouldThrowOnRotate = false,
  });

  final bool shouldThrowOnSave;
  final bool shouldThrowOnRotate;

  @override
  Future<bool> validateKey({
    required AiProviderName providerName,
    required String apiKey,
  }) async {
    return true;
  }

  @override
  Future<String> saveConfig(ByokEditDraft draft) async {
    if (shouldThrowOnSave) throw Exception('db failure');
    return super.saveConfig(draft);
  }

  @override
  Future<void> rotateKey({
    required String configId,
    required AiProviderName providerName,
    required String newApiKey,
  }) async {
    if (shouldThrowOnRotate) throw Exception('rotate failure');
    return super.rotateKey(
      configId: configId,
      providerName: providerName,
      newApiKey: newApiKey,
    );
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FakeConfigDao configDao;
  late FakeSecureStorage secureStorage;
  late ByokRepository repository;

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        AppProviders.byokRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
  }

  setUp(() {
    configDao = FakeConfigDao();
    secureStorage = FakeSecureStorage();
    repository = _ValidatingFakeRepository(
      configDao: configDao,
      secureStorageService: secureStorage,
    );
  });

  group('ByokSetupController', () {
    test('initial build loads provider options and configs', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      final state = await controller.future;

      expect(state.isLoading, isFalse);
      expect(state.providerOptions.length, equals(3));
      expect(state.configs, isEmpty);
      expect(state.hasError, isFalse);
    });

    test('updateDraft updates state', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      controller.updateDraft(
        const ByokEditDraft(
          providerName: AiProviderName.openai,
          selectedModel: 'gpt-4o',
          apiKey: 'sk-test',
        ),
      );

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(state.editDraft, isNotNull);
      expect(state.editDraft!.providerName, equals(AiProviderName.openai));
      expect(state.editDraft!.apiKey, equals('sk-test'));
    });

    test('save validates key then persists configuration', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      controller.updateDraft(
        const ByokEditDraft(
          providerName: AiProviderName.openai,
          selectedModel: 'gpt-4o',
          apiKey: 'sk-valid',
        ),
      );

      await controller.save();

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(state.configs.length, equals(1));
      expect(state.configs.first.providerName, equals(AiProviderName.openai));
      expect(state.isSaving, isFalse);
      expect(state.isTesting, isFalse);
      expect(state.hasError, isFalse);
    });

    test('save surfaces validation error when key is empty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      controller.updateDraft(
        const ByokEditDraft(providerName: AiProviderName.openai, apiKey: ''),
      );

      await controller.save();

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(
        state.validationMessage,
        equals(AppErrorStrings.byokEmptyKeyValidation),
      );
    });

    test('deleteConfig removes config', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      controller.updateDraft(
        const ByokEditDraft(
          providerName: AiProviderName.openai,
          apiKey: 'sk-delete',
        ),
      );
      await controller.save();
      expect(
        container
            .read(AppProviders.byokSetupControllerProvider)
            .requireValue
            .configs
            .length,
        equals(1),
      );

      final configId = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue
          .configs
          .first
          .id;
      await controller.deleteConfig(configId);

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(state.configs, isEmpty);
    });

    test('setActiveConfig switches active config', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      controller.updateDraft(
        const ByokEditDraft(
          providerName: AiProviderName.openai,
          apiKey: 'sk-1',
        ),
      );
      await controller.save();

      controller.updateDraft(
        const ByokEditDraft(
          configId: null,
          providerName: AiProviderName.anthropic,
          apiKey: 'sk-2',
        ),
      );
      await controller.save();

      final configs = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue
          .configs;
      final anthropicConfig = configs.firstWhere(
        (c) => c.providerName == AiProviderName.anthropic,
      );
      await controller.setActiveConfig(anthropicConfig.id);

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      final active = state.configs.firstWhere((c) => c.isActive);
      expect(active.providerName, equals(AiProviderName.anthropic));
    });

    test('empty key validation does not echo secret input', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      controller.updateDraft(
        const ByokEditDraft(providerName: AiProviderName.openai, apiKey: ''),
      );
      await controller.save();

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(
        state.validationMessage,
        equals(AppErrorStrings.byokEmptyKeyValidation),
      );
      expect(state.validationMessage, isNotEmpty);
    });

    test('save failure surfaces safe error only', () async {
      final throwingRepository = _ValidatingFakeRepository(
        configDao: configDao,
        secureStorageService: secureStorage,
        shouldThrowOnSave: true,
      );
      final container = ProviderContainer(
        overrides: [
          AppProviders.byokRepositoryProvider.overrideWith(
            (ref) => throwingRepository,
          ),
        ],
      );
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      controller.updateDraft(
        ByokEditDraft(
          providerName: AiProviderName.openai,
          selectedModel: 'gpt-4o',
          apiKey: PrivacySentinelValues.fakeApiKey,
        ),
      );
      await controller.save();

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(state.hasError, isTrue);
      expect(state.errorMessage, isNot(contains('db failure')));
      expect(
        state.errorMessage,
        isNot(contains(PrivacySentinelValues.fakeApiKey)),
      );
      container.dispose();
    });

    test('rotate failure surfaces safe error only', () async {
      final throwingRepository = _ValidatingFakeRepository(
        configDao: configDao,
        secureStorageService: secureStorage,
        shouldThrowOnRotate: true,
      );
      final container = ProviderContainer(
        overrides: [
          AppProviders.byokRepositoryProvider.overrideWith(
            (ref) => throwingRepository,
          ),
        ],
      );
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      await controller.rotateKey(
        configId: 'nonexistent-id',
        providerName: AiProviderName.openai,
        newApiKey: PrivacySentinelValues.fakeApiKey,
      );

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(state.hasError, isTrue);
      expect(
        state.errorMessage,
        isNot(contains(PrivacySentinelValues.fakeApiKey)),
      );
      container.dispose();
    });

    test('reload refreshes state', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      controller.updateDraft(
        const ByokEditDraft(
          providerName: AiProviderName.openai,
          apiKey: 'sk-test',
        ),
      );
      await controller.save();
      expect(
        container
            .read(AppProviders.byokSetupControllerProvider)
            .requireValue
            .configs
            .length,
        equals(1),
      );

      await controller.reload();

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(state.isLoading, isFalse);
      expect(state.configs.length, equals(1));
      expect(state.editDraft, isNull);
    });
  });
}
