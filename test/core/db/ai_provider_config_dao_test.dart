import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/ai_provider_config_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AiProviderConfigDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = AiProviderConfigDao(db);
  });

  tearDown(() {
    db.close();
  });

  test('upsertConfig saves config', () async {
    await dao.upsertConfig(
      AiProviderConfigsCompanion(
        id: const Value('test-1'),
        providerName: const Value('openai'),
        secureKeyAlias: const Value('test-1'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final configs = await dao.getAllConfigs();
    expect(configs.length, equals(1));
    expect(configs.first.id, equals('test-1'));
    expect(configs.first.providerName, equals('openai'));
  });

  test('getAllConfigs returns saved configs', () async {
    await dao.upsertConfig(
      AiProviderConfigsCompanion(
        id: const Value('a'),
        providerName: const Value('openai'),
        secureKeyAlias: const Value('a'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await dao.upsertConfig(
      AiProviderConfigsCompanion(
        id: const Value('b'),
        providerName: const Value('anthropic'),
        secureKeyAlias: const Value('b'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final configs = await dao.getAllConfigs();
    expect(configs.length, equals(2));
  });

  test('getActiveConfig returns active config', () async {
    await dao.upsertConfig(
      AiProviderConfigsCompanion(
        id: const Value('active-1'),
        providerName: const Value('openai'),
        secureKeyAlias: const Value('active-1'),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final active = await dao.getActiveConfig();
    expect(active, isA<AiProviderConfig>());
    expect(active!.id, equals('active-1'));
  });

  test('setActiveConfig switches active config', () async {
    await dao.upsertConfig(
      AiProviderConfigsCompanion(
        id: const Value('c1'),
        providerName: const Value('openai'),
        secureKeyAlias: const Value('c1'),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await dao.upsertConfig(
      AiProviderConfigsCompanion(
        id: const Value('c2'),
        providerName: const Value('anthropic'),
        secureKeyAlias: const Value('c2'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await dao.setActiveConfig('c2');
    final active = await dao.getActiveConfig();
    expect(active, isA<AiProviderConfig>());
    expect(active!.id, equals('c2'));

    final c1 = await dao.getById('c1');
    expect(c1!.isActive, isFalse);
  });

  test('deleteConfig removes config', () async {
    await dao.upsertConfig(
      AiProviderConfigsCompanion(
        id: const Value('delete-me'),
        providerName: const Value('openai'),
        secureKeyAlias: const Value('delete-me'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await dao.deleteConfig('delete-me');
    final configs = await dao.getAllConfigs();
    expect(configs, isEmpty);
  });

  test('updateValidationState updates status fields', () async {
    await dao.upsertConfig(
      AiProviderConfigsCompanion(
        id: const Value('validate-me'),
        providerName: const Value('openai'),
        secureKeyAlias: const Value('validate-me'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final now = DateTime.now();
    await dao.updateValidationState(
      id: 'validate-me',
      validatedAt: now,
      validationStatus: 'valid',
      errorCode: null,
    );
    final updated = await dao.getById('validate-me');
    expect(updated!.lastValidationStatus, equals('valid'));
    expect(updated.lastValidatedAt, isA<DateTime>());
  });
}
