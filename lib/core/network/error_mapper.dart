import 'package:dio/dio.dart';
import 'package:aedify/core/errors/app_error.dart';

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
          userMessage:
              'Connection timed out. Please check your connection and try again.',
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
          userMessage:
              'Could not connect. Please check your internet connection.',
          details: error.message,
        );
      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response?.statusCode, error.message);
      case DioExceptionType.badCertificate:
        return AppError(
          code: 'bad_certificate',
          message: 'Invalid server certificate',
          userMessage: 'A security error occurred. Please try again later.',
          details: error.message,
        );
      case DioExceptionType.unknown:
        return AppError(
          code: 'unknown_network_error',
          message: error.message ?? 'An unknown network error occurred',
          userMessage: 'Something went wrong. Please try again.',
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
          userMessage: 'Please check your credentials and try again.',
          details: details,
        );
      case 403:
        return AppError(
          code: 'forbidden',
          message: 'Access denied',
          userMessage: 'You do not have permission to perform this action.',
          details: details,
        );
      case 404:
        return AppError(
          code: 'not_found',
          message: 'Resource not found',
          userMessage: 'The requested resource was not found.',
          details: details,
        );
      case 429:
        return AppError(
          code: 'rate_limited',
          message: 'Too many requests',
          userMessage: 'Please wait a moment and try again.',
          details: details,
        );
      case final s when s != null && s >= 500:
        return AppError(
          code: 'server_error',
          message: 'Server error',
          userMessage: 'A server error occurred. Please try again later.',
          details: details,
        );
      default:
        return AppError(
          code: 'unexpected_status',
          message: 'Unexpected response status: $statusCode',
          userMessage: 'Something went wrong. Please try again.',
          details: details,
        );
    }
  }
}
