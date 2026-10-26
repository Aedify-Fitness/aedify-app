import 'package:aedify/core/db/transactions/transaction_failure_injection.dart';
import 'package:aedify/core/db/transactions/transaction_operation.dart';

class NoOpTransactionFailureInjection implements TransactionFailureInjection {
  const NoOpTransactionFailureInjection();

  @override
  void beforeOperation(TransactionOperation operation) {}

  @override
  void afterOperation(TransactionOperation operation) {}
}
