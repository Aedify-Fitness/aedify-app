import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/network/interceptors/redacted_logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('training and BYOK sentinels never reach diagnostic sinks', () {
    const privateFields = {
      'api_key': 'M4_KEY_SENTINEL',
      'set_logs': 'M4_LOG_SENTINEL',
      'workout_session_notes': 'M4_SESSION_SENTINEL',
      'set_log_notes': 'M4_NOTE_SENTINEL',
      'exercise_name_snapshot': 'M4_EXERCISE_SENTINEL',
      'prompt': 'M4_PROMPT_SENTINEL',
      'response': 'M4_RESPONSE_SENTINEL',
    };
    final captured = <String>[];
    final logger = AppLogger(
      sink: (message, {required name, required level, error, stackTrace}) {
        captured.add('$message $error');
      },
    );
    logger.error(
      'workout_save_failed',
      metadata: privateFields,
      error: StateError(privateFields.values.join(',')),
    );
    final client = _CapturingCrashClient();
    final crash = CrashlyticsService(client: client);
    crash.logSafe('workout_save_failed', metadata: privateFields);
    crash.recordErrorSafe(
      StateError(privateFields.values.join(',')),
      StackTrace.empty,
      reason: privateFields['set_logs'],
      metadata: privateFields,
    );
    for (final entry in privateFields.entries) {
      crash.setCustomKeySafe(entry.key, entry.value);
    }
    final options = RequestOptions(
      path: '/provider',
      data: privateFields,
      headers: {'Authorization': privateFields['api_key']},
      queryParameters: {'api_key': privateFields['api_key']},
    );
    RedactedLoggingInterceptor(
      logger: logger,
    ).onRequest(options, RequestInterceptorHandler());
    final output = [...captured, ...client.events].join('\n');
    expect(output, contains('[REDACTED]'));
    for (final sentinel in privateFields.values) {
      expect(output, isNot(contains(sentinel)));
    }
    expect(client.keys, isEmpty);
  });
}

class _CapturingCrashClient implements CrashlyticsClient {
  final events = <String>[];
  final keys = <String, String>{};
  @override
  void log(String message) => events.add(message);
  @override
  void setCustomKey(String key, String value) => keys[key] = value;
  @override
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    events.add('$exception $reason');
  }
}
