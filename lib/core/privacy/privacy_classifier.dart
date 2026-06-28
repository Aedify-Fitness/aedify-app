enum PrivacyClass {
  publicStatic,
  localPersonal,
  secret,
  localMedia,
  temporaryImportArtifact,
  aiInternal,
  exportablePlanContent,
  diagnosticSafe,
}

class PrivacyClassifier {
  const PrivacyClassifier();

  static const _allowedFields = {
    'app_version',
    'build_number',
    'platform',
    'os_version',
    'device_model',
    'screen_name',
    'route_name',
    'error_code',
    'operation_name',
    'operation_name_without_payload',
    'non_sensitive_feature_flag',
    'drift_schema_version',
    'exercise_dataset_schema_version',
    'exercise_library_version',
    'redacted_stack_trace',
  };

  static const _forbiddenFields = {
    'api_key',
    'prompt',
    'response',
    'chat_history',
    'file_path',
    'progress_media_path',
    'body_measurements',
    'set_logs',
    'candidate_exercise_list',
    'candidate_exercise_lists',
    'injury_note',
    'injuries',
    'notes',
    'programme_description',
    'workout_notes',
    'session_notes',
    'exercise_name_snapshot',
    'program_revision_summary',
    'screenshot_path',
    'source_file_excerpt',
    'local_database_dump',
    'prompt_text',
    'ai_response_json',
    'workout_session_notes',
    'saved_workout_notes',
    'set_log_notes',
    'exercise_notes',
    'exercise_cues',
    'workout_name_snapshot',
  };

  bool isAllowedInCrashlytics(PrivacyClass privacyClass) {
    return switch (privacyClass) {
      PrivacyClass.publicStatic => true,
      PrivacyClass.diagnosticSafe => true,
      _ => false,
    };
  }

  bool isAllowedInExport(PrivacyClass privacyClass) {
    return switch (privacyClass) {
      PrivacyClass.publicStatic => true,
      PrivacyClass.exportablePlanContent => true,
      _ => false,
    };
  }

  bool isAllowedInLog(PrivacyClass privacyClass) {
    return switch (privacyClass) {
      PrivacyClass.publicStatic => true,
      PrivacyClass.diagnosticSafe => true,
      _ => false,
    };
  }

  bool isDiagnosticFieldAllowed(String key) {
    return _allowedFields.contains(key);
  }

  PrivacyClass classifyField(String key) {
    if (_forbiddenFields.contains(key)) return PrivacyClass.secret;
    if (_allowedFields.contains(key)) return PrivacyClass.diagnosticSafe;
    return PrivacyClass.publicStatic;
  }
}
