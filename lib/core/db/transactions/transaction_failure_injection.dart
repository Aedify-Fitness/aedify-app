import 'package:aedify/core/db/transactions/transaction_operation.dart';

abstract class TransactionFailureInjection {
  const TransactionFailureInjection();

  void beforeOperation(TransactionOperation operation);

  void afterOperation(TransactionOperation operation);
}
