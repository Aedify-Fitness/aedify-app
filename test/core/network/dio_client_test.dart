import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/network/error_mapper.dart';
import 'package:aedify/core/network/dio_client.dart';
import 'package:aedify/core/network/interceptors/redacted_logging_interceptor.dart';
import 'package:aedify/core/network/retry_policy.dart';

void main() {
  group('DioClient', () {
    test('constructs with explicit dependencies', () {
      final client = DioClient(
        logger: AppLogger(),
        errorMapper: const ErrorMapper(),
        retryPolicy: const RetryPolicy(),
      );
      expect(client.dio, isNotNull);
    });

    test('constructs with default retry policy', () {
      final client = DioClient(
        logger: AppLogger(),
        errorMapper: const ErrorMapper(),
      );
      expect(client.dio, isNotNull);
    });

    test('has RedactedLoggingInterceptor installed', () {
      final client = DioClient(
        logger: AppLogger(),
        errorMapper: const ErrorMapper(),
      );
      final hasRedactedInterceptor = client.dio.interceptors.any(
        (i) => i is RedactedLoggingInterceptor,
      );
      expect(hasRedactedInterceptor, isTrue);
    });

    test('logger sink can be injected for safe network logging', () {
      late String capturedMessage;
      final client = DioClient(
        logger: AppLogger(
          sink: (
            message, {
            required String name,
            required int level,
            Object? error,
            StackTrace? stackTrace,
          }) {
            capturedMessage = message;
          },
        ),
        errorMapper: const ErrorMapper(),
      );

      final interceptor = client.dio.interceptors
          .whereType<RedactedLoggingInterceptor>()
          .single;
      interceptor.onRequest(
        RequestOptions(
          path: '/chat',
          headers: {'Authorization': 'Bearer secret-token'},
          queryParameters: {'api_key': 'sk-secret'},
        ),
        RequestInterceptorHandler(),
      );

      expect(capturedMessage, contains('[REDACTED]'));
      expect(capturedMessage, isNot(contains('secret-token')));
      expect(capturedMessage, isNot(contains('sk-secret')));
    });
  });
}
