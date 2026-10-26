import 'package:aedify/core/db/transactions/transaction_failure_injection.dart';
import 'package:aedify/core/db/transactions/transaction_operation.dart';

class CapturingTransactionFailureInjection
    implements TransactionFailureInjection {
  final List<String> beforeOperations = <String>[];
  final List<String> afterOperations = <String>[];

  @override
  void beforeOperation(TransactionOperation operation) {
    beforeOperations.add(operation.name);
  }

  @override
  void afterOperation(TransactionOperation operation) {
    afterOperations.add(operation.name);
  }
}
