enum ExerciseLibraryImportFailureCode {
  transactionFailed,
  invalidDatasetForImport,
  preserveFlagsFailed,
  metadataWriteFailed,
}

class ExerciseLibraryImportFailure implements Exception {
  const ExerciseLibraryImportFailure({
    required this.code,
    required this.message,
  });

  final ExerciseLibraryImportFailureCode code;
  final String message;

  @override
  String toString() => 'ExerciseLibraryImportFailure(${code.name}): $message';
}
