enum ExerciseSource {
  firebaseDataset,
  custom,
  importedShare;

  String get dbValue {
    return switch (this) {
      ExerciseSource.firebaseDataset => 'firebase_dataset',
      ExerciseSource.importedShare => 'imported_share',
      _ => name,
    };
  }

  static ExerciseSource fromDb(String value) {
    return ExerciseSource.values.firstWhere((e) => e.dbValue == value);
  }
}
