class AppError {
  const AppError({
    required this.code,
    required this.message,
    this.userMessage,
    this.details,
  });

  final String code;
  final String message;
  final String? userMessage;
  final Object? details;

  String get userFacingMessage => userMessage ?? message;

  @override
  String toString() => 'AppError($code): $message';
}

class AppException implements Exception {
  const AppException(this.error);

  final AppError error;

  @override
  String toString() => error.toString();
}
