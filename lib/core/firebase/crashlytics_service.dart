import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:aedify/core/privacy/privacy_classifier.dart';
import 'package:aedify/core/privacy/redaction.dart';

abstract interface class CrashlyticsClient {
  void setCustomKey(String key, String value);

  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
  });

  void log(String message);
}

class FirebaseCrashlyticsClient implements CrashlyticsClient {
  const FirebaseCrashlyticsClient();

  FirebaseCrashlytics get _instance => FirebaseCrashlytics.instance;

  @override
  void setCustomKey(String key, String value) {
    _instance.setCustomKey(key, value);
  }

  @override
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
  }) {
    return _instance.recordError(exception, stack, reason: reason);
  }

  @override
  void log(String message) {
    _instance.log(message);
  }
}

/// Emits diagnostics with redacted errors, stack text and private metadata.
///
/// Event strings must be static identifiers. Allowlisted scalar metadata must
/// contain non-sensitive diagnostic values, never user content.
class CrashlyticsService {
  CrashlyticsService({
    CrashlyticsClient? client,
    PrivacyClassifier? classifier,
    this.enabled = true,
  }) : _client = client,
       _classifier = classifier ?? const PrivacyClassifier();

  final CrashlyticsClient? _client;
  final PrivacyClassifier _classifier;
  final bool enabled;

  void setCustomKeySafe(String key, Object value) {
    if (!enabled || _client == null) return;
    if (!_classifier.isDiagnosticFieldAllowed(key)) return;
    final safeMetadata = Redaction.diagnosticMetadata({
      key: value,
    }, classifier: _classifier);
    _client.setCustomKey(key, safeMetadata[key].toString());
  }

  void recordErrorSafe(
    Object exception,
    StackTrace? stack, {
    String? reason,
    Map<String, Object?> metadata = const {},
  }) {
    if (!enabled || _client == null) return;
    final safeMetadata = Redaction.diagnosticMetadata(
      metadata,
      classifier: _classifier,
    );
    for (final entry in safeMetadata.entries) {
      if (_classifier.isDiagnosticFieldAllowed(entry.key)) {
        _client.setCustomKey(entry.key, entry.value.toString());
      }
    }
    _client.recordError(
      StateError('Redacted ${exception.runtimeType}'),
      Redaction.stackTrace(stack),
      reason: reason == null ? null : Redaction.sensitive(reason),
    );
  }

  void logSafe(String event, {Map<String, Object?> metadata = const {}}) {
    if (!enabled || _client == null) return;
    final safeMetadata = Redaction.diagnosticMetadata(
      metadata,
      classifier: _classifier,
    );
    final safeEvent = safeMetadata.isEmpty
        ? event
        : '$event (${safeMetadata.map((k, v) => MapEntry(k, v.toString()))})';
    _client.log(safeEvent);
  }
}
