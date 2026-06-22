import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_manifest.dart';

enum ExerciseDatasetSyncPhase {
  neverSynced,
  checkingManifest,
  downloading,
  importing,
  synced,
  failed,
  updateRequired,
  unavailableOffline,
}

class ExerciseDatasetSyncFailure {
  const ExerciseDatasetSyncFailure({
    required this.code,
    required this.message,
    this.retryable = true,
  });

  final String code;
  final String message;
  final bool retryable;
}

class ExerciseDatasetSyncState {
  const ExerciseDatasetSyncState({
    required this.phase,
    this.manifest,
    this.libraryVersion,
    this.schemaVersion,
    this.exerciseCount,
    this.downloadProgress,
    this.failure,
    this.isOffline = false,
  });

  final ExerciseDatasetSyncPhase phase;
  final ExerciseDatasetManifest? manifest;
  final String? libraryVersion;
  final int? schemaVersion;
  final int? exerciseCount;
  final double? downloadProgress;
  final ExerciseDatasetSyncFailure? failure;
  final bool isOffline;

  bool get isLoading =>
      phase == ExerciseDatasetSyncPhase.checkingManifest ||
      phase == ExerciseDatasetSyncPhase.downloading ||
      phase == ExerciseDatasetSyncPhase.importing;

  bool get needsInitialSync => phase == ExerciseDatasetSyncPhase.neverSynced;

  bool get hasFailure => failure != null;

  bool get isSynced => phase == ExerciseDatasetSyncPhase.synced;

  ExerciseDatasetSyncState copyWith({
    ExerciseDatasetSyncPhase? phase,
    ExerciseDatasetManifest? manifest,
    String? libraryVersion,
    int? schemaVersion,
    int? exerciseCount,
    double? downloadProgress,
    ExerciseDatasetSyncFailure? failure,
    bool? isOffline,
    bool clearManifest = false,
    bool clearLibraryVersion = false,
    bool clearDownloadProgress = false,
    bool clearFailure = false,
  }) {
    return ExerciseDatasetSyncState(
      phase: phase ?? this.phase,
      manifest: clearManifest ? null : (manifest ?? this.manifest),
      libraryVersion: clearLibraryVersion
          ? null
          : (libraryVersion ?? this.libraryVersion),
      schemaVersion: schemaVersion ?? this.schemaVersion,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      downloadProgress: clearDownloadProgress
          ? null
          : (downloadProgress ?? this.downloadProgress),
      failure: clearFailure ? null : (failure ?? this.failure),
      isOffline: isOffline ?? this.isOffline,
    );
  }

  const ExerciseDatasetSyncState.neverSynced()
    : phase = ExerciseDatasetSyncPhase.neverSynced,
      manifest = null,
      libraryVersion = null,
      schemaVersion = null,
      exerciseCount = null,
      downloadProgress = null,
      failure = null,
      isOffline = false;
}
