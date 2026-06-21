enum ExerciseDatasetDownloadFailureCode {
  offline,
  authFailed,
  manifestFetchFailed,
  invalidManifest,
  unsupportedAppSchema,
  datasetDownloadFailed,
  interruptedDownload,
  sizeMismatch,
  checksumMismatch,
}

class ExerciseDatasetDownloadFailure implements Exception {
  const ExerciseDatasetDownloadFailure({
    required this.code,
    required this.message,
    this.retryable = true,
  });

  final ExerciseDatasetDownloadFailureCode code;
  final String message;
  final bool retryable;

  @override
  String toString() => 'ExerciseDatasetDownloadFailure(${code.name}): $message';
}
