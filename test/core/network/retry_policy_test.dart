import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/network/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    test('retries connection timeout', () {
      final policy = const RetryPolicy();
      final error = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(policy.shouldRetry(error, attempt: 0), isTrue);
    });

    test('does not retry cancelled request', () {
      final policy = const RetryPolicy();
      final error = DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(policy.shouldRetry(error, attempt: 0), isFalse);
    });

    test('does not retry 4xx errors', () {
      final policy = const RetryPolicy();
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );
      expect(policy.shouldRetry(error, attempt: 0), isFalse);
    });

    test('retries 5xx errors', () {
      final policy = const RetryPolicy();
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      expect(policy.shouldRetry(error, attempt: 0), isTrue);
    });

    test('stops retrying after max attempts', () {
      final policy = const RetryPolicy(maxRetries: 2);
      final error = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(policy.shouldRetry(error, attempt: 0), isTrue);
      expect(policy.shouldRetry(error, attempt: 1), isTrue);
      expect(policy.shouldRetry(error, attempt: 2), isFalse);
    });

    test('retryDelay increases with attempt', () {
      final policy = const RetryPolicy();
      expect(policy.retryDelay(0), equals(Duration(seconds: 2)));
      expect(policy.retryDelay(1), equals(Duration(seconds: 4)));
      expect(policy.retryDelay(2), equals(Duration(seconds: 6)));
    });
  });
}
