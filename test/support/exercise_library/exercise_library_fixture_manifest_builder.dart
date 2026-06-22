class ExerciseLibraryFixtureManifestBuilder {
  int _schemaVersion = 1;
  int _manifestVersion = 3;
  String _datasetVersion = '2026-06-22-v1';
  String _generatedAt = '2026-06-22T00:00:00Z';
  String _source = 'musclewiki';
  int _exerciseCount = 350;
  String _activePath = 'datasets/exercises/2026-06-22-v1.json';
  String _contentType = 'application/json';
  int _sizeBytes = 285000;
  String _sha256 =
      'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1';
  int _activeSchemaVersion = 1;
  int _minimumSupportedAppSchemaVersion = 1;
  bool _includeHistory = true;
  bool _includeActive = true;

  ExerciseLibraryFixtureManifestBuilder withDatasetVersion(String value) {
    _datasetVersion = value;
    return this;
  }

  ExerciseLibraryFixtureManifestBuilder withMinimumSupportedAppSchemaVersion(
    int value,
  ) {
    _minimumSupportedAppSchemaVersion = value;
    return this;
  }

  ExerciseLibraryFixtureManifestBuilder withActiveSchemaVersion(int value) {
    _activeSchemaVersion = value;
    return this;
  }

  ExerciseLibraryFixtureManifestBuilder withPath(String value) {
    _activePath = value;
    return this;
  }

  ExerciseLibraryFixtureManifestBuilder withSha256(String value) {
    _sha256 = value;
    return this;
  }

  ExerciseLibraryFixtureManifestBuilder withSizeBytes(int value) {
    _sizeBytes = value;
    return this;
  }

  ExerciseLibraryFixtureManifestBuilder withExerciseCount(int value) {
    _exerciseCount = value;
    return this;
  }

  ExerciseLibraryFixtureManifestBuilder withHistoryIncluded(bool include) {
    _includeHistory = include;
    return this;
  }

  ExerciseLibraryFixtureManifestBuilder withActiveIncluded(bool include) {
    _includeActive = include;
    return this;
  }

  Map<String, Object?> build() {
    final manifest = <String, Object?>{
      'schema_version': _schemaVersion,
      'manifest_version': _manifestVersion,
      'dataset_version': _datasetVersion,
      'generated_at': _generatedAt,
      'source': _source,
      'exercise_count': _exerciseCount,
    };

    if (_includeActive) {
      manifest['active'] = <String, Object?>{
        'path': _activePath,
        'content_type': _contentType,
        'size_bytes': _sizeBytes,
        'sha256': _sha256,
        'schema_version': _activeSchemaVersion,
        'minimum_supported_app_schema_version':
            _minimumSupportedAppSchemaVersion,
      };
    }

    if (_includeHistory) {
      manifest['history'] = <Object?>[];
    } else {
      manifest['history'] = <Object?>[];
    }

    return manifest;
  }
}
