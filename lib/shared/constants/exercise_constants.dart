class ExerciseConstants {
  ExerciseConstants._();

  // Difficulty taxonomy values (internal, not user-facing)
  static const String difficultyNovice = 'novice';
  static const String difficultyBeginner = 'beginner';
  static const String difficultyIntermediate = 'intermediate';
  static const String difficultyAdvanced = 'advanced';

  // Goal tag taxonomy values (internal, used for candidate scoring)
  static const String goalTagHypertrophy = 'hypertrophy';
  static const String goalTagCardio = 'cardio';
  static const String goalTagStrength = 'strength';

  // Predefined difficulty sets
  static const Set<String> beginnerDifficulties = {
    difficultyNovice,
    difficultyBeginner,
  };
  static const Set<String> intermediateDifficulties = {
    difficultyBeginner,
    difficultyIntermediate,
  };
  static const Set<String> allDifficulties = {
    difficultyNovice,
    difficultyBeginner,
    difficultyIntermediate,
    difficultyAdvanced,
  };
}
