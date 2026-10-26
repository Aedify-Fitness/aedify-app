import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/settings/data/drift_byok_repository.dart';
import 'package:aedify/features/settings/data/drift_provider_capability_repository.dart';
import 'package:aedify/core/db/daos/ai_model_capability_dao.dart';
import 'package:aedify/core/db/daos/ai_provider_config_dao.dart';
import 'package:aedify/features/settings/data/provider_key_validator.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/settings/provider_metadata_adapter.dart';
import 'fake_dependencies.dart';

class _FailingCapabilityRepository extends DriftProviderCapabilityRepository {
  _FailingCapabilityRepository(AiModelCapabilityDao superDao)
    : super(capabilityDao: superDao);
  @override
  Future<void> saveCapability(ProviderCapabilityViewData capability) async {
    await super.saveCapability(capability);
    throw StateError('synthetic storage failure');
  }
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late ProviderMetadataAdapter adapter;
  late FakeSecureStorage secure;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    secure = FakeSecureStorage();
    adapter = ProviderMetadataAdapter();
    container = ProviderContainer(
      overrides: [
        AppProviders.appDatabaseProvider.overrideWithValue(db),
        AppProviders.secureStorageProvider.overrideWithValue(secure),
        AppProviders.providerKeyValidatorProvider.overrideWithValue(
          ProviderKeyValidator(dio: adapter.client()),
        ),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  const draft = ByokEditDraft(
    providerName: AiProviderName.openai,
    selectedModel: 'gpt-4o',
    apiKey: 'synthetic-private-key',
  );

  test(
    'saving checks the selected model and persists only safe capability metadata',
    () async {
      final id = await container
          .read(AppProviders.byokRepositoryProvider)
          .saveConfig(draft);
      final row = (await db.select(db.aiProviderConfigs).get()).single;
      expect(row.id, id);
      expect(row.lastValidationStatus, 'valid');
      expect(row.lastValidatedAt, isNotNull);
      expect(await secure.readProviderApiKey(id), draft.apiKey);
      final capabilities = await db.select(db.aiModelCapabilities).get();
      expect(capabilities.single.supportsImageInput, isTrue);
      final persisted = [
        (await db.customSelect('SELECT * FROM ai_provider_configs').get())
            .single
            .data,
        (await db.customSelect('SELECT * FROM ai_model_capabilities').get())
            .single
            .data,
      ].toString();
      expect(persisted, isNot(contains(draft.apiKey!)));
      expect(adapter.requests.single.uri.path, '/v1/models/gpt-4o');
    },
  );

  test('invalid replacement keeps old key, metadata and activation', () async {
    final repository = container.read(AppProviders.byokRepositoryProvider);
    final id = await repository.saveConfig(draft);
    final before = (await db.select(db.aiProviderConfigs).get()).single;
    adapter.status = 401;
    await expectLater(
      repository.rotateKey(
        configId: id,
        providerName: AiProviderName.openai,
        newApiKey: 'synthetic-invalid-key',
      ),
      throwsA(isA<ProviderValidationFailure>()),
    );
    expect(await secure.readProviderApiKey(id), draft.apiKey);
    final after = (await db.select(db.aiProviderConfigs).get()).single;
    expect(after, before);
  });

  test(
    'editing the model reuses a stored key without clearing activation or creation time',
    () async {
      final repository = container.read(AppProviders.byokRepositoryProvider);
      final id = await repository.saveConfig(draft);
      final before = (await db.select(db.aiProviderConfigs).get()).single;
      await repository.saveConfig(
        ByokEditDraft(
          configId: id,
          providerName: AiProviderName.openai,
          selectedModel: 'gpt-4o-mini',
          makeActive: false,
        ),
      );
      final after = (await db.select(db.aiProviderConfigs).get()).single;
      expect(after.createdAt, before.createdAt);
      expect(after.isActive, isTrue);
      expect(after.selectedModel, 'gpt-4o-mini');
      expect(await secure.readProviderApiKey(id), draft.apiKey);
    },
  );

  test(
    'capability write failure rolls back metadata and restores the prior secure key',
    () async {
      final repository = container.read(AppProviders.byokRepositoryProvider);
      final id = await repository.saveConfig(draft);
      final before = (await db.select(db.aiProviderConfigs).get()).single;
      final failing = DriftByokRepository(
        configDao: AiProviderConfigDao(db),
        secureStorageService: secure,
        keyValidator: ProviderKeyValidator(dio: adapter.client()),
        capabilityRepository: _FailingCapabilityRepository(
          AiModelCapabilityDao(db),
        ),
      );
      await expectLater(
        failing.rotateKey(
          configId: id,
          providerName: AiProviderName.openai,
          newApiKey: 'synthetic-new-key',
        ),
        throwsStateError,
      );
      expect(await secure.readProviderApiKey(id), draft.apiKey);
      expect((await db.select(db.aiProviderConfigs).get()).single, before);
    },
  );

  test(
    'new-config failure removes its secure alias and does not leave partial rows',
    () async {
      final failing = DriftByokRepository(
        configDao: AiProviderConfigDao(db),
        secureStorageService: secure,
        keyValidator: ProviderKeyValidator(dio: adapter.client()),
        capabilityRepository: _FailingCapabilityRepository(
          AiModelCapabilityDao(db),
        ),
      );
      await expectLater(failing.saveConfig(draft), throwsStateError);
      expect(await db.select(db.aiProviderConfigs).get(), isEmpty);
      expect(await db.select(db.aiModelCapabilities).get(), isEmpty);
      expect(secure.keysForTest, isEmpty);
    },
  );

  test(
    'deletion while checking a replacement key cannot recreate the configuration',
    () async {
      final repository = container.read(AppProviders.byokRepositoryProvider);
      final id = await repository.saveConfig(draft);
      adapter.beforeResponse = () => repository.deleteConfig(id);
      await expectLater(
        repository.rotateKey(
          configId: id,
          providerName: AiProviderName.openai,
          newApiKey: 'synthetic-new-key',
        ),
        throwsA(isA<ProviderValidationFailure>()),
      );
      expect(await db.select(db.aiProviderConfigs).get(), isEmpty);
      expect(await secure.readProviderApiKey(id), isNull);
    },
  );

  test('stale failed refresh cannot invalidate a newly rotated key', () async {
    final repository = container.read(AppProviders.byokRepositoryProvider);
    final id = await repository.saveConfig(draft);
    adapter.beforeResponse = () async {
      adapter.beforeResponse = null;
      await repository.rotateKey(
        configId: id,
        providerName: AiProviderName.openai,
        newApiKey: 'synthetic-new-key',
      );
      adapter.status = 401;
    };
    await expectLater(
      container
          .read(AppProviders.providerCapabilityRefreshServiceProvider)
          .refresh(providerName: AiProviderName.openai, modelName: 'gpt-4o'),
      throwsA(isA<ProviderValidationFailure>()),
    );
    expect(
      (await db.select(db.aiProviderConfigs).get()).single.lastValidationStatus,
      'valid',
    );
    expect(await db.select(db.aiModelCapabilities).get(), hasLength(1));
    expect(await secure.readProviderApiKey(id), 'synthetic-new-key');
  });

  test(
    'failed refresh invalidates cached access while transport failures preserve it',
    () async {
      final repository = container.read(AppProviders.byokRepositoryProvider);
      final id = await repository.saveConfig(draft);
      final refresh = container.read(
        AppProviders.providerCapabilityRefreshServiceProvider,
      );
      adapter.failTransport = true;
      await expectLater(
        refresh.refresh(
          providerName: AiProviderName.openai,
          modelName: 'gpt-4o',
        ),
        throwsA(isA<ProviderValidationFailure>()),
      );
      expect(await db.select(db.aiModelCapabilities).get(), hasLength(1));
      adapter.failTransport = false;
      adapter.status = 401;
      await expectLater(
        refresh.refresh(
          providerName: AiProviderName.openai,
          modelName: 'gpt-4o',
        ),
        throwsA(isA<ProviderValidationFailure>()),
      );
      expect(await db.select(db.aiModelCapabilities).get(), isEmpty);
      expect(
        (await container
                .read(AppProviders.aiProviderConfigDaoProvider)
                .getById(id))!
            .lastValidationStatus,
        'invalid',
      );
    },
  );
}
