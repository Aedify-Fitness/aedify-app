import 'package:dio/dio.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/privacy/redaction.dart';

class RedactedLoggingInterceptor extends Interceptor {
  RedactedLoggingInterceptor({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final safeHeaders = Redaction.headers(
      options.headers.map((k, v) => MapEntry(k, v as Object)),
    );
    _logger.debug(
      '[HTTP] --> ${options.method} ${options.path}',
      metadata: {
        'method': options.method,
        'path': options.path,
        if (options.queryParameters.isNotEmpty)
          'query': Redaction.queryParameters(
            options.queryParameters.map((k, v) => MapEntry(k, v as Object)),
          ).toString(),
        'headers': safeHeaders.keys.toString(),
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.info(
      '[HTTP] <-- ${response.statusCode} ${response.requestOptions.path}',
      metadata: {
        'status_code': response.statusCode,
        'path': response.requestOptions.path,
        'method': response.requestOptions.method,
      },
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      '[HTTP] ERROR ${err.type.name} ${err.requestOptions.path}',
      metadata: {
        'error_type': err.type.name,
        'path': err.requestOptions.path,
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
