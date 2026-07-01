import 'package:aedify/core/db/transactions/transaction_failure_injection.dart';
import 'package:aedify/core/db/transactions/transaction_operation.dart';

class ThrowingTransactionFailureInjection
    implements TransactionFailureInjection {
  ThrowingTransactionFailureInjection({
    required this.failOnOperationName,
    this.failBefore = true,
  });

  final String failOnOperationName;
  final bool failBefore;

  @override
  void beforeOperation(TransactionOperation operation) {
    if (failBefore && operation.name == failOnOperationName) {
      throw Exception('Injected failure before: ${operation.name}');
    }
  }

  @override
  void afterOperation(TransactionOperation operation) {
    if (!failBefore && operation.name == failOnOperationName) {
      throw Exception('Injected failure after: ${operation.name}');
    }
  }
}
