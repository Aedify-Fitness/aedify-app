import 'package:aedify/core/firebase/crashlytics_service.dart';

class FakeCrashlyticsCapture implements CrashlyticsClient {
  final Map<String, String> keys = {};
  final List<String> logs = [];
  Object? recordedException;
  String? recordedReason;

  @override
  void setCustomKey(String key, String value) {
    keys[key] = value;
  }

  @override
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    recordedException = exception;
    recordedReason = reason;
  }

  @override
  void log(String message) {
    logs.add(message);
  }
}
