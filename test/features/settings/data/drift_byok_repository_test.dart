import 'package:aedify/features/settings/data/drift_byok_repository.dart';
import 'package:aedify/features/settings/domain/byok_config_view_data.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_model_option.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fake_dependencies.dart';

void main() {
  late FakeConfigDao configDao;
  late FakeSecureStorage secureStorage;
  late DriftByokRepository repository;

  setUp(() {
    configDao = FakeConfigDao();
    secureStorage = FakeSecureStorage();
    repository = DriftByokRepository(
      configDao: configDao,
      secureStorageService: secureStorage,
    );
  });

  test(
    'saveConfig persists metadata and stores key only in secure storage',
    () async {
      final configId = await repository.saveConfig(
        const ByokEditDraft(
          providerName: 'openai',
          selectedModel: 'gpt-4o',
          apiKey: 'sk-test-123',
          makeActive: true,
        ),
      );

      final configs = await repository.getConfigs();
      expect(configs.length, equals(1));
      expect(configs.first.providerName, equals('openai'));
      expect(configs.first.selectedModel, equals('gpt-4o'));
      expect(configs.first.hasKey, isTrue);

      final hasKey = await secureStorage.hasProviderApiKey(configId);
      expect(hasKey, isTrue);
    },
  );

  test('rotateKey replaces secure storage value', () async {
    final configId = await repository.saveConfig(
      const ByokEditDraft(providerName: 'openai', apiKey: 'sk-old-key'),
    );

    await repository.rotateKey(
      configId: configId,
      providerName: 'openai',
      newApiKey: 'sk-new-key',
    );

    final stored = await secureStorage.readProviderApiKey(configId);
    expect(stored, equals('sk-new-key'));
  });

  test('deleteConfig removes metadata and key', () async {
    final configId = await repository.saveConfig(
      const ByokEditDraft(providerName: 'openai', apiKey: 'sk-delete-test'),
    );

    await repository.deleteConfig(configId);

    final configs = await repository.getConfigs();
    expect(configs, isEmpty);

    final hasKey = await secureStorage.hasProviderApiKey(configId);
    expect(hasKey, isFalse);
  });

  test('setActiveConfig updates active config only', () async {
    await repository.saveConfig(
      const ByokEditDraft(
        providerName: 'openai',
        apiKey: 'sk-1',
        makeActive: true,
      ),
    );
    final configId2 = await repository.saveConfig(
      const ByokEditDraft(
        providerName: 'anthropic',
        apiKey: 'sk-2',
        makeActive: false,
      ),
    );

    await repository.setActiveConfig(configId2);

    final active = await repository.getActiveConfig();
    expect(active, isA<ByokConfigViewData>());
    expect(active!.providerName, equals('anthropic'));
  });

  test('getConfigs returns hasKey without exposing raw key', () async {
    await repository.saveConfig(
      const ByokEditDraft(providerName: 'openai', apiKey: 'sk-secret'),
    );

    final configs = await repository.getConfigs();
    expect(configs.first.hasKey, isTrue);
    expect(() => configs.first as dynamic..apiKey, throwsNoSuchMethodError);
  });

  test(
    'getProviderOptions returns 3 built-in options with models and pricing',
    () async {
      final options = await repository.getProviderOptions();
      expect(options.length, equals(3));
      expect(options[0].providerName, equals('openai'));
      expect(options[1].providerName, equals('anthropic'));
      expect(options[2].providerName, equals('google'));

      for (final option in options) {
        expect(option.models, isNotEmpty);
        expect(option.models, isA<List<ByokModelOption>>());
        expect(option.description, isNotEmpty);
        for (final model in option.models) {
          expect(model.id, isNotEmpty);
          expect(model.displayName, isNotEmpty);
          expect(model.inputCostPer1kTokens, greaterThanOrEqualTo(0));
          expect(model.outputCostPer1kTokens, greaterThanOrEqualTo(0));
        }
      }
    },
  );

  test('correct OpenAI models', () async {
    final options = await repository.getProviderOptions();
    final openAi = options.firstWhere((o) => o.providerName == 'openai');
    final modelIds = openAi.models.map((m) => m.id).toList();
    expect(modelIds, contains('gpt-4o'));
    expect(modelIds, contains('gpt-4o-mini'));
    expect(modelIds, contains('o1'));
    expect(modelIds, contains('o1-mini'));
    expect(modelIds, isNot(contains('gpt-4-turbo')));
    expect(modelIds, isNot(contains('gpt-3.5-turbo')));
  });

  test('correct Anthropic model display names', () async {
    final options = await repository.getProviderOptions();
    final anthropic = options.firstWhere((o) => o.providerName == 'anthropic');
    final displayNames = anthropic.models.map((m) => m.displayName).toList();
    expect(displayNames, contains('Claude Sonnet 4.6'));
    expect(displayNames, contains('Claude Haiku 4.5'));
    expect(displayNames, contains('Claude Opus 4.7'));
  });

  test('correct Google models', () async {
    final options = await repository.getProviderOptions();
    final google = options.firstWhere((o) => o.providerName == 'google');
    final modelIds = google.models.map((m) => m.id).toList();
    expect(modelIds, contains('gemini-2.5-pro'));
    expect(modelIds, contains('gemini-2.5-flash'));
  });
}
