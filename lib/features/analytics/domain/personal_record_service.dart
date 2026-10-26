import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

/// Rebuilds strength records from completed working-set evidence in pure Dart.
///
/// Supply the entire relevant exercise history from the analytics repository;
/// filtering by a display date range first would create false baselines. The
/// first eligible set establishes a baseline per exercise/type/load comparison.
/// Strict improvements create subsequent achievements; ties keep the earliest.
/// Volume means single-set kg × reps, not session volume. Zero-load weighted
/// sets contribute rep records only. Reps-only strength uses a separate rep
/// record and ignores residual hidden load fields. Unknown modes/modalities,
/// timed/cardio exercises and invalid actuals cannot produce strength records.
/// e1RM records are reserved for the e1RM ticket.
class PersonalRecordService {
  const PersonalRecordService();

  /// Detects records without mutating [logs] or persisting derived flags.
  ///
  /// Ordering uses performance time, session, membership, set index and set ID
  /// so equal timestamps produce the same result regardless of input order.
  PersonalRecordSummary detect(Iterable<AnalyticsSetLog> logs) {
    final ordered = logs.toList()..sort(_compareLogs);
    final best =
        <
          ({int exerciseId, PersonalRecordType type, double? weightKg}),
          PersonalRecord
        >{};
    final history = <PersonalRecord>[];

    void consider(
      AnalyticsSetLog log,
      PersonalRecordType type,
      num value, {
      double? weightKg,
    }) {
      final key = (exerciseId: log.exerciseId, type: type, weightKg: weightKg);
      final previous = best[key];
      if (previous != null && value <= previous.value) return;
      final record = PersonalRecord(
        exerciseId: log.exerciseId,
        type: type,
        value: value,
        previousValue: previous?.value,
        comparisonWeightKg: weightKg,
        setLogId: log.id,
        sessionId: log.sessionId,
        achievedAt: log.performedAt,
      );
      best[key] = record;
      history.add(record);
    }

    for (final log in ordered) {
      final reps = log.actualReps;
      if (log.modality != ExerciseModality.strength ||
          reps == null ||
          reps <= 0) {
        continue;
      }
      if (log.loggingType == ExerciseLoggingType.repsOnly) {
        consider(log, PersonalRecordType.maxReps, reps);
        continue;
      }
      final weight = log.actualWeightKg;
      if (log.loggingType != ExerciseLoggingType.repsWeight ||
          weight == null ||
          !weight.isFinite ||
          weight < 0) {
        continue;
      }
      if (weight > 0) {
        consider(log, PersonalRecordType.maxWeight, weight);
      }
      consider(log, PersonalRecordType.maxRepsAtWeight, reps, weightKg: weight);
      final volume = weight * reps;
      if (volume.isFinite && volume > 0) {
        consider(log, PersonalRecordType.volume, volume);
      }
    }
    return PersonalRecordSummary(current: best.values, history: history);
  }

  static int _compareLogs(AnalyticsSetLog left, AnalyticsSetLog right) {
    var order = left.performedAt.compareTo(right.performedAt);
    if (order != 0) return order;
    order = left.sessionId.compareTo(right.sessionId);
    if (order != 0) return order;
    order = left.sessionExerciseId.compareTo(right.sessionExerciseId);
    if (order != 0) return order;
    order = left.setIndex.compareTo(right.setIndex);
    return order != 0 ? order : left.id.compareTo(right.id);
  }
}
