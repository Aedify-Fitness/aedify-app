import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  CrashlyticsService({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  void log(String message) => _crashlytics.log(message);

  void recordError(dynamic exception, StackTrace? stack, {String? reason}) {
    _crashlytics.recordError(exception, stack, reason: reason);
  }

  void setCustomKey(String key, String value) =>
      _crashlytics.setCustomKey(key, value);

  void setUserId(String userId) => _crashlytics.setUserIdentifier(userId);
}
