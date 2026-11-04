import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/network/interceptors/redacted_logging_interceptor.dart';
import 'package:aedify/core/privacy/privacy_classifier.dart';
import 'package:aedify/core/privacy/redaction.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'M5 privacy gate: training evidence and derived metrics never reach diagnostic sinks',
    () {
      const privateFields = <String, Object>{
        'api_key': 'M5_KEY_SENTINEL',
        'set_logs': 'M5_LOG_SENTINEL',
        'set_log_notes': 'M5_NOTE_SENTINEL',
        'body_measurements': 'M5_BODY_SENTINEL',
        'exercise_name_snapshot': 'M5_EXERCISE_SENTINEL',
        'personal_records': 'M5_PR_SENTINEL',
        'estimated_1rm_kg': 'M5_E1RM_SENTINEL',
        'weekly_volume': 'M5_VOLUME_SENTINEL',
        'plateau_flags': 'M5_PLATEAU_SENTINEL',
        'future_analytics_payload': {'nested_metric': 'M5_NESTED_SENTINEL'},
      };
      final captured = <String>[];
      final logger = AppLogger(
        sink: (message, {required name, required level, error, stackTrace}) {
          captured.add('$message $error');
        },
      );
      logger.error(
        'analytics_failed',
        metadata: privateFields,
        error: StateError(privateFields.toString()),
      );
      final client = _CapturedCrashClient();
      final crash = CrashlyticsService(client: client);
      crash.logSafe(
        'analytics_failed',
        metadata: {...privateFields, 'error_code': 'analytics_unavailable'},
      );
      crash.recordErrorSafe(
        StateError(privateFields.toString()),
        StackTrace.empty,
        reason: privateFields.toString(),
        metadata: privateFields,
      );
      for (final field in privateFields.entries) {
        crash.setCustomKeySafe(field.key, field.value);
      }
      final options = RequestOptions(
        path: '/provider',
        data: privateFields,
        headers: {'Authorization': privateFields['api_key']},
      );
      RedactedLoggingInterceptor(
        logger: logger,
      ).onRequest(options, RequestInterceptorHandler());
      final output = [...captured, ...client.events].join('\n');
      for (final sentinel in [
        'M5_KEY_SENTINEL',
        'M5_LOG_SENTINEL',
        'M5_NOTE_SENTINEL',
        'M5_BODY_SENTINEL',
        'M5_EXERCISE_SENTINEL',
        'M5_PR_SENTINEL',
        'M5_E1RM_SENTINEL',
        'M5_VOLUME_SENTINEL',
        'M5_PLATEAU_SENTINEL',
        'M5_NESTED_SENTINEL',
      ]) {
        expect(output, isNot(contains(sentinel)));
      }
      expect(output, contains(Redaction.redactedPlaceholder));
      expect(output, contains('analytics_unavailable'));
      expect(client.keys, isEmpty);
    },
  );

  test(
    'M5 privacy gate: local analytics remain ineligible for export and diagnostics',
    () {
      const classifier = PrivacyClassifier();
      expect(classifier.isAllowedInExport(PrivacyClass.localPersonal), isFalse);
      expect(classifier.isAllowedInLog(PrivacyClass.localPersonal), isFalse);
      expect(
        classifier.isAllowedInCrashlytics(PrivacyClass.localPersonal),
        isFalse,
      );
      for (final field in [
        'personal_records',
        'estimated_1rm_kg',
        'weekly_volume',
        'plateau_flags',
        'future_analytics_payload',
      ]) {
        expect(classifier.isDiagnosticFieldAllowed(field), isFalse);
      }
    },
  );
}

class _CapturedCrashClient implements CrashlyticsClient {
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
    events.add('$exception $reason $stack');
  }
}
