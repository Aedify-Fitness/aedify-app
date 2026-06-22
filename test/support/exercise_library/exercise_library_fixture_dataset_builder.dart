class ExerciseLibraryFixtureDatasetBuilder {
  int _schemaVersion = 1;
  String _generatedAt = '2026-06-22T00:00:00Z';
  String _source = 'musclewiki';
  int _exerciseCount = 0;
  final List<Map<String, Object?>> _exercises = [];

  ExerciseLibraryFixtureDatasetBuilder withSchemaVersion(int value) {
    _schemaVersion = value;
    return this;
  }

  ExerciseLibraryFixtureDatasetBuilder withGeneratedAt(String value) {
    _generatedAt = value;
    return this;
  }

  ExerciseLibraryFixtureDatasetBuilder withExerciseCount(int value) {
    _exerciseCount = value;
    return this;
  }

  ExerciseLibraryFixtureDatasetBuilder addExercise(
    Map<String, Object?> exercise,
  ) {
    _exercises.add(Map<String, Object?>.from(exercise));
    return this;
  }

  ExerciseLibraryFixtureDatasetBuilder replaceExercises(
    List<Map<String, Object?>> exercises,
  ) {
    _exercises.clear();
    _exercises.addAll(exercises.map((e) => Map<String, Object?>.from(e)));
    return this;
  }

  Map<String, Object?> build() {
    return <String, Object?>{
      'schema_version': _schemaVersion,
      'generated_at': _generatedAt,
      'source': _source,
      'exercise_count': _exerciseCount > 0 ? _exerciseCount : _exercises.length,
      'exercises': _exercises,
    };
  }
}
