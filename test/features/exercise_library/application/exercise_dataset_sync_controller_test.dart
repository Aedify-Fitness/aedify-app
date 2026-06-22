import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/exercise_video_dao.dart';
import 'package:aedify/core/db/daos/library_meta_dao.dart';
import 'package:aedify/core/db/enums/library_sync_status.dart';
import 'package:aedify/core/firebase/firebase_auth_service.dart';
import 'package:aedify/core/firebase/firebase_storage_client.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_failure.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_result.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_service.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_manifest.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _StubAuthService implements FirebaseAuthService {
  @override
  Future<void> ensureAnonymousSignIn() async {}
}

class _StubStorageClient implements FirebaseStorageClient {
  @override
  Future<String> getText(String remotePath) async => '';

  @override
  Future<void> downloadToFile({
    required String remotePath,
    required String localPath,
  }) async {}
}

class _FakeNetworkStatus extends NetworkStatus {
  _FakeNetworkStatus({required this.online});

  bool online;

  @override
  bool get isOnline => online;

  @override
  Future<bool> check() async => online;
}

final _activeFile = ExerciseDatasetActiveFile(
  path: 'datasets/exercises/v1.json',
  contentType: 'application/json',
  sizeBytes: 100,
  sha256: 'abc123',
  schemaVersion: 1,
  minimumSupportedAppSchemaVersion: 1,
);

final _manifest = ExerciseDatasetManifest(
  schemaVersion: 1,
  manifestVersion: 1,
  datasetVersion: 'v1',
  generatedAt: DateTime(2026, 6, 22),
  source: 'test',
  exerciseCount: 10,
  active: _activeFile,
  history: [],
);

final _result = ExerciseDatasetDownloadResult(
  manifest: _manifest,
  localRelativePath: 'temp/exercise_dataset/dataset.json',
  localAbsolutePath: '/nonexistent/dataset.json',
  downloadedAt: DateTime(2026, 6, 22),
  sizeBytes: 100,
);

class _ControllableDownloadService extends ExerciseDatasetDownloadService {
  _ControllableDownloadService()
    : super(
        authService: _StubAuthService(),
        storageClient: _StubStorageClient(),
        fileStore: LocalFileStore(basePath: '/tmp'),
        logger: AppLogger(),
      );

  bool shouldThrowOnManifest = false;
  bool shouldThrowOnDownload = false;
  bool throwUnsupportedAppSchema = false;
  ExerciseDatasetDownloadFailureCode failureCode =
      ExerciseDatasetDownloadFailureCode.datasetDownloadFailed;
  String failureMessage = '';
  bool failureRetryable = true;
  ExerciseDatasetManifest? manifestOverride;
  ExerciseDatasetDownloadResult? resultOverride;

  @override
  Future<ExerciseDatasetManifest> fetchManifest() async {
    if (shouldThrowOnManifest) {
      throw ExerciseDatasetDownloadFailure(
        code: failureCode,
        message: failureMessage,
        retryable: failureRetryable,
      );
    }
    return manifestOverride ?? _manifest;
  }

  @override
  Future<ExerciseDatasetDownloadResult> downloadActiveDataset() async {
    if (throwUnsupportedAppSchema) {
      throw ExerciseDatasetDownloadFailure(
        code: ExerciseDatasetDownloadFailureCode.unsupportedAppSchema,
        message: 'App schema too old',
        retryable: failureRetryable,
      );
    }
    if (shouldThrowOnDownload) {
      throw ExerciseDatasetDownloadFailure(
        code: failureCode,
        message: failureMessage,
        retryable: failureRetryable,
      );
    }
    return resultOverride ?? _result;
  }
}

ProviderContainer createContainer({
  AppDatabase? database,
  NetworkStatus? networkStatus,
  ExerciseDatasetDownloadService? downloadService,
}) {
  final db = database ?? AppDatabase(NativeDatabase.memory());
  final ns = networkStatus ?? _FakeNetworkStatus(online: true);
  final ds = downloadService ?? _ControllableDownloadService();

  return ProviderContainer(
    overrides: [
      AppProviders.appDatabaseProvider.overrideWithValue(db),
      AppProviders.networkStatusProvider.overrideWithValue(ns),
      AppProviders.exerciseDatasetDownloadServiceProvider.overrideWithValue(ds),
      AppProviders.exerciseDaoProvider.overrideWithValue(ExerciseDao(db)),
      AppProviders.exerciseVideoDaoProvider.overrideWithValue(
        ExerciseVideoDao(db),
      ),
      AppProviders.libraryMetaDaoProvider.overrideWithValue(LibraryMetaDao(db)),
    ],
  );
}

