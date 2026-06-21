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
}
