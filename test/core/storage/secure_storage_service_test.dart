import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aedify/core/storage/secure_storage_service.dart';

class _FakeFlutterSecureStorage extends FlutterSecureStorage {
  final _store = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    if (value != null) {
      _store[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async => _store[key];

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async => _store.remove(key);

  @override
  Future<void> deleteAll({
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async => _store.clear();
}

class _ThrowingFlutterSecureStorage extends FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    throw Exception('secret should not leak: $value');
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    throw Exception('secret should not leak');
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    throw Exception('delete failure');
  }

  @override
  Future<void> deleteAll({
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    throw Exception('delete all failure');
  }
}

void main() {
  group('SecureStorageService', () {
    late _FakeFlutterSecureStorage fakeStorage;
    late SecureStorageService service;

    setUp(() {
      fakeStorage = _FakeFlutterSecureStorage();
      service = SecureStorageService(storage: fakeStorage);
    });

    test('saveProviderApiKey and readProviderApiKey round-trip', () async {
      await service.saveProviderApiKey('openai', 'sk-test-123');
      final value = await service.readProviderApiKey('openai');
      expect(value, equals('sk-test-123'));
    });

    test('readProviderApiKey returns null for missing alias', () async {
      final value = await service.readProviderApiKey('nonexistent');
      expect(value, isNull);
    });

    test('hasProviderApiKey returns true when key exists', () async {
      await service.saveProviderApiKey('anthropic', 'sk-ant-test');
      expect(await service.hasProviderApiKey('anthropic'), isTrue);
    });

    test('hasProviderApiKey returns false when key does not exist', () async {
      expect(await service.hasProviderApiKey('missing'), isFalse);
    });

    test('deleteProviderApiKey removes key', () async {
      await service.saveProviderApiKey('openai', 'to-delete');
      await service.deleteProviderApiKey('openai');
      expect(await service.hasProviderApiKey('openai'), isFalse);
    });

    test('rotateProviderApiKey replaces key', () async {
      await service.saveProviderApiKey('openai', 'old-key');
      await service.rotateProviderApiKey('openai', 'new-key');
      final value = await service.readProviderApiKey('openai');
      expect(value, equals('new-key'));
    });

    test('deleteAll removes all keys', () async {
      await service.saveProviderApiKey('openai', 'sk-1');
      await service.saveProviderApiKey('anthropic', 'sk-2');
      await service.deleteAll();
      expect(await service.hasProviderApiKey('openai'), isFalse);
      expect(await service.hasProviderApiKey('anthropic'), isFalse);
    });

    test('different aliases are isolated', () async {
      await service.saveProviderApiKey('openai', 'sk-openai');
      await service.saveProviderApiKey('anthropic', 'sk-anthropic');
      expect(await service.readProviderApiKey('openai'), equals('sk-openai'));
      expect(
        await service.readProviderApiKey('anthropic'),
        equals('sk-anthropic'),
      );
    });

    test('write failure throws sanitized SecureStorageFailure', () async {
      service = SecureStorageService(storage: _ThrowingFlutterSecureStorage());

      await expectLater(
        () => service.saveProviderApiKey('openai', 'sk-secret-1234'),
        throwsA(
          isA<SecureStorageFailure>()
              .having((e) => e.code, 'code', 'secure_storage_write_failed')
              .having(
                (e) => e.message,
                'message',
                isNot(contains('sk-secret-1234')),
              ),
        ),
      );
    });

    test('read failure throws sanitized SecureStorageFailure', () async {
      service = SecureStorageService(storage: _ThrowingFlutterSecureStorage());

      await expectLater(
        () => service.readProviderApiKey('openai'),
        throwsA(
          isA<SecureStorageFailure>()
              .having((e) => e.code, 'code', 'secure_storage_read_failed'),
        ),
      );
    });
  });
}
