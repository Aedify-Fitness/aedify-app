import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:aedify/core/firebase/firebase_auth_service.dart';
import 'package:aedify/core/firebase/firebase_storage_client.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_failure.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_service.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuthService fakeAuth;
  late FakeStorageClient fakeStorage;
  late LocalFileStore fileStore;
  late AppLogger logger;
  late ExerciseDatasetDownloadService service;

  setUp(() async {
    fakeAuth = FakeAuthService();
    fakeStorage = FakeStorageClient();
    final tempDir = await Directory.systemTemp.createTemp('ds_test_');
    fileStore = LocalFileStore(basePath: tempDir.path);
    logger = AppLogger();
    service = ExerciseDatasetDownloadService(
      authService: fakeAuth,
      storageClient: fakeStorage,
      fileStore: fileStore,
      logger: logger,
    );
  });

  group('fetchManifest', () {
    test('succeeds with valid manifest', () async {
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        _validManifestJson(),
      );

      final manifest = await service.fetchManifest();

      expect(manifest.schemaVersion, 1);
      expect(manifest.datasetVersion, '2024-01-01');
      expect(manifest.exerciseCount, 100);
    });

    test('throws authFailed when auth fails', () async {
      fakeAuth.shouldThrow = true;

      expect(
        () => service.fetchManifest(),
        throwsA(
          isA<ExerciseDatasetDownloadFailure>().having(
            (f) => f.code,
            'code',
            ExerciseDatasetDownloadFailureCode.authFailed,
          ),
        ),
      );
    });

    test('throws manifestFetchFailed when storage fails', () async {
      fakeStorage.shouldThrowOnGetText = true;

      expect(
        () => service.fetchManifest(),
        throwsA(
          isA<ExerciseDatasetDownloadFailure>().having(
            (f) => f.code,
            'code',
            ExerciseDatasetDownloadFailureCode.manifestFetchFailed,
          ),
        ),
      );
    });

    test('throws invalidManifest for non-JSON response', () async {
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        'not json',
      );

      expect(
        () => service.fetchManifest(),
        throwsA(
          isA<ExerciseDatasetDownloadFailure>().having(
            (f) => f.code,
            'code',
            ExerciseDatasetDownloadFailureCode.invalidManifest,
          ),
        ),
      );
    });

    test('throws invalidManifest for JSON array', () async {
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        '[1, 2, 3]',
      );

      expect(
        () => service.fetchManifest(),
        throwsA(
          isA<ExerciseDatasetDownloadFailure>().having(
            (f) => f.code,
            'code',
            ExerciseDatasetDownloadFailureCode.invalidManifest,
          ),
        ),
      );
    });

    test('throws invalidManifest when schema_version missing', () async {
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        '{"active": {"path": "x","content_type": "x","size_bytes": 1,"sha256": "x","schema_version": 1,"minimum_supported_app_schema_version": 1}}',
      );

      expect(
        () => service.fetchManifest(),
        throwsA(
          isA<ExerciseDatasetDownloadFailure>().having(
            (f) => f.code,
            'code',
            ExerciseDatasetDownloadFailureCode.invalidManifest,
          ),
        ),
      );
    });
  });

  group('downloadActiveDataset', () {
    test('succeeds and returns download result', () async {
      final activeContent = '{"exercises":[]}';
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        _validManifestJson(
          activeSha256: _sha256Of(activeContent),
          activeSizeBytes: activeContent.length,
        ),
      );
      fakeStorage.downloadToFileCallback = (remotePath, localPath) async {
        await File(localPath).writeAsString(activeContent);
      };

      final result = await service.downloadActiveDataset();

      expect(result.manifest.datasetVersion, '2024-01-01');
      expect(result.sizeBytes, activeContent.length);
      expect(result.localRelativePath, contains('exercise_dataset'));
      expect(result.localAbsolutePath, isNotEmpty);
      expect(result.downloadedAt, isNotNull);
    });

    test('throws unsupportedAppSchema when app schema too low', () async {
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        _validManifestJson(minSchema: 999),
      );

      expect(
        () => service.downloadActiveDataset(),
        throwsA(
          isA<ExerciseDatasetDownloadFailure>().having(
            (f) => f.code,
            'code',
            ExerciseDatasetDownloadFailureCode.unsupportedAppSchema,
          ),
        ),
      );
    });

    test('throws sizeMismatch when file size differs', () async {
      final activeContent = '{"exercises":[]}';
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        _validManifestJson(activeSha256: _sha256Of(activeContent)),
      );
      fakeStorage.downloadToFileCallback = (remotePath, localPath) async {
        await File(localPath).writeAsString(activeContent);
      };

      expect(
        () => service.downloadActiveDataset(),
        throwsA(
          isA<ExerciseDatasetDownloadFailure>().having(
            (f) => f.code,
            'code',
            ExerciseDatasetDownloadFailureCode.sizeMismatch,
          ),
        ),
      );
    });

    test('throws checksumMismatch when sha256 differs', () async {
      final activeContent = '{"exercises":[]}';
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        _validManifestJson(
          activeSha256: 'wrong_checksum',
          activeSizeBytes: activeContent.length,
        ),
      );
      fakeStorage.downloadToFileCallback = (remotePath, localPath) async {
        await File(localPath).writeAsString(activeContent);
      };

      expect(
        () => service.downloadActiveDataset(),
        throwsA(
          isA<ExerciseDatasetDownloadFailure>().having(
            (f) => f.code,
            'code',
            ExerciseDatasetDownloadFailureCode.checksumMismatch,
          ),
        ),
      );
    });
  });

  group('hasCompatibleMinimumAppSchema', () {
    test(
      'returns true when app schema meets minimum (schema 1 >= min 1)',
      () async {
        fakeStorage.setTextResponse(
          'datasets/exercises/manifest.json',
          _validManifestJson(minSchema: 1),
        );

        final manifest = await service.fetchManifest();
        expect(service.hasCompatibleMinimumAppSchema(manifest), isTrue);
      },
    );

    test(
      'returns false when app schema below minimum (schema 1 < min 2)',
      () async {
        final rawJson = _validManifestJson(minSchema: 2);
        final json = _decodeJson(rawJson);
        final manifest = ExerciseDatasetManifest.fromJson(json);
        expect(service.hasCompatibleMinimumAppSchema(manifest), isFalse);
      },
    );
  });
}

