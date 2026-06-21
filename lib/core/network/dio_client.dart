import 'package:dio/dio.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/network/error_mapper.dart';
import 'package:aedify/core/network/retry_policy.dart';
import 'package:aedify/core/network/interceptors/redacted_logging_interceptor.dart';

class DioClient {
  DioClient({
    required AppLogger logger,
    required ErrorMapper errorMapper,
    RetryPolicy? retryPolicy,
  }) : _logger = logger,
       _errorMapper = errorMapper,
       _retryPolicy = retryPolicy ?? const RetryPolicy(),
       _dio = Dio(
         BaseOptions(
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(seconds: 30),
           sendTimeout: const Duration(seconds: 30),
         ),
       ) {
    _dio.interceptors.add(RedactedLoggingInterceptor(logger: _logger));
  }

  final Dio _dio;
  final AppLogger _logger;
  final ErrorMapper _errorMapper;
  final RetryPolicy _retryPolicy;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeWithRetry(
      () =>
          _dio.get<T>(path, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeWithRetry(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeWithRetry(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeWithRetry(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> _executeWithRetry<T>(
    Future<Response<T>> Function() request,
  ) async {
    var attempt = 0;
    while (true) {
      try {
        return await request();
      } on DioException catch (e) {
        if (_retryPolicy.shouldRetry(e, attempt: attempt)) {
          attempt++;
          await Future.delayed(_retryPolicy.retryDelay(attempt));
          continue;
        }
        final mapped = _errorMapper.mapDioError(e);
        _logger.warn(
          '[RETRY] exhausted retries',
          metadata: {'error_code': mapped.code, 'message': mapped.message},
        );
        rethrow;
      }
    }
  }
}
