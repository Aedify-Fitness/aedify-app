import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/logging/app_logger.dart';

void main() {
  group('AppLogger', () {
    test('debug accepts event and redacted metadata', () {
      final logger = AppLogger();
      expect(
        () => logger.debug('test event', metadata: {'api_key': 'secret-key'}),
        returnsNormally,
      );
    });

    test('info accepts event and safe metadata', () {
      final logger = AppLogger();
      expect(
        () => logger.info('test event', metadata: {'app_version': '1.0.0'}),
        returnsNormally,
      );
    });

    test('warn accepts event with error', () {
      final logger = AppLogger();
      expect(
        () => logger.warn('warning', error: Exception('test')),
        returnsNormally,
      );
    });

    test('error accepts event with stack trace', () {
      final logger = AppLogger();
      expect(
        () => logger.error(
          'error occurred',
          error: Exception('fail'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('empty metadata does not crash', () {
      final logger = AppLogger();
      expect(() => logger.info('no metadata'), returnsNormally);
    });

    test('custom name is used', () {
      final logger = AppLogger(name: 'custom-test');
      expect(logger.name, equals('custom-test'));
    });
  });
}
