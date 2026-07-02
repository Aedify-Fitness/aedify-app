import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/enums/library_sync_status.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_failure.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_parser.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';

class ExerciseDatasetSyncController
    extends AsyncNotifier<ExerciseDatasetSyncState> {
  static final _logger = AppLogger(name: 'ExerciseDatasetSyncController');

  @override
  Future<ExerciseDatasetSyncState> build() async {
    final dao = ref.read(AppProviders.libraryMetaDaoProvider);
    final meta = await dao.getLibraryMeta();
    if (meta == null) {
      return const ExerciseDatasetSyncState.neverSynced();
    }
    final status = LibrarySyncStatus.fromValue(meta.syncStatus);
    return ExerciseDatasetSyncState(
      phase: _phaseForStatus(status),
      libraryVersion: meta.libraryVersion,
      schemaVersion: meta.schemaVersion,
      exerciseCount: meta.exerciseCount,
      isOffline: !ref.read(AppProviders.networkStatusProvider).isOnline,
    );
  }

  ExerciseDatasetSyncPhase _phaseForStatus(LibrarySyncStatus status) {
    switch (status) {
      case LibrarySyncStatus.synced:
        return ExerciseDatasetSyncPhase.synced;
      case LibrarySyncStatus.failed:
        return ExerciseDatasetSyncPhase.failed;
      case LibrarySyncStatus.syncing:
      case LibrarySyncStatus.neverSynced:
        return ExerciseDatasetSyncPhase.neverSynced;
    }
  }

  Future<void> initialize() async {
    final buildResult = await future;
    if (buildResult.isSynced) return;
    await _runSync();
  }

  Future<void> retry() async {
    state = AsyncLoading();
    await _runSync();
  }

  Future<void> refresh() async {
    final current = await future;
    if (current.isOffline) return;
    await _runSync();
  }

  Future<void> clearFailure() async {
    final dao = ref.read(AppProviders.libraryMetaDaoProvider);
    final current = await future;
    if (current.isSynced) return;
    await dao.setSyncStatus(syncStatus: LibrarySyncStatus.synced);
    state = AsyncData(
      current.copyWith(
        phase: ExerciseDatasetSyncPhase.synced,
        clearFailure: true,
      ),
    );
  }

  Future<void> _runSync() async {
    _logger.info('_runSync — start');
    final dao = ref.read(AppProviders.libraryMetaDaoProvider);
    final networkStatus = ref.read(AppProviders.networkStatusProvider);
    final downloadService = ref.read(
      AppProviders.exerciseDatasetDownloadServiceProvider,
    );
    final parser = const ExerciseDatasetParser();
    final importer = ref.read(AppProviders.exerciseLibraryImporterProvider);

    final isOnline = await networkStatus.check();
    if (!isOnline) {
      _logger.info('_runSync — offline, checking local meta');
      final meta = await dao.getLibraryMeta();
      if (meta == null) {
        state = AsyncData(
          const ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.unavailableOffline,
            isOffline: true,
          ),
        );
        return;
      }
      state = AsyncData(
        ExerciseDatasetSyncState(
          phase: ExerciseDatasetSyncPhase.synced,
          libraryVersion: meta.libraryVersion,
          schemaVersion: meta.schemaVersion,
          exerciseCount: meta.exerciseCount,
          isOffline: true,
        ),
      );
      return;
    }

    try {
      state = AsyncData(
        const ExerciseDatasetSyncState(
          phase: ExerciseDatasetSyncPhase.checkingManifest,
        ),
      );
      _logger.info('_runSync — phase: checkingManifest');
      await dao.setSyncStatus(syncStatus: LibrarySyncStatus.syncing);

      final manifest = await downloadService.fetchManifest();
      final meta = await dao.getLibraryMeta();

      // Short-circuit if the local dataset version matches the manifest version
      if (meta != null && meta.libraryVersion == manifest.datasetVersion) {
        _logger.info(
          '_runSync — local version matches manifest, skipping download',
        );
        final version = meta.libraryVersion ?? '';
        await dao.updateManifestMetadata(
          libraryVersion: version,
          schemaVersion: meta.schemaVersion,
          exerciseCount: meta.exerciseCount,
          downloadedAt: meta.downloadedAt ?? DateTime.now(),
          manifestLastUpdatedAt: DateTime.now(),
        );
        await dao.setSyncStatus(syncStatus: LibrarySyncStatus.synced);
        state = AsyncData(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.synced,
            manifest: manifest,
            libraryVersion: meta.libraryVersion,
            schemaVersion: meta.schemaVersion,
            exerciseCount: meta.exerciseCount,
          ),
        );
        return;
      }

      final downloadResult = await downloadService.downloadActiveDataset();

      state = AsyncData(
        ExerciseDatasetSyncState(
          phase: ExerciseDatasetSyncPhase.importing,
          manifest: downloadResult.manifest,
        ),
      );
      _logger.info('_runSync — phase: importing');

      final rawFile = File(downloadResult.localAbsolutePath);
      final rawJson = await rawFile.readAsString();

      final dataset = parser.parse(
        rawJson: rawJson,
        supportedSchemaVersion: 1,
        minimumSupportedAppSchemaVersion:
            downloadResult.manifest.active.minimumSupportedAppSchemaVersion,
      );

      final importResult = await importer.importDataset(
        dataset: dataset,
        manifest: downloadResult.manifest,
        downloadedAt: downloadResult.downloadedAt,
      );
      _logger.info(
        '_runSync — import complete',
        metadata: {'exercises': importResult.importedExerciseCount},
      );

      final finalMeta = await dao.getLibraryMeta();

      state = AsyncData(
        ExerciseDatasetSyncState(
          phase: ExerciseDatasetSyncPhase.synced,
          manifest: downloadResult.manifest,
          libraryVersion: importResult.libraryVersion,
          schemaVersion: finalMeta?.schemaVersion,
          exerciseCount: finalMeta?.exerciseCount,
          downloadProgress: 1.0,
        ),
      );
      _logger.info('_runSync — phase: synced');
    } on ExerciseDatasetDownloadFailure catch (e) {
      _logger.error('_runSync — download failure', error: e);
      final retryable = e.retryable;
      final isUnsupported =
          e.code == ExerciseDatasetDownloadFailureCode.unsupportedAppSchema;

      await dao.setSyncStatus(
        syncStatus: LibrarySyncStatus.failed,
        errorCode: e.code.name,
        errorMessage: e.message,
      );

      state = AsyncData(
        ExerciseDatasetSyncState(
          phase: isUnsupported
              ? ExerciseDatasetSyncPhase.updateRequired
              : ExerciseDatasetSyncPhase.failed,
          failure: ExerciseDatasetSyncFailure(
            code: e.code.name,
            message: e.message,
            retryable: retryable,
          ),
        ),
      );
    } catch (e) {
      _logger.error('_runSync — unexpected error', error: e);
      await dao.setSyncStatus(
        syncStatus: LibrarySyncStatus.failed,
        errorCode: AppErrorCodes.unknown,
        errorMessage: e.toString(),
      );

      state = AsyncData(
        ExerciseDatasetSyncState(
          phase: ExerciseDatasetSyncPhase.failed,
          failure: ExerciseDatasetSyncFailure(
            code: AppErrorCodes.unknown,
            message: e.toString(),
            retryable: true,
          ),
        ),
      );
    }
  }
}
