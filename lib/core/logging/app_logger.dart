import 'dart:developer' as dev;
import 'package:aedify/core/privacy/privacy_classifier.dart';
import 'package:aedify/core/privacy/redaction.dart';

class AppLogger {
  static const loggerName = 'aedify';

  AppLogger({PrivacyClassifier? classifier, this.name = AppLogger.loggerName})
    : _classifier = classifier ?? const PrivacyClassifier();

  final String name;
  final PrivacyClassifier _classifier;

  void debug(
    String event, {
    Map<String, Object?> metadata = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      event,
      level: 500,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void info(
    String event, {
    Map<String, Object?> metadata = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      event,
      level: 800,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void warn(
    String event, {
    Map<String, Object?> metadata = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      event,
      level: 900,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(
    String event, {
    Map<String, Object?> metadata = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      event,
      level: 1000,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    String event, {
    required int level,
    Map<String, Object?> metadata = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    final classified = metadata.map((k, v) {
      if (!_classifier.isDiagnosticFieldAllowed(k)) {
        return MapEntry(k, Redaction.sensitive(v.toString()));
      }
      return MapEntry(k, v);
    });
    final safeMetadata = Redaction.metadata(classified);
    final safeEvent = safeMetadata.isEmpty
        ? event
        : '$event (${safeMetadata.map((k, v) => MapEntry(k, v.toString()))})';
    dev.log(
      safeEvent,
      name: name,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
