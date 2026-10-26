import 'package:dio/dio.dart';
import 'package:aedify/core/errors/app_error.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';

class ErrorMapper {
  const ErrorMapper();

  AppError mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return AppError(
          code: AppErrorCodes.networkTimeout,
          message: 'Request timed out',
          userMessage: AppErrorStrings.networkTimeoutMessage,
          details: error.message,
        );
      case DioExceptionType.cancel:
        return AppError(
          code: AppErrorCodes.requestCancelled,
          message: 'Request was cancelled',
          userMessage: null,
          details: error.message,
        );
      case DioExceptionType.connectionError:
        return AppError(
          code: AppErrorCodes.networkUnreachable,
          message: 'Unable to reach server',
          userMessage: AppErrorStrings.networkUnreachableMessage,
          details: error.message,
        );
      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response?.statusCode, error.message);
      case DioExceptionType.badCertificate:
        return AppError(
          code: AppErrorCodes.badCertificate,
          message: 'Invalid server certificate',
          userMessage: AppErrorStrings.badCertificateMessage,
          details: error.message,
        );
      case DioExceptionType.unknown:
        return AppError(
          code: AppErrorCodes.unknownNetworkError,
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
          code: AppErrorCodes.unauthorized,
          message: 'Authentication failed',
          userMessage: AppErrorStrings.unauthorizedMessage,
          details: details,
        );
      case 403:
        return AppError(
          code: AppErrorCodes.forbidden,
          message: 'Access denied',
          userMessage: AppErrorStrings.forbiddenMessage,
          details: details,
        );
      case 404:
        return AppError(
          code: AppErrorCodes.notFound,
          message: 'Resource not found',
          userMessage: AppErrorStrings.notFoundMessage,
          details: details,
        );
      case 429:
        return AppError(
          code: AppErrorCodes.rateLimited,
          message: 'Too many requests',
          userMessage: AppErrorStrings.rateLimitedMessage,
          details: details,
        );
      case final s when s != null && s >= 500:
        return AppError(
          code: AppErrorCodes.serverError,
          message: 'Server error',
          userMessage: AppErrorStrings.serverErrorMessage,
          details: details,
        );
      default:
        return AppError(
          code: AppErrorCodes.unexpectedStatus,
          message: 'Unexpected response status: $statusCode',
          userMessage: AppErrorStrings.unexpectedStatusMessage,
          details: details,
        );
    }
  }
}
