import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCrashlyticsClient implements CrashlyticsClient {
  final keys = <String, String>{};
  final logs = <String>[];
  Object? recordedException;
  String? recordedReason;

  @override
  void log(String message) {
    logs.add(message);
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
  void setCustomKey(String key, String value) {
    keys[key] = value;
  }
}

void main() {
  group('CrashlyticsService', () {
    test('no-ops when disabled', () {
      final service = CrashlyticsService(enabled: false);
      expect(
        () => service.setCustomKeySafe('api_key', 'secret'),
        returnsNormally,
      );
      expect(
        () => service.recordErrorSafe(Exception('test'), StackTrace.current),
        returnsNormally,
      );
      expect(
        () => service.logSafe('test event', metadata: {'api_key': 'secret'}),
        returnsNormally,
      );
    });

    test('no-ops when crashlytics is null', () {
      final service = CrashlyticsService(client: null);
      expect(
        () => service.setCustomKeySafe('api_key', 'secret'),
        returnsNormally,
      );
      expect(
        () => service.recordErrorSafe(Exception('test'), StackTrace.current),
        returnsNormally,
      );
      expect(() => service.logSafe('test event'), returnsNormally);
    });

    test('ignores forbidden keys in setCustomKeySafe', () {
      final client = _FakeCrashlyticsClient();
      final service = CrashlyticsService(client: client);

      service.setCustomKeySafe('api_key', 'secret');

      expect(client.keys, isEmpty);
    });

    test('allows allowed keys in setCustomKeySafe', () {
      final client = _FakeCrashlyticsClient();
      final service = CrashlyticsService(client: client);

      service.setCustomKeySafe('app_version', '1.0.0');

      expect(client.keys['app_version'], equals('1.0.0'));
    });

    test('logSafe redacts forbidden metadata', () {
      final client = _FakeCrashlyticsClient();
      final service = CrashlyticsService(client: client);

      service.logSafe(
        'test',
        metadata: {'api_key': 'secret', 'app_version': '1.0.0'},
      );

      expect(client.logs.single, contains('[REDACTED]'));
      expect(client.logs.single, contains('1.0.0'));
      expect(client.logs.single, isNot(contains('secret')));
    });

    test('recordErrorSafe forwards only safe metadata and redacted error', () {
      final client = _FakeCrashlyticsClient();
      final service = CrashlyticsService(client: client);

      service.recordErrorSafe(
        Exception('api key secret'),
        StackTrace.empty,
        reason: 'prompt contains secret',
        metadata: {'app_version': '1.0.0', 'api_key': 'sk-secret'},
      );

      expect(client.keys['app_version'], equals('1.0.0'));
      expect(client.keys.containsKey('api_key'), isFalse);
      expect(client.recordedException.toString(), contains('Redacted'));
      expect(client.recordedReason, contains('[REDACTED]'));
    });

    test('enabled is true by default', () {
      final service = CrashlyticsService(client: null);
      expect(service.enabled, isTrue);
    });
  });
}
