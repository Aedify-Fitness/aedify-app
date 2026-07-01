import 'package:aedify/core/db/transactions/transaction_operation.dart';

class TransactionStep {
  const TransactionStep({required this.operation, required this.run});

  final TransactionOperation operation;
  final Future<void> Function() run;
}
