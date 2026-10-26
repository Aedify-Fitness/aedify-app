enum TrainingStyle {
  generalFitness,
  strength,
  hypertrophy,
  strengthHypertrophy,
  fatLoss,
  conditioning,
  mobilityRecovery;

  String get dbValue {
    return switch (this) {
      TrainingStyle.generalFitness => 'general_fitness',
      TrainingStyle.strengthHypertrophy => 'strength_hypertrophy',
      TrainingStyle.fatLoss => 'fat_loss',
      TrainingStyle.mobilityRecovery => 'mobility_recovery',
      _ => name,
    };
  }

  static TrainingStyle? fromDb(String? value) {
    if (value == null) return null;
    return TrainingStyle.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => TrainingStyle.generalFitness,
    );
  }
}
