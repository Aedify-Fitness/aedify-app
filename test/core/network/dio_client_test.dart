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
  });
}
