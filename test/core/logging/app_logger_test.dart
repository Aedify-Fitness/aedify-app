import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/logging/app_logger.dart';
import '../../support/privacy/privacy_sentinel_values.dart';

void main() {
  group('AppLogger', () {
    test('debug redacts forbidden metadata values', () {
      late String capturedMessage;
      final logger = AppLogger(
        sink:
            (
              message, {
              required String name,
              required int level,
              Object? error,
              StackTrace? stackTrace,
            }) {
              capturedMessage = message;
            },
      );

      logger.debug('test event', metadata: {'api_key': 'secret-key'});

      expect(capturedMessage, contains('[REDACTED]'));
      expect(capturedMessage, isNot(contains('secret-key')));
    });

    test('info preserves allowlisted metadata values', () {
      late String capturedMessage;
      final logger = AppLogger(
        sink:
            (
              message, {
              required String name,
              required int level,
              Object? error,
              StackTrace? stackTrace,
            }) {
              capturedMessage = message;
            },
      );

      logger.info('test event', metadata: {'app_version': '1.0.0'});

      expect(capturedMessage, contains('1.0.0'));
    });

    test('warn redacts error object', () {
      Object? capturedError;
      final logger = AppLogger(
        sink:
            (
              message, {
              required String name,
              required int level,
              Object? error,
              StackTrace? stackTrace,
            }) {
              capturedError = error;
            },
      );

      logger.warn('warning', error: Exception('test'));

      expect(capturedError.toString(), contains('Redacted'));
      expect(capturedError.toString(), isNot(contains('test')));
    });

    test('error accepts stack trace and uses custom sink', () {
      var captured = false;
      final logger = AppLogger(
        sink:
            (
              message, {
              required String name,
              required int level,
              Object? error,
              StackTrace? stackTrace,
            }) {
              captured = stackTrace != null;
            },
      );

      logger.error(
        'error occurred',
        error: Exception('fail'),
        stackTrace: StackTrace.current,
      );

      expect(captured, isTrue);
    });

    test('empty metadata does not crash', () {
      final logger = AppLogger();
      expect(() => logger.info('no metadata'), returnsNormally);
    });

    test('custom name is used', () {
      final logger = AppLogger(name: 'custom-test');
      expect(logger.name, equals('custom-test'));
    });

    test('profile note sentinel is redacted in logs', () {
      late String capturedMessage;
      final logger = AppLogger(
        sink:
            (
              message, {
              required String name,
              required int level,
              Object? error,
              StackTrace? stackTrace,
            }) {
              capturedMessage = message;
            },
      );

      logger.debug(
        'profile event',
        metadata: {'notes': PrivacySentinelValues.fakeProfileNote},
      );

      expect(capturedMessage, contains('[REDACTED]'));
      expect(
        capturedMessage,
        isNot(contains(PrivacySentinelValues.fakeProfileNote)),
      );
    });

    test('injury sentinel is redacted in logs', () {
      late String capturedMessage;
      final logger = AppLogger(
        sink:
            (
              message, {
              required String name,
              required int level,
              Object? error,
              StackTrace? stackTrace,
            }) {
              capturedMessage = message;
            },
      );

      logger.warn(
        'injury event',
        metadata: {'injury': PrivacySentinelValues.fakeInjuryNote},
      );

      expect(capturedMessage, contains('[REDACTED]'));
      expect(
        capturedMessage,
        isNot(contains(PrivacySentinelValues.fakeInjuryNote)),
      );
    });

    test('bodyweight sentinel is redacted in logs', () {
      late String capturedMessage;
      final logger = AppLogger(
        sink:
            (
              message, {
              required String name,
              required int level,
              Object? error,
              StackTrace? stackTrace,
            }) {
              capturedMessage = message;
            },
      );

      logger.info(
        'weight event',
        metadata: {'bodyweight': PrivacySentinelValues.fakeBodyweight},
      );

      expect(capturedMessage, contains('[REDACTED]'));
      expect(
        capturedMessage,
        isNot(contains(PrivacySentinelValues.fakeBodyweight)),
      );
    });
  });
}
