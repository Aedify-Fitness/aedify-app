import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/transactions/drift_transaction_executor.dart';
import 'package:aedify/core/db/transactions/transaction_execution_failure.dart';
import 'package:aedify/core/db/transactions/transaction_operation.dart';
import 'package:aedify/core/db/transactions/transaction_step.dart';
import '../../../support/transactions/throwing_transaction_failure_injection.dart';
import '../../../support/transactions/capturing_transaction_failure_injection.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';

ExercisesCompanion _companion({required int id, required String name}) {
  final now = DateTime.now();
  return ExercisesCompanion(
    id: Value(id),
    name: Value(name),
    nameNormalized: Value(name.toLowerCase()),
    source: const Value('test'),
    modality: const Value('strength'),
    primaryMusclesJson: const Value('[]'),
    muscleGroupsJson: const Value('[]'),
    gripsJson: const Value('[]'),
    stepsJson: const Value('[]'),
    createdAt: Value(now),
    updatedAt: Value(now),
  );
}

void main() {
  late AppDatabase db;
  late ExerciseDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = ExerciseDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftTransactionExecutor', () {
    test('runs all steps in order', () async {
      final injection = CapturingTransactionFailureInjection();
      final executor = DriftTransactionExecutor(
        database: db,
        failureInjection: injection,
      );

      await executor.execute(
        operationName: 'test.steps',
        steps: [
          TransactionStep(
            operation: const TransactionOperation(name: 'step.one'),
            run: () =>
                dao.insertCustomExercise(_companion(id: 1, name: 'step-one')),
          ),
          TransactionStep(
            operation: const TransactionOperation(name: 'step.two'),
            run: () =>
                dao.insertCustomExercise(_companion(id: 2, name: 'step-two')),
          ),
        ],
      );

      expect(injection.beforeOperations, ['step.one', 'step.two']);
      expect(injection.afterOperations, ['step.one', 'step.two']);

      final rows = await dao.getAllExercises();
      expect(rows.length, 2);
      expect(rows[0].name, 'step-one');
      expect(rows[1].name, 'step-two');
    });

    test('rolls back when a step throws before operation', () async {
      final injection = ThrowingTransactionFailureInjection(
        failOnOperationName: 'step.two',
        failBefore: true,
      );
      final executor = DriftTransactionExecutor(
        database: db,
        failureInjection: injection,
      );

      try {
        await executor.execute(
          operationName: 'test.rollback_before',
          steps: [
            TransactionStep(
              operation: const TransactionOperation(name: 'step.one'),
              run: () => dao.insertCustomExercise(
                _companion(id: 1, name: 'should-rollback'),
              ),
            ),
            TransactionStep(
              operation: const TransactionOperation(name: 'step.two'),
              run: () async {},
            ),
          ],
        );
        fail('Expected exception');
      } on TransactionExecutionFailure {
        // expected
      }

      final rows = await dao.getAllExercises();
      expect(rows, isEmpty);
    });

    test('rolls back when a step throws after operation', () async {
      final injection = ThrowingTransactionFailureInjection(
        failOnOperationName: 'step.one',
        failBefore: false,
      );
      final executor = DriftTransactionExecutor(
        database: db,
        failureInjection: injection,
      );

      try {
        await executor.execute(
          operationName: 'test.rollback_after',
          steps: [
            TransactionStep(
              operation: const TransactionOperation(name: 'step.one'),
              run: () => dao.insertCustomExercise(
                _companion(id: 1, name: 'should-rollback'),
              ),
            ),
          ],
        );
        fail('Expected exception');
      } on TransactionExecutionFailure {
        // expected
      }

      final rows = await dao.getAllExercises();
      expect(rows, isEmpty);
    });

    test('wraps errors in TransactionExecutionFailure', () async {
      final executor = DriftTransactionExecutor(database: db);

      try {
        await executor.execute(
          operationName: 'test.wrap',
          steps: [
            TransactionStep(
              operation: const TransactionOperation(name: 'step.one'),
              run: () => throw StateError('deliberate'),
            ),
          ],
        );
        fail('Expected exception');
      } on TransactionExecutionFailure catch (e) {
        expect(e.operationName, 'test.wrap');
        expect(e.cause, isNotNull);
      }
    });
  });
}
