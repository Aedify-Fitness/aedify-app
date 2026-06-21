import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:aedify/core/firebase/firebase_auth_service.dart';
import 'package:aedify/core/firebase/firebase_storage_client.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_failure.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_result.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_manifest.dart';
import 'package:aedify/shared/constants/db_constants.dart';

class ExerciseDatasetDownloadService {
  ExerciseDatasetDownloadService({
    required FirebaseAuthService authService,
    required FirebaseStorageClient storageClient,
    required LocalFileStore fileStore,
    required AppLogger logger,
  }) : _authService = authService,
       _storageClient = storageClient,
       _fileStore = fileStore,
       _logger = logger;

  final FirebaseAuthService _authService;
  final FirebaseStorageClient _storageClient;
  final LocalFileStore _fileStore;
  final AppLogger _logger;

  static const String manifestRemotePath = 'datasets/exercises/manifest.json';

  Future<ExerciseDatasetManifest> fetchManifest() async {
    try {
      await _authService.ensureAnonymousSignIn();
    } on FirebaseAuthFailure catch (e) {
      _logger.error('Manifest fetch failed: auth error', error: e);
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.authFailed,
        message: e.message,
        retryable: true,
      );
    }

    late String rawJson;
    try {
      rawJson = await _storageClient.getText(manifestRemotePath);
    } on FirebaseStorageFailure catch (e) {
      _logger.error('Manifest fetch failed: storage error', error: e);
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.manifestFetchFailed,
        message: e.message,
        retryable: true,
      );
    }

    final json = _decodeJsonObject(rawJson);
    _validateManifestTransportShape(json);

    try {
      return ExerciseDatasetManifest.fromJson(json);
    } on FormatException catch (e) {
      _logger.error('Manifest parse failed', error: e);
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.invalidManifest,
        message: e.message,
        retryable: false,
      );
    }
  }

  Future<ExerciseDatasetDownloadResult> downloadActiveDataset() async {
    final manifest = await fetchManifest();

    final compatible = hasCompatibleMinimumAppSchema(manifest);
    if (!compatible) {
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.unsupportedAppSchema,
        message:
            'App schema ${DbConstants.supportedExerciseDatasetSchemaVersion} '
            'is below minimum required ${manifest.active.minimumSupportedAppSchemaVersion}',
        retryable: false,
      );
    }

    final tempDir = await _fileStore.exerciseDatasetTempDir();
    final tempFile = File('${tempDir.path}/${manifest.datasetVersion}.json');

    try {
      await _storageClient.downloadToFile(
        remotePath: manifest.active.path,
        localPath: tempFile.path,
      );
    } on FirebaseStorageFailure catch (e) {
      _logger.error('Dataset download failed', error: e);
      await _cleanupFile(tempFile);
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.datasetDownloadFailed,
        message: e.message,
        retryable: true,
      );
    } on IOException catch (e) {
      _logger.error('Dataset download IO error', error: e);
      await _cleanupFile(tempFile);
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.interruptedDownload,
        message: e.toString(),
        retryable: true,
      );
    }

    await _verifyDownloadedFile(file: tempFile, active: manifest.active);

    final relativePath = await _fileStore.toRelativePath(tempFile.path);

    return ExerciseDatasetDownloadResult(
      manifest: manifest,
      localRelativePath: relativePath,
      localAbsolutePath: tempFile.path,
      downloadedAt: DateTime.now(),
      sizeBytes: manifest.active.sizeBytes,
    );
  }

  bool hasCompatibleMinimumAppSchema(ExerciseDatasetManifest manifest) {
    return DbConstants.supportedExerciseDatasetSchemaVersion >=
        manifest.active.minimumSupportedAppSchemaVersion;
  }

  Map<String, Object?> _decodeJsonObject(String rawJson) {
    try {
      final decoded = json.decode(rawJson);
      if (decoded is! Map<String, Object?>) {
        throw const ExerciseDatasetDownloadFailure(
          code: ExerciseDatasetDownloadFailureCode.invalidManifest,
          message: 'Manifest root must be a JSON object',
          retryable: false,
        );
      }
      return decoded;
    } on FormatException catch (e) {
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.invalidManifest,
        message: 'Invalid JSON: ${e.message}',
        retryable: false,
      );
    }
  }

  void _validateManifestTransportShape(Map<String, Object?> json) {
    if (!json.containsKey('schema_version')) {
      throw const ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.invalidManifest,
        message: 'Missing required top-level field: schema_version',
        retryable: false,
      );
    }
    if (!json.containsKey('active')) {
      throw const ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.invalidManifest,
        message: 'Missing required top-level field: active',
        retryable: false,
      );
    }
  }

  Future<void> _verifyDownloadedFile({
    required File file,
    required ExerciseDatasetActiveFile active,
  }) async {
    if (!await file.exists()) {
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.interruptedDownload,
        message: 'Downloaded file does not exist',
        retryable: true,
      );
    }

    final actualSize = await file.length();
    if (actualSize != active.sizeBytes) {
      await _cleanupFile(file);
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.sizeMismatch,
        message: 'Expected ${active.sizeBytes} bytes, got $actualSize',
        retryable: true,
      );
    }

    final actualSha256 = await _computeSha256(file);
    if (actualSha256 != active.sha256) {
      await _cleanupFile(file);
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.checksumMismatch,
        message:
            'SHA-256 mismatch: expected ${active.sha256}, got $actualSha256',
        retryable: true,
      );
    }
  }

  Future<String> _computeSha256(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  Future<void> _cleanupFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort cleanup
    }
  }
}
