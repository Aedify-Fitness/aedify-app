import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyPrefix = 'ai_provider_api_key:';

  String _aliasKey(String alias) => '$_keyPrefix$alias';

  Future<void> saveProviderApiKey(String alias, String value) =>
      _storage.write(key: _aliasKey(alias), value: value);

  Future<String?> readProviderApiKey(String alias) =>
      _storage.read(key: _aliasKey(alias));

  Future<void> deleteProviderApiKey(String alias) =>
      _storage.delete(key: _aliasKey(alias));

  Future<void> rotateProviderApiKey(String alias, String newValue) async {
    final key = _aliasKey(alias);
    await _storage.delete(key: key);
    await _storage.write(key: key, value: newValue);
  }

  Future<bool> hasProviderApiKey(String alias) async {
    final value = await _storage.read(key: _aliasKey(alias));
    return value != null;
  }

  Future<void> deleteAll() => _storage.deleteAll();
}