void main() {
  group('ExerciseDatasetSyncController', () {
    late AppDatabase db;
    late LibraryMetaDao dao;
    late _FakeNetworkStatus networkStatus;
    late _ControllableDownloadService downloadService;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = LibraryMetaDao(db);
      networkStatus = _FakeNetworkStatus(online: true);
      downloadService = _ControllableDownloadService();
    });

    tearDown(() async {
      await db.close();
    });

    Future<ExerciseDatasetSyncState> readState(ProviderContainer container) {
      return container.read(
        AppProviders.exerciseDatasetSyncControllerProvider.future,
      );
    }

    test('initial state is never synced when no local meta exists', () async {
      final container = createContainer(
        database: db,
        networkStatus: networkStatus,
        downloadService: downloadService,
      );

      final state = await readState(container);
      expect(state.phase, ExerciseDatasetSyncPhase.neverSynced);
      expect(state.needsInitialSync, isTrue);
      expect(state.isSynced, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test(
      'initial state is synced when local meta exists with synced status',
      () async {
        await dao.upsertLibraryMeta(
          LibraryMetaCompanion(
            id: const Value('exercise_library'),
            source: const Value('test'),
            schemaVersion: const Value(1),
            libraryVersion: const Value('v1'),
            syncStatus: Value(LibrarySyncStatus.synced.value),
            exerciseCount: const Value(10),
            downloadedAt: Value(DateTime(2026, 6, 22)),
            createdAt: Value(DateTime(2026, 6, 22)),
            updatedAt: Value(DateTime(2026, 6, 22)),
          ),
        );

        final container = createContainer(
          database: db,
          networkStatus: networkStatus,
          downloadService: downloadService,
        );

        final state = await readState(container);
        expect(state.phase, ExerciseDatasetSyncPhase.synced);
        expect(state.isSynced, isTrue);
        expect(state.libraryVersion, 'v1');
      },
    );

    test(
      'initial state is failed when local meta exists with failed status',
      () async {
        await dao.upsertLibraryMeta(
          LibraryMetaCompanion(
            id: const Value('exercise_library'),
            source: const Value('test'),
            schemaVersion: const Value(1),
            libraryVersion: const Value('v1'),
            syncStatus: Value(LibrarySyncStatus.failed.value),
            exerciseCount: const Value(10),
            downloadedAt: Value(DateTime(2026, 6, 22)),
            createdAt: Value(DateTime(2026, 6, 22)),
            updatedAt: Value(DateTime(2026, 6, 22)),
          ),
        );

        final container = createContainer(
          database: db,
          networkStatus: networkStatus,
          downloadService: downloadService,
        );

        final state = await readState(container);
        expect(state.phase, ExerciseDatasetSyncPhase.failed);
        expect(state.hasFailure, isFalse);
        expect(state.isSynced, isFalse);
      },
    );

    test('offline with no local dataset becomes unavailableOffline', () async {
      networkStatus.online = false;

      final container = createContainer(
        database: db,
        networkStatus: networkStatus,
        downloadService: downloadService,
      );

      await container
          .read(AppProviders.exerciseDatasetSyncControllerProvider.notifier)
          .initialize();

      final state = container
          .read(AppProviders.exerciseDatasetSyncControllerProvider)
          .requireValue;
      expect(state.phase, ExerciseDatasetSyncPhase.unavailableOffline);
      expect(state.isOffline, isTrue);
    });

    test('offline with existing local dataset stays synced', () async {
      await dao.upsertLibraryMeta(
        LibraryMetaCompanion(
          id: const Value('exercise_library'),
          source: const Value('test'),
          schemaVersion: const Value(1),
          libraryVersion: const Value('v1'),
          syncStatus: Value(LibrarySyncStatus.synced.value),
          exerciseCount: const Value(10),
          downloadedAt: Value(DateTime(2026, 6, 22)),
          createdAt: Value(DateTime(2026, 6, 22)),
          updatedAt: Value(DateTime(2026, 6, 22)),
        ),
      );

      networkStatus.online = false;

      final container = createContainer(
        database: db,
        networkStatus: networkStatus,
        downloadService: downloadService,
      );

      await container
          .read(AppProviders.exerciseDatasetSyncControllerProvider.notifier)
          .refresh();

      final state = container
          .read(AppProviders.exerciseDatasetSyncControllerProvider)
          .requireValue;
      expect(state.phase, ExerciseDatasetSyncPhase.synced);
      expect(state.isOffline, isTrue);
      expect(state.libraryVersion, 'v1');
    });

    test('unsupported minimum app schema becomes updateRequired', () async {
      downloadService.throwUnsupportedAppSchema = true;

      final container = createContainer(
        database: db,
        networkStatus: networkStatus,
        downloadService: downloadService,
      );

      await container
          .read(AppProviders.exerciseDatasetSyncControllerProvider.notifier)
          .initialize();

      final state = container
          .read(AppProviders.exerciseDatasetSyncControllerProvider)
          .requireValue;
      expect(state.phase, ExerciseDatasetSyncPhase.updateRequired);
      expect(state.hasFailure, isTrue);
    });

    test('download failure becomes failed with retryable error', () async {
      downloadService.shouldThrowOnDownload = true;
      downloadService.failureCode =
          ExerciseDatasetDownloadFailureCode.datasetDownloadFailed;
      downloadService.failureMessage = 'Network error';
      downloadService.failureRetryable = true;

      final container = createContainer(
        database: db,
        networkStatus: networkStatus,
        downloadService: downloadService,
      );

      await container
          .read(AppProviders.exerciseDatasetSyncControllerProvider.notifier)
          .initialize();

      final state = container
          .read(AppProviders.exerciseDatasetSyncControllerProvider)
          .requireValue;
      expect(state.phase, ExerciseDatasetSyncPhase.failed);
      expect(state.hasFailure, isTrue);
      expect(state.failure!.retryable, isTrue);
      expect(state.failure!.code, 'datasetDownloadFailed');
    });

    test('non-retryable failure stays in failed state', () async {
      downloadService.shouldThrowOnDownload = true;
      downloadService.failureCode =
          ExerciseDatasetDownloadFailureCode.invalidManifest;
      downloadService.failureMessage = 'Invalid manifest';
      downloadService.failureRetryable = false;

      final container = createContainer(
        database: db,
        networkStatus: networkStatus,
        downloadService: downloadService,
      );

      await container
          .read(AppProviders.exerciseDatasetSyncControllerProvider.notifier)
          .initialize();

      final state = container
          .read(AppProviders.exerciseDatasetSyncControllerProvider)
          .requireValue;
      expect(state.phase, ExerciseDatasetSyncPhase.failed);
      expect(state.failure!.retryable, isFalse);
    });

    test('clearFailure resets to synced and clears db error', () async {
      await dao.upsertLibraryMeta(
        LibraryMetaCompanion(
          id: const Value('exercise_library'),
          source: const Value('test'),
          schemaVersion: const Value(1),
          libraryVersion: const Value('v1'),
          syncStatus: Value(LibrarySyncStatus.failed.value),
          lastSyncErrorCode: const Value('some_error'),
          lastSyncErrorMessage: const Value('some message'),
          exerciseCount: const Value(10),
          downloadedAt: Value(DateTime(2026, 6, 22)),
          createdAt: Value(DateTime(2026, 6, 22)),
          updatedAt: Value(DateTime(2026, 6, 22)),
        ),
      );

      final container = createContainer(
        database: db,
        networkStatus: networkStatus,
        downloadService: downloadService,
      );

      await container
          .read(AppProviders.exerciseDatasetSyncControllerProvider.notifier)
          .clearFailure();

      final state = container
          .read(AppProviders.exerciseDatasetSyncControllerProvider)
          .requireValue;
      expect(state.phase, ExerciseDatasetSyncPhase.synced);
      expect(state.hasFailure, isFalse);

      final meta = await dao.getLibraryMeta();
      expect(meta!.lastSyncErrorCode, isNull);
      expect(meta.lastSyncErrorMessage, isNull);
    });

    test(
      'download succeeds with missing file triggers catch-all error',
      () async {
        final container = createContainer(
          database: db,
          networkStatus: networkStatus,
          downloadService: downloadService,
        );

        await container
            .read(AppProviders.exerciseDatasetSyncControllerProvider.notifier)
            .initialize();

        final state = container
            .read(AppProviders.exerciseDatasetSyncControllerProvider)
            .requireValue;
        expect(state.phase, ExerciseDatasetSyncPhase.failed);
        expect(state.hasFailure, isTrue);
        expect(state.failure!.code, 'unknown');
        expect(state.failure!.retryable, isTrue);
      },
    );
  });
}
