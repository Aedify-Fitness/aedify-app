enum GoalTag {
  buildMuscle,
  loseWeight,
  increaseStrength,
  improveEndurance,
  generalFitness,
  flexibility;

  String get dbValue {
    return switch (this) {
      GoalTag.buildMuscle => 'build_muscle',
      GoalTag.loseWeight => 'lose_weight',
      GoalTag.increaseStrength => 'increase_strength',
      GoalTag.improveEndurance => 'improve_endurance',
      GoalTag.generalFitness => 'general_fitness',
      _ => name,
    };
  }

  static GoalTag fromDb(String value) {
    return GoalTag.values.firstWhere((e) => e.dbValue == value);
  }
}
