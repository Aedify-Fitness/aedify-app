import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:flutter/foundation.dart';

/// Keeps global error callbacks inside the same redaction boundary as features.
class FirebaseErrorHandlers {
  FirebaseErrorHandlers(this._crashlytics);
  final CrashlyticsService _crashlytics;

  void install() {
    FlutterError.onError = reportFlutterError;
    PlatformDispatcher.instance.onError = reportPlatformError;
  }

  void reportFlutterError(FlutterErrorDetails details) {
    _crashlytics.recordErrorSafe(details.exception, details.stack);
  }

  bool reportPlatformError(Object error, StackTrace stack) {
    _crashlytics.recordErrorSafe(error, stack);
    return true;
  }
}
