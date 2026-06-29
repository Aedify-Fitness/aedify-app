enum ExerciseRole {
  primary,
  secondary,
  tertiary,
  conditioning,
  mobilityRecovery;

  String get dbValue {
    return switch (this) {
      ExerciseRole.mobilityRecovery => 'mobility_recovery',
      _ => name,
    };
  }

  static ExerciseRole? fromDb(String? value) {
    if (value == null) return null;
    return ExerciseRole.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => ExerciseRole.primary,
    );
  }
}
