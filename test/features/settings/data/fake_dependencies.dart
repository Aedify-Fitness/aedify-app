import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/ai_provider_config_dao.dart';
import 'package:aedify/core/storage/secure_storage_service.dart';
import 'package:drift/native.dart';

class FakeConfigDao extends AiProviderConfigDao {
  FakeConfigDao() : super(AppDatabase(NativeDatabase.memory()));

  final _store = <String, Map<String, dynamic>>{};

  @override
  Future<List<AiProviderConfig>> getAllConfigs() async {
    return _store.values.map(_rowFromMap).toList();
  }

  @override
  Future<AiProviderConfig?> getById(String id) async {
    final map = _store[id];
    return map != null ? _rowFromMap(map) : null;
  }

  @override
  Future<AiProviderConfig?> getActiveConfig() async {
    final match = _store.values.where((m) => m['isActive'] == true);
    return match.isNotEmpty ? _rowFromMap(match.first) : null;
  }

  @override
  Future<void> upsertConfig(AiProviderConfigsCompanion entry) async {
    _store[entry.id.value] = {
      'id': entry.id.value,
      'providerName': entry.providerName.value,
      'displayName': entry.displayName.present ? entry.displayName.value : null,
      'selectedModel': entry.selectedModel.present
          ? entry.selectedModel.value
          : null,
      'secureKeyAlias': entry.secureKeyAlias.present
          ? entry.secureKeyAlias.value
          : entry.id.value,
      'isActive': entry.isActive.present ? entry.isActive.value : false,
      'lastValidationStatus': entry.lastValidationStatus.present
          ? entry.lastValidationStatus.value
          : null,
      'lastErrorCode': entry.lastErrorCode.present
          ? entry.lastErrorCode.value
          : null,
      'createdAt': entry.createdAt.present
          ? entry.createdAt.value
          : DateTime.now(),
      'updatedAt': entry.updatedAt.present
          ? entry.updatedAt.value
          : DateTime.now(),
    };
  }

  @override
  Future<void> deleteConfig(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> setActiveConfig(String id) async {
    for (final key in _store.keys) {
      _store[key]!['isActive'] = key == id;
    }
  }

  @override
  Future<void> clearActiveConfig() async {
    for (final key in _store.keys) {
      _store[key]!['isActive'] = false;
    }
  }

  AiProviderConfig _rowFromMap(Map<String, dynamic> map) {
    return AiProviderConfig(
      id: map['id'] as String,
      providerName: map['providerName'] as String,
      displayName: map['displayName'] as String?,
      selectedModel: map['selectedModel'] as String?,
      secureKeyAlias: map['secureKeyAlias'] as String? ?? map['id'] as String,
      isActive: map['isActive'] as bool? ?? false,
      supportsTextInput: true,
      supportsImageInput: false,
      supportsJsonSchemaMode: false,
      supportsStreaming: false,
      supportsToolCalling: null,
      maxContextTokens: null,
      maxOutputTokens: null,
      maxImagesPerRequest: null,
      maxImageSizeBytes: null,
      lastValidatedAt: null,
      lastValidationStatus: map['lastValidationStatus'] as String?,
      lastErrorCode: map['lastErrorCode'] as String?,
      createdAt: map['createdAt'] as DateTime? ?? DateTime.now(),
      updatedAt: map['updatedAt'] as DateTime? ?? DateTime.now(),
    );
  }
}

class FakeSecureStorage extends SecureStorageService {
  FakeSecureStorage() : super();

  final _keys = <String, String>{};

  @override
  Future<void> saveProviderApiKey(String alias, String value) async {
    _keys[alias] = value;
  }

  @override
  Future<String?> readProviderApiKey(String alias) async {
    return _keys[alias];
  }

  @override
  Future<void> deleteProviderApiKey(String alias) async {
    _keys.remove(alias);
  }

  @override
  Future<void> rotateProviderApiKey(String alias, String newValue) async {
    _keys[alias] = newValue;
  }

  @override
  Future<bool> hasProviderApiKey(String alias) async {
    return _keys.containsKey(alias);
  }
}
