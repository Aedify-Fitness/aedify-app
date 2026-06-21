import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:aedify/core/privacy/privacy_classifier.dart';
import 'package:aedify/core/privacy/redaction.dart';

class CrashlyticsService {
  CrashlyticsService({
    FirebaseCrashlytics? crashlytics,
    PrivacyClassifier? classifier,
    this.enabled = true,
  }) : _crashlytics = crashlytics,
       _classifier = classifier ?? const PrivacyClassifier();

  final FirebaseCrashlytics? _crashlytics;
  final PrivacyClassifier _classifier;
  final bool enabled;

  void setCustomKeySafe(String key, Object value) {
    if (!enabled || _crashlytics == null) return;
    if (!_classifier.isDiagnosticFieldAllowed(key)) return;
    _crashlytics.setCustomKey(key, value.toString());
  }

  void recordErrorSafe(
    Object exception,
    StackTrace? stack, {
    String? reason,
    Map<String, Object?> metadata = const {},
  }) {
    if (!enabled || _crashlytics == null) return;
    final safeMetadata = Redaction.metadata(metadata);
    for (final entry in safeMetadata.entries) {
      if (_classifier.isDiagnosticFieldAllowed(entry.key)) {
        _crashlytics.setCustomKey(entry.key, entry.value.toString());
      }
    }
    _crashlytics.recordError(exception, stack, reason: reason);
  }

  void logSafe(String event, {Map<String, Object?> metadata = const {}}) {
    if (!enabled || _crashlytics == null) return;
    final safeMetadata = Redaction.metadata(metadata);
    final safeEvent = safeMetadata.isEmpty
        ? event
        : '$event (${safeMetadata.map((k, v) => MapEntry(k, v.toString()))})';
    _crashlytics.log(safeEvent);
  }
}
