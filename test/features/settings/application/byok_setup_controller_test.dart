import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/data/drift_byok_repository.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../data/fake_dependencies.dart';

class _ValidatingFakeRepository extends DriftByokRepository {
  _ValidatingFakeRepository({
    required super.configDao,
    required super.secureStorageService,
  });

  @override
  Future<bool> validateKey({
    required String providerName,
    required String apiKey,
  }) async {
    return true;
  }
}

void main() {
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
          providerName: 'openai',
          selectedModel: 'gpt-4o',
          apiKey: 'sk-test',
        ),
      );

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(state.editDraft, isNotNull);
      expect(state.editDraft!.providerName, equals('openai'));
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
          providerName: 'openai',
          selectedModel: 'gpt-4o',
          apiKey: 'sk-valid',
        ),
      );

      await controller.save();

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      expect(state.configs.length, equals(1));
      expect(state.configs.first.providerName, equals('openai'));
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
        const ByokEditDraft(providerName: 'openai', apiKey: ''),
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
        const ByokEditDraft(providerName: 'openai', apiKey: 'sk-delete'),
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
        const ByokEditDraft(providerName: 'openai', apiKey: 'sk-1'),
      );
      await controller.save();

      controller.updateDraft(
        const ByokEditDraft(
          configId: null,
          providerName: 'anthropic',
          apiKey: 'sk-2',
        ),
      );
      await controller.save();

      final configs = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue
          .configs;
      final anthropicConfig = configs.firstWhere(
        (c) => c.providerName == 'anthropic',
      );
      await controller.setActiveConfig(anthropicConfig.id);

      final state = container
          .read(AppProviders.byokSetupControllerProvider)
          .requireValue;
      final active = state.configs.firstWhere((c) => c.isActive);
      expect(active.providerName, equals('anthropic'));
    });

    test('reload refreshes state', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.byokSetupControllerProvider.notifier,
      );
      await controller.future;

      controller.updateDraft(
        const ByokEditDraft(providerName: 'openai', apiKey: 'sk-test'),
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
