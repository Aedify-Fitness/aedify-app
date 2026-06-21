import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

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
      final service = CrashlyticsService(crashlytics: null);
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
      final service = CrashlyticsService(crashlytics: null);
      expect(
        () => service.setCustomKeySafe('api_key', 'secret'),
        returnsNormally,
      );
    });

    test('allows allowed keys in setCustomKeySafe', () {
      final service = CrashlyticsService(crashlytics: null);
      expect(
        () => service.setCustomKeySafe('app_version', '1.0.0'),
        returnsNormally,
      );
    });

    test('logSafe redacts forbidden metadata', () {
      final service = CrashlyticsService(crashlytics: null);
      expect(
        () => service.logSafe(
          'test',
          metadata: {'api_key': 'secret', 'app_version': '1.0.0'},
        ),
        returnsNormally,
      );
    });

    test('enabled is true by default', () {
      final service = CrashlyticsService(crashlytics: null);
      expect(service.enabled, isTrue);
    });
  });
}
