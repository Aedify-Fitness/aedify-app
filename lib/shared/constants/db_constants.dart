class DbConstants {
  DbConstants._();

  static const String databaseFileName = 'aedify.sqlite';

  static const String initialDriftSchemaVersion = '2';
  static const String defaultExerciseLibraryVersion = '0';
  static const String defaultDataModelPlanVersion = '1.0';
  static const String defaultInstructionSetVersion = '1.10';
  static const int supportedExerciseDatasetSchemaVersion = 1;
  static const String defaultAiOutputSchemaSupportedMax = '1';
  static const String defaultAiOutputSchemaSupportedMin = '1';
  static const String defaultShareSchemaSupportedVersion = '1';
  static const String defaultFirebaseExerciseSupportedSchemaMin = '1';
  static const String defaultFirebaseExerciseSupportedSchemaMax = '1';
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
