class ExerciseDatasetManifest {
  const ExerciseDatasetManifest({
    required this.schemaVersion,
    required this.manifestVersion,
    required this.datasetVersion,
    required this.generatedAt,
    required this.source,
    required this.exerciseCount,
    required this.active,
    required this.history,
  });

  final int schemaVersion;
  final int manifestVersion;
  final String datasetVersion;
  final DateTime generatedAt;
  final String source;
  final int exerciseCount;
  final ExerciseDatasetActiveFile active;
  final List<ExerciseDatasetHistoryEntry> history;

  factory ExerciseDatasetManifest.fromJson(Map<String, Object?> json) {
    final schemaVersion = json['schema_version'];
    if (schemaVersion is! int) {
      throw const FormatException('schema_version must be an integer');
    }
    final manifestVersion = json['manifest_version'];
    if (manifestVersion is! int) {
      throw const FormatException('manifest_version must be an integer');
    }
    final datasetVersion = json['dataset_version'];
    if (datasetVersion is! String) {
      throw const FormatException('dataset_version must be a string');
    }
    final generatedAt = json['generated_at'];
    if (generatedAt is! String) {
      throw const FormatException('generated_at must be a string');
    }
    final source = json['source'];
    if (source is! String) {
      throw const FormatException('source must be a string');
    }
    final exerciseCount = json['exercise_count'];
    if (exerciseCount is! int) {
      throw const FormatException('exercise_count must be an integer');
    }
    final active = json['active'];
    if (active is! Map<String, Object?>) {
      throw const FormatException('active must be an object');
    }
    final history = json['history'];
    if (history is! List) {
      throw const FormatException('history must be an array');
    }

    final historyEntries = <ExerciseDatasetHistoryEntry>[];
    for (final (i, entry) in history.indexed) {
      if (entry is! Map<String, Object?>) {
        throw FormatException('history[$i] must be an object');
      }
      historyEntries.add(ExerciseDatasetHistoryEntry.fromJson(entry));
    }

    return ExerciseDatasetManifest(
      schemaVersion: schemaVersion,
      manifestVersion: manifestVersion,
      datasetVersion: datasetVersion,
      generatedAt: DateTime.parse(generatedAt),
      source: source,
      exerciseCount: exerciseCount,
      active: ExerciseDatasetActiveFile.fromJson(active),
      history: historyEntries,
    );
  }
}

class ExerciseDatasetActiveFile {
  const ExerciseDatasetActiveFile({
    required this.path,
    required this.contentType,
    required this.sizeBytes,
    required this.sha256,
    required this.schemaVersion,
    required this.minimumSupportedAppSchemaVersion,
  });

  final String path;
  final String contentType;
  final int sizeBytes;
  final String sha256;
  final int schemaVersion;
  final int minimumSupportedAppSchemaVersion;

  factory ExerciseDatasetActiveFile.fromJson(Map<String, Object?> json) {
    final path = json['path'];
    if (path is! String) {
      throw const FormatException('active.path must be a string');
    }
    final contentType = json['content_type'];
    if (contentType is! String) {
      throw const FormatException('active.content_type must be a string');
    }
    final sizeBytes = json['size_bytes'];
    if (sizeBytes is! int) {
      throw const FormatException('active.size_bytes must be an integer');
    }
    final sha256 = json['sha256'];
    if (sha256 is! String) {
      throw const FormatException('active.sha256 must be a string');
    }
    final schemaVersion = json['schema_version'];
    if (schemaVersion is! int) {
      throw const FormatException('active.schema_version must be an integer');
    }
    final minimumSupportedAppSchemaVersion =
        json['minimum_supported_app_schema_version'];
    if (minimumSupportedAppSchemaVersion is! int) {
      throw const FormatException(
        'active.minimum_supported_app_schema_version must be an integer',
      );
    }

    return ExerciseDatasetActiveFile(
      path: path,
      contentType: contentType,
      sizeBytes: sizeBytes,
      sha256: sha256,
      schemaVersion: schemaVersion,
      minimumSupportedAppSchemaVersion: minimumSupportedAppSchemaVersion,
    );
  }
}

class ExerciseDatasetHistoryEntry {
  const ExerciseDatasetHistoryEntry({
    required this.datasetVersion,
    required this.path,
    required this.sha256,
    required this.sizeBytes,
    required this.exerciseCount,
    required this.generatedAt,
  });

  final String datasetVersion;
  final String path;
  final String sha256;
  final int sizeBytes;
  final int exerciseCount;
  final DateTime generatedAt;

  factory ExerciseDatasetHistoryEntry.fromJson(Map<String, Object?> json) {
    final datasetVersion = json['dataset_version'];
    if (datasetVersion is! String) {
      throw const FormatException('history.dataset_version must be a string');
    }
    final path = json['path'];
    if (path is! String) {
      throw const FormatException('history.path must be a string');
    }
    final sha256 = json['sha256'];
    if (sha256 is! String) {
      throw const FormatException('history.sha256 must be a string');
    }
    final sizeBytes = json['size_bytes'];
    if (sizeBytes is! int) {
      throw const FormatException('history.size_bytes must be an integer');
    }
    final exerciseCount = json['exercise_count'];
    if (exerciseCount is! int) {
      throw const FormatException('history.exercise_count must be an integer');
    }
    final generatedAt = json['generated_at'];
    if (generatedAt is! String) {
      throw const FormatException('history.generated_at must be a string');
    }

    return ExerciseDatasetHistoryEntry(
      datasetVersion: datasetVersion,
      path: path,
      sha256: sha256,
      sizeBytes: sizeBytes,
      exerciseCount: exerciseCount,
      generatedAt: DateTime.parse(generatedAt),
    );
  }
}
