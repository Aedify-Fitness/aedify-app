import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/errors/app_error.dart';

void main() {
  group('AppError', () {
    test('uses message when userMessage is null', () {
      final error = AppError(code: 'E001', message: 'Something went wrong');
      expect(error.userFacingMessage, 'Something went wrong');
    });

    test('uses userMessage when provided', () {
      final error = AppError(
        code: 'E001',
        message: 'Internal error',
        userMessage: 'Please try again later',
      );
      expect(error.userFacingMessage, 'Please try again later');
    });

    test('toString returns formatted string', () {
      final error = AppError(code: 'E001', message: 'test error');
      expect(error.toString(), 'AppError(E001): test error');
    });
  });

  group('AppException', () {
    test('toString returns error toString', () {
      final error = AppError(code: 'E001', message: 'test');
      final exception = AppException(error);
      expect(exception.toString(), error.toString());
    });
  });
}
