import 'package:dio/dio.dart';

class RetryPolicy {
  const RetryPolicy({this.maxRetries = 2});

  final int maxRetries;

  bool shouldRetry(DioException error, {required int attempt}) {
    if (attempt >= maxRetries) return false;
    if (error.type == DioExceptionType.cancel) return false;
    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      if (statusCode == null) return false;
      if (statusCode >= 400 && statusCode < 500) return false;
      return statusCode >= 500;
    }
    return true;
  }

  Duration retryDelay(int attempt) {
    return Duration(seconds: 2 * (attempt + 1));
  }
}
