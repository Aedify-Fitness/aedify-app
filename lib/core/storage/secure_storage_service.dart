import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageFailure implements Exception {
  const SecureStorageFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'SecureStorageFailure($code): $message';
}

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyPrefix = 'ai_provider_api_key:';

  String _aliasKey(String alias) => '$_keyPrefix$alias';

  Future<T> _run<T>(String code, Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      throw SecureStorageFailure(
        code: code,
        message: 'Secure storage is unavailable.',
      );
    }
  }

  Future<void> saveProviderApiKey(String alias, String value) => _run(
    'secure_storage_write_failed',
    () => _storage.write(key: _aliasKey(alias), value: value),
  );

  Future<String?> readProviderApiKey(String alias) => _run(
    'secure_storage_read_failed',
    () => _storage.read(key: _aliasKey(alias)),
  );

  Future<void> deleteProviderApiKey(String alias) => _run(
    'secure_storage_delete_failed',
    () => _storage.delete(key: _aliasKey(alias)),
  );

  Future<void> rotateProviderApiKey(String alias, String newValue) async {
    await _run('secure_storage_rotate_failed', () async {
      final key = _aliasKey(alias);
      await _storage.delete(key: key);
      await _storage.write(key: key, value: newValue);
    });
  }

  Future<bool> hasProviderApiKey(String alias) async =>
      _run('secure_storage_contains_failed', () async {
        final value = await _storage.read(key: _aliasKey(alias));
        return value != null;
      });

  Future<void> deleteAll() =>
      _run('secure_storage_delete_all_failed', _storage.deleteAll);
}
