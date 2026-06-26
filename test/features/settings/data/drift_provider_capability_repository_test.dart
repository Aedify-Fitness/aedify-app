import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/ai_model_capability_dao.dart';
import 'package:aedify/features/settings/data/drift_provider_capability_repository.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderCapabilityRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftProviderCapabilityRepository(
      capabilityDao: AiModelCapabilityDao(db),
    );
  });

  tearDown(() {
    db.close();
  });

  test('saveCapability persists capability metadata', () async {
    final now = DateTime.now();
    await repository.saveCapability(
      ProviderCapabilityViewData(
        providerName: 'openai',
        modelName: 'gpt-4o',
        supportsTextInput: true,
        supportsImageInput: false,
        supportsJsonSchemaMode: true,
        supportsStreaming: true,
        maxContextTokens: 128000,
        maxOutputTokens: 4096,
        maxImagesPerRequest: null,
        checkedAt: now,
      ),
    );

    final saved = await repository.getCapability(
      providerName: 'openai',
      modelName: 'gpt-4o',
    );
    expect(saved, isNotNull);
    expect(saved!.providerName, equals('openai'));
    expect(saved.modelName, equals('gpt-4o'));
    expect(saved.supportsTextInput, isTrue);
    expect(saved.supportsJsonSchemaMode, isTrue);
    expect(saved.maxContextTokens, equals(128000));
  });

  test('getCapability returns mapped view data', () async {
    final now = DateTime.now();
    await repository.saveCapability(
      ProviderCapabilityViewData(
        providerName: 'anthropic',
        modelName: 'claude-sonnet-4-20250514',
        supportsTextInput: true,
        supportsImageInput: true,
        supportsJsonSchemaMode: false,
        supportsStreaming: true,
        maxContextTokens: null,
        maxOutputTokens: null,
        maxImagesPerRequest: 5,
        checkedAt: now,
      ),
    );

    final result = await repository.getCapability(
      providerName: 'anthropic',
      modelName: 'claude-sonnet-4-20250514',
    );
    expect(result, isNotNull);
    expect(result!.providerName, equals('anthropic'));
    expect(result.supportsTextInput, isTrue);
    expect(result.supportsImageInput, isTrue);
    expect(result.supportsJsonSchemaMode, isFalse);
    expect(result.supportsStreaming, isTrue);
    expect(result.maxImagesPerRequest, equals(5));
  });

  test('clearCapability removes cached capability', () async {
    final now = DateTime.now();
    await repository.saveCapability(
      ProviderCapabilityViewData(
        providerName: 'openai',
        modelName: 'gpt-4o',
        supportsTextInput: true,
        supportsImageInput: false,
        supportsJsonSchemaMode: false,
        supportsStreaming: true,
        maxContextTokens: null,
        maxOutputTokens: null,
        maxImagesPerRequest: null,
        checkedAt: now,
      ),
    );

    await repository.clearCapability(
      providerName: 'openai',
      modelName: 'gpt-4o',
    );

    final result = await repository.getCapability(
      providerName: 'openai',
      modelName: 'gpt-4o',
    );
    expect(result, isNull);
  });
}
