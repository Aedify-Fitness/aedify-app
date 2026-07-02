import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/transactions/no_op_transaction_failure_injection.dart';
import 'package:aedify/core/db/transactions/transaction_execution_failure.dart';
import 'package:aedify/core/db/transactions/transaction_executor.dart';
import 'package:aedify/core/db/transactions/transaction_failure_injection.dart';
import 'package:aedify/core/db/transactions/transaction_step.dart';

class DriftTransactionExecutor implements TransactionExecutor {
  DriftTransactionExecutor({
    required AppDatabase database,
    TransactionFailureInjection? failureInjection,
  }) : _database = database,
       _failureInjection =
           failureInjection ?? const NoOpTransactionFailureInjection();

  static final _logger = AppLogger(name: 'DriftTransactionExecutor');

  final AppDatabase _database;
  final TransactionFailureInjection _failureInjection;

  @override
  Future<void> execute({
    required String operationName,
    required List<TransactionStep> steps,
  }) async {
    _logger.debug(
      'execute — operation: $operationName, steps: ${steps.length}',
    );
    try {
      await _database.inTransaction(() async {
        for (final step in steps) {
          _logger.debug('execute — step start: ${step.operation.name}');
          _failureInjection.beforeOperation(step.operation);
          await step.run();
          _logger.debug('execute — step complete: ${step.operation.name}');
          _failureInjection.afterOperation(step.operation);
        }
      });
      _logger.debug('execute — commit: $operationName');
    } catch (e) {
      _logger.error('execute — rollback: $operationName', error: e);
      if (e is TransactionExecutionFailure) rethrow;
      throw TransactionExecutionFailure(
        operationName: operationName,
        message: 'Transaction failed: $operationName',
        cause: e,
      );
    }
  }
}
