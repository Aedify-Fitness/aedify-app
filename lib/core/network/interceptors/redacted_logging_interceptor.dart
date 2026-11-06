import 'package:dio/dio.dart';
import 'package:aedify/core/logging/app_logger.dart';

class RedactedLoggingInterceptor extends Interceptor {
  RedactedLoggingInterceptor({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug('[HTTP] request', metadata: {'method': options.method});
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.info(
      '[HTTP] response',
      metadata: {
        'status_code': response.statusCode,
        'method': response.requestOptions.method,
      },
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      '[HTTP] error',
      metadata: {
        'error_code': err.type.name,
        'method': err.requestOptions.method,
        if (err.response?.statusCode != null)
          'status_code': err.response!.statusCode,
      },
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
