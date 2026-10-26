import 'package:aedify/core/db/transactions/transaction_step.dart';

abstract class TransactionExecutor {
  Future<void> execute({
    required String operationName,
    required List<TransactionStep> steps,
  });
}
