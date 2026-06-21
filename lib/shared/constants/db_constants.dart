class DbConstants {
  DbConstants._();

  static const String databaseFileName = 'aedify.sqlite';

  static const String initialDriftSchemaVersion = '2';
  static const String driftSchemaVersionKey = 'drift_schema_version';

  static const String dataModelPlanVersionKey = 'data_model_plan_version';
  static const String instructionSetVersionKey = 'instruction_set_version';
  static const String aiOutputSchemaSupportedMinKey = 'ai_output_schema_min';
  static const String aiOutputSchemaSupportedMaxKey = 'ai_output_schema_max';
  static const String shareSchemaSupportedVersionKey = 'share_schema_version';
  static const String firebaseExerciseSupportedSchemaMinKey =
      'firebase_exercise_schema_min';
  static const String firebaseExerciseSupportedSchemaMaxKey =
      'firebase_exercise_schema_max';
  static const String lastSuccessfulExerciseLibraryVersionKey =
      'last_exercise_library_version';
}
