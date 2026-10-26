import 'package:aedify/features/plateau_detection/domain/plateau_evaluation.dart';

/// Owns transactional derived flags and durable dismissal state in Drift.
abstract interface class PlateauRepository {
  Future<List<PlateauEvaluation>> recompute({required DateTime now});
  Stream<List<PlateauEvaluation>> watchEvaluations({
    required DateTime Function() now,
  });
  Future<void> dismiss(int exerciseId, {required DateTime now});
}
