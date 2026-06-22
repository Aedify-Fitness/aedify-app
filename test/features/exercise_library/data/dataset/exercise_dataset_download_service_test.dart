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

import '../../../../support/exercise_library/exercise_library_fixture_loader.dart';
import '../../../../support/exercise_library/exercise_library_fixture_manifest_builder.dart';

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
    test('succeeds with valid manifest fixture', () async {
      final manifestJson = await ExerciseLibraryFixtureLoader.loadRawString(
        'manifest_valid.json',
      );
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        manifestJson,
      );

      final manifest = await service.fetchManifest();

      expect(manifest.schemaVersion, 1);
      expect(manifest.datasetVersion, '2026-06-22-v1');
      expect(manifest.exerciseCount, 350);
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
      final manifestJson = await ExerciseLibraryFixtureLoader.loadRawString(
        'manifest_invalid_shape.json',
      );
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        manifestJson,
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
      final manifestJson = _buildManifestFromBuilder(
        activeSha256: _sha256Of(activeContent),
        activeSizeBytes: activeContent.length,
      );
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        manifestJson,
      );
      fakeStorage.downloadToFileCallback = (remotePath, localPath) async {
        await File(localPath).writeAsString(activeContent);
      };

      final result = await service.downloadActiveDataset();

      expect(result.manifest.datasetVersion, '2026-06-22-v1');
      expect(result.sizeBytes, activeContent.length);
      expect(result.localRelativePath, contains('exercise_dataset'));
      expect(result.localAbsolutePath, isNotEmpty);
      expect(result.downloadedAt, isNotNull);
    });

    test('throws unsupportedAppSchema when app schema too low', () async {
      final manifestJson = await ExerciseLibraryFixtureLoader.loadRawString(
        'manifest_future_schema_required.json',
      );
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        manifestJson,
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
      final manifestJson = _buildManifestFromBuilder(
        activeSha256: _sha256Of(activeContent),
      );
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        manifestJson,
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
      final manifestJson = _buildManifestFromBuilder(
        activeSha256: 'wrong_checksum',
        activeSizeBytes: activeContent.length,
      );
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        manifestJson,
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
    test('returns true when app schema meets minimum', () async {
      final manifestJson = await ExerciseLibraryFixtureLoader.loadRawString(
        'manifest_valid.json',
      );
      fakeStorage.setTextResponse(
        'datasets/exercises/manifest.json',
        manifestJson,
      );

      final manifest = await service.fetchManifest();
      expect(service.hasCompatibleMinimumAppSchema(manifest), isTrue);
    });

    test('returns false when app schema below minimum', () async {
      final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
        'manifest_future_schema_required.json',
      );
      final json = _decodeJson(rawJson);
      final manifest = ExerciseDatasetManifest.fromJson(json);
      expect(service.hasCompatibleMinimumAppSchema(manifest), isFalse);
    });
  });
}

// --- Helpers ---

String _buildManifestFromBuilder({
  int minSchema = 1,
  String activeSha256 = 'abc123',
  int activeSizeBytes = 50000,
}) {
  final builder = ExerciseLibraryFixtureManifestBuilder()
      .withMinimumSupportedAppSchemaVersion(minSchema)
      .withSha256(activeSha256)
      .withSizeBytes(activeSizeBytes);
  final jsonMap = builder.build();
  return json.encode(jsonMap);
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
