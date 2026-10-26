class TransactionExecutionFailure implements Exception {
  const TransactionExecutionFailure({
    required this.operationName,
    required this.message,
    this.cause,
  });

  final String operationName;
  final String message;
  final Object? cause;

  @override
  String toString() =>
      'TransactionExecutionFailure('
      'operationName: $operationName, '
      'message: $message'
      '${cause != null ? ', cause: $cause' : ''}'
      ')';
}
