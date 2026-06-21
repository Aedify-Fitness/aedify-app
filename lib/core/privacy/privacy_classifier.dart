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
  };

  static const _forbiddenFields = {
    'api_key',
    'prompt',
    'response',
    'chat_history',
    'file_path',
    'body_measurements',
    'set_logs',
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
    return isAllowedInLog(classifyField(key));
  }

  PrivacyClass classifyField(String key) {
    if (_forbiddenFields.contains(key)) return PrivacyClass.secret;
    if (_allowedFields.contains(key)) return PrivacyClass.diagnosticSafe;
    return PrivacyClass.publicStatic;
  }
}
