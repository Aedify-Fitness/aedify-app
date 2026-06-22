import 'package:dio/dio.dart';
import 'package:aedify/core/errors/app_error.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';

class ErrorMapper {
  const ErrorMapper();

  AppError mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          code: 'network_timeout',
          message: 'Request timed out',
          userMessage: AppErrorStrings.networkTimeoutMessage,
          details: error.message,
        );
      case DioExceptionType.cancel:
        return AppError(
          code: 'request_cancelled',
          message: 'Request was cancelled',
          userMessage: null,
          details: error.message,
        );
      case DioExceptionType.connectionError:
        return AppError(
          code: 'network_unreachable',
          message: 'Unable to reach server',
          userMessage: AppErrorStrings.networkUnreachableMessage,
          details: error.message,
        );
      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response?.statusCode, error.message);
      case DioExceptionType.badCertificate:
        return AppError(
          code: 'bad_certificate',
          message: 'Invalid server certificate',
          userMessage: AppErrorStrings.badCertificateMessage,
          details: error.message,
        );
      case DioExceptionType.unknown:
        return AppError(
          code: 'unknown_network_error',
          message: error.message ?? 'An unknown network error occurred',
          userMessage: AppErrorStrings.unknownNetworkErrorMessage,
          details: error.message,
        );
    }
  }

  AppError _mapStatusCode(int? statusCode, String? details) {
    switch (statusCode) {
      case 401:
        return AppError(
          code: 'unauthorized',
          message: 'Authentication failed',
          userMessage: AppErrorStrings.unauthorizedMessage,
          details: details,
        );
      case 403:
        return AppError(
          code: 'forbidden',
          message: 'Access denied',
          userMessage: AppErrorStrings.forbiddenMessage,
          details: details,
        );
      case 404:
        return AppError(
          code: 'not_found',
          message: 'Resource not found',
          userMessage: AppErrorStrings.notFoundMessage,
          details: details,
        );
      case 429:
        return AppError(
          code: 'rate_limited',
          message: 'Too many requests',
          userMessage: AppErrorStrings.rateLimitedMessage,
          details: details,
        );
      case final s when s != null && s >= 500:
        return AppError(
          code: 'server_error',
          message: 'Server error',
          userMessage: AppErrorStrings.serverErrorMessage,
          details: details,
        );
      default:
        return AppError(
          code: 'unexpected_status',
          message: 'Unexpected response status: $statusCode',
          userMessage: AppErrorStrings.unexpectedStatusMessage,
          details: details,
        );
    }
  }
}
