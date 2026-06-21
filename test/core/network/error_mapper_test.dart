import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/network/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    late ErrorMapper mapper;

    setUp(() {
      mapper = const ErrorMapper();
    });

    DioException buildError({
      required DioExceptionType type,
      int? statusCode,
      String? message,
    }) {
      return DioException(
        type: type,
        requestOptions: RequestOptions(path: '/test'),
        response: statusCode != null
            ? Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: statusCode,
              )
            : null,
        message: message,
      );
    }

    test('maps connection timeout', () {
      final error = buildError(type: DioExceptionType.connectionTimeout);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('network_timeout'));
      expect(result.userMessage, contains('timed out'));
    });

    test('maps send timeout', () {
      final error = buildError(type: DioExceptionType.sendTimeout);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('network_timeout'));
    });

    test('maps receive timeout', () {
      final error = buildError(type: DioExceptionType.receiveTimeout);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('network_timeout'));
    });

    test('maps cancellation', () {
      final error = buildError(type: DioExceptionType.cancel);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('request_cancelled'));
      expect(result.userMessage, isNull);
    });

    test('maps connection error', () {
      final error = buildError(type: DioExceptionType.connectionError);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('network_unreachable'));
    });

    test('maps 401 unauthorized', () {
      final error = buildError(type: DioExceptionType.badResponse, statusCode: 401);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('unauthorized'));
    });

    test('maps 403 forbidden', () {
      final error = buildError(type: DioExceptionType.badResponse, statusCode: 403);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('forbidden'));
    });

    test('maps 404 not found', () {
      final error = buildError(type: DioExceptionType.badResponse, statusCode: 404);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('not_found'));
    });

    test('maps 429 rate limited', () {
      final error = buildError(type: DioExceptionType.badResponse, statusCode: 429);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('rate_limited'));
    });

    test('maps 500 server error', () {
      final error = buildError(type: DioExceptionType.badResponse, statusCode: 500);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('server_error'));
    });

    test('maps bad certificate', () {
      final error = buildError(type: DioExceptionType.badCertificate);
      final result = mapper.mapDioError(error);
      expect(result.code, equals('bad_certificate'));
    });

    test('maps unknown error', () {
      final error = buildError(
        type: DioExceptionType.unknown,
        message: 'Something went wrong',
      );
      final result = mapper.mapDioError(error);
      expect(result.code, equals('unknown_network_error'));
    });
  });
}
