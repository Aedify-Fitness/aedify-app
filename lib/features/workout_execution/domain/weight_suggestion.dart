import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_policy.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/rpe_load_estimator.dart';
import 'package:aedify/shared/domain/set_effort.dart';
import 'package:aedify/shared/domain/set_type.dart';

enum LoadReferenceSource { history, currentWorkout, knownMax }

class LoadReference {
  const LoadReference({
    required this.id,
    required this.exerciseId,
    required this.weightKg,
    required this.performedAt,
    required this.source,
    this.reps,
    this.rpe,
  });
  final String id;
  final int exerciseId;
  final double weightKg;
  final int? reps;
  final double? rpe;
  final DateTime performedAt;
  final LoadReferenceSource source;

  double? get strengthKg => source == LoadReferenceSource.knownMax
      ? (weightKg.isFinite && weightKg > 0 ? weightKg : null)
      : reps == null || rpe == null
      ? null
      : RpeLoadEstimator.strengthEstimate(weightKg, reps!, rpe!);
}

class WeightSuggestionTarget {
  const WeightSuggestionTarget(this.reps, this.rpe);
  final int reps;
  final double rpe;
  bool get valid => RpeLoadEstimator.validTarget(reps, rpe);

  static WeightSuggestionTarget? fromSet(WorkoutRunnerSetItem set) {
    final reps =
        set.prescribedRepsExact ??
        set.prescribedRepsMin ??
        set.prescribedRepsMax;
    final rpe =
        set.prescribedRpeMin ??
        set.prescribedRpeMax ??
        SetEffort.rpeFromRir(set.prescribedRir);
    if (reps == null || rpe == null) return null;
    final target = WeightSuggestionTarget(reps, rpe);
    return target.valid ? target : null;
  }
}

class WeightSuggestionEvidence {
  const WeightSuggestionEvidence({
    required this.supported,
    this.references = const [],
  });
  final bool supported;
  final List<LoadReference> references;
}

class WeightSuggestion {
  const WeightSuggestion({
    required this.sessionId,
    required this.setId,
    required this.exerciseId,
    required this.target,
    required this.weightKg,
    required this.reference,
    required this.referenceCount,
  });
  final String sessionId;
  final String setId;
  final int exerciseId;
  final WeightSuggestionTarget target;
  final double weightKg;
  final LoadReference reference;
  final int referenceCount;
}

/// Ephemeral proposals only. No targets, actuals or analytics are persisted here.
abstract final class WeightSuggestionPolicy {
  static const historyAge = Duration(days: 90);
  static const historySetCount = 5;

  static bool supportsExercise({
    required String name,
    required String modality,
    String? equipment,
    String? loggingType,
  }) =>
      modality == 'strength' &&
      equipment?.toLowerCase() != 'bodyweight' &&
      (loggingType == null ||
          loggingType == ExerciseLoggingType.repsWeight.dbValue) &&
      !RegExp(
        r'\b(assisted|body[ -]?weight|pull[ -]?ups?|chin[ -]?ups?|push[ -]?ups?|sit[ -]?ups?|muscle[ -]?ups?|dips?)\b',
        caseSensitive: false,
      ).hasMatch(name);

  static WeightSuggestion? calculate({
    required WeightSuggestionEvidence evidence,
    required WorkoutRunnerSessionViewData session,
    required WorkoutRunnerExerciseItem exercise,
    required WorkoutRunnerSetItem set,
    required WeightSuggestionTarget target,
    required DateTime now,
  }) {
    if (session.status != WorkoutSessionStatus.inProgress ||
        !evidence.supported ||
        !target.valid ||
        set.setType != SetType.working ||
        set.completed ||
        set.skipped ||
        set.exerciseId != exercise.exerciseId ||
        WorkoutRunnerSetPolicy.loggingType(
              set,
              snapshot: exercise.loggingType,
            ) !=
            ExerciseLoggingType.repsWeight) {
      return null;
    }
    bool recent(LoadReference source) =>
        source.exerciseId == set.exerciseId &&
        !source.performedAt.isAfter(now) &&
        now.difference(source.performedAt) <= historyAge &&
        source.strengthKg != null;
    final current =
        <LoadReference>[
            for (final member in session.exercises)
              for (final log in member.sets)
                if (log.completed &&
                    !log.skipped &&
                    log.setType == SetType.working &&
                    log.actualWeightKg != null &&
                    log.actualReps != null &&
                    (WorkoutRunnerSetPolicy.loggingType(
                          log,
                          snapshot: log.exerciseId == member.exerciseId
                              ? member.loggingType
                              : null,
                        ) ==
                        ExerciseLoggingType.repsWeight))
                  LoadReference(
                    id: log.id,
                    exerciseId: log.exerciseId,
                    weightKg: log.actualWeightKg!,
                    reps: log.actualReps,
                    rpe: log.actualRpe ?? SetEffort.rpeFromRir(log.actualRir),
                    performedAt: log.performedAt,
                    source: LoadReferenceSource.currentWorkout,
                  ),
          ].where(recent).toList()
          ..sort((a, b) => b.performedAt.compareTo(a.performedAt));
    LoadReference? reference;
    var count = 1;
    if (current.isNotEmpty) {
      reference = current.first;
    } else {
      final history =
          evidence.references
              .where(
                (item) =>
                    item.source == LoadReferenceSource.history && recent(item),
              )
              .toList()
            ..sort((a, b) => b.performedAt.compareTo(a.performedAt));
      final selected = history.take(historySetCount).toList()
        ..sort((a, b) => a.strengthKg!.compareTo(b.strengthKg!));
      if (selected.isNotEmpty) {
        reference = selected[(selected.length - 1) ~/ 2];
        count = selected.length;
      } else {
        final anchors =
            evidence.references
                .where(
                  (item) =>
                      item.source == LoadReferenceSource.knownMax &&
                      recent(item),
                )
                .toList()
              ..sort((a, b) => b.performedAt.compareTo(a.performedAt));
        reference = anchors.firstOrNull;
      }
    }
    if (reference == null) return null;
    final load = RpeLoadEstimator.load(
      reference.strengthKg!,
      target.reps,
      target.rpe,
    );
    if (load == null || load <= 0) return null;
    return WeightSuggestion(
      sessionId: session.sessionId,
      setId: set.id,
      exerciseId: set.exerciseId,
      target: target,
      weightKg: load,
      reference: reference,
      referenceCount: count,
    );
  }
}