// --- Helpers ---

String _validManifestJson({
  int minSchema = 1,
  String activeSha256 = 'abc123',
  int activeSizeBytes = 50000,
}) {
  return '''
{
  "schema_version": 1,
  "manifest_version": 1,
  "dataset_version": "2024-01-01",
  "generated_at": "2024-01-01T00:00:00.000Z",
  "source": "musclewiki",
  "exercise_count": 100,
  "active": {
    "path": "datasets/exercises/v1/exercises.json",
    "content_type": "application/json",
    "size_bytes": $activeSizeBytes,
    "sha256": "$activeSha256",
    "schema_version": 1,
    "minimum_supported_app_schema_version": $minSchema
  },
  "history": []
}
''';
}

Map<String, Object?> _decodeJson(String rawJson) {
  return Map<String, Object?>.from(jsonDecode(rawJson) as Map);
}

String _sha256Of(String content) {
  final bytes = utf8.encode(content);
  return sha256.convert(bytes).toString();
}

// --- Fakes ---

class FakeAuthService implements FirebaseAuthService {
  bool shouldThrow = false;

  @override
  Future<void> ensureAnonymousSignIn() async {
    if (shouldThrow) {
      throw FirebaseAuthFailure(code: 'auth_error', message: 'Auth failed');
    }
  }
}

class FakeStorageClient implements FirebaseStorageClient {
  final _textResponses = <String, String>{};
  bool shouldThrowOnGetText = false;
  Future<void> Function(String remotePath, String localPath)?
  downloadToFileCallback;

  void setTextResponse(String path, String content) {
    _textResponses[path] = content;
  }

  @override
  Future<String> getText(String remotePath) async {
    if (shouldThrowOnGetText) {
      throw FirebaseStorageFailure(
        code: 'storage_error',
        message: 'Storage failed',
      );
    }
    return _textResponses[remotePath] ??
        (throw FirebaseStorageFailure(
          code: 'not_found',
          message: 'Path not found: $remotePath',
        ));
  }

  @override
  Future<void> downloadToFile({
    required String remotePath,
    required String localPath,
  }) async {
    if (downloadToFileCallback != null) {
      await downloadToFileCallback!(remotePath, localPath);
    } else {
      throw FirebaseStorageFailure(
        code: 'not_found',
        message: 'No callback configured for $remotePath',
      );
    }
  }
}
