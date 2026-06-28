import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/ai_model_capability_dao.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AiModelCapabilityDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = AiModelCapabilityDao(db);
  });

  tearDown(() {
    db.close();
  });

  test('getCapability returns null initially', () async {
    final result = await dao.getCapability(
      providerName: 'openai',
      modelName: 'gpt-4o',
    );
    expect(result, isNull);
  });

  test('upsertCapability saves capability', () async {
    final now = DateTime.now();
    await dao.upsertCapability(
      AiModelCapabilitiesCompanion(
        id: const Value('openai_gpt-4o'),
        providerName: const Value('openai'),
        modelName: const Value('gpt-4o'),
        supportsTextInput: const Value(true),
        supportsImageInput: const Value(true),
        supportsJsonSchemaMode: const Value(true),
        supportsStreaming: const Value(true),
        maxContextTokens: const Value(128000),
        maxOutputTokens: const Value(4096),
        maxImagesPerRequest: const Value(10),
        checkedAt: Value(now),
      ),
    );

    final saved = await dao.getCapability(
      providerName: 'openai',
      modelName: 'gpt-4o',
    );
    expect(saved, isNotNull);
    expect(saved!.providerName, equals('openai'));
    expect(saved.modelName, equals('gpt-4o'));
    expect(saved.supportsTextInput, isTrue);
    expect(saved.supportsImageInput, isTrue);
    expect(saved.supportsJsonSchemaMode, isTrue);
    expect(saved.supportsStreaming, isTrue);
    expect(saved.maxContextTokens, equals(128000));
    expect(saved.maxOutputTokens, equals(4096));
    expect(saved.maxImagesPerRequest, equals(10));
  });

  test('getCapability returns saved capability', () async {
    final now = DateTime.now();
    await dao.upsertCapability(
      AiModelCapabilitiesCompanion(
        id: const Value('anthropic_claude-sonnet-4-20250514'),
        providerName: const Value('anthropic'),
        modelName: const Value('claude-sonnet-4-20250514'),
        supportsTextInput: const Value(true),
        supportsImageInput: const Value(false),
        supportsJsonSchemaMode: const Value(false),
        supportsStreaming: const Value(true),
        checkedAt: Value(now),
      ),
    );

    final result = await dao.getCapability(
      providerName: 'anthropic',
      modelName: 'claude-sonnet-4-20250514',
    );
    expect(result, isNotNull);
    expect(result!.supportsTextInput, isTrue);
    expect(result.supportsImageInput, isFalse);
    expect(result.supportsJsonSchemaMode, isFalse);
  });

  test('deleteCapability removes capability', () async {
    final now = DateTime.now();
    await dao.upsertCapability(
      AiModelCapabilitiesCompanion(
        id: const Value('openai_gpt-4o'),
        providerName: const Value('openai'),
        modelName: const Value('gpt-4o'),
        supportsTextInput: const Value(true),
        supportsImageInput: const Value(false),
        supportsJsonSchemaMode: const Value(false),
        supportsStreaming: const Value(true),
        checkedAt: Value(now),
      ),
    );

    await dao.deleteCapability(providerName: 'openai', modelName: 'gpt-4o');

    final result = await dao.getCapability(
      providerName: 'openai',
      modelName: 'gpt-4o',
    );
    expect(result, isNull);
  });
}
