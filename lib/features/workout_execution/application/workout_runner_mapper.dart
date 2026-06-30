import 'package:aedify/features/workout_execution/domain/set_log_draft.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_aggregate.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_exercise_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

class WorkoutRunnerMapper {
  const WorkoutRunnerMapper();

  WorkoutRunnerSessionViewData toViewData(WorkoutSessionAggregate aggregate) {
    final setLogsByExercise = <String, List<SetLog>>{};
    for (final log in aggregate.setLogs) {
      setLogsByExercise.putIfAbsent(log.workoutSessionExerciseId, () => []);
      setLogsByExercise[log.workoutSessionExerciseId]!.add(log);
    }

    final exercises = aggregate.exercises.map((e) {
      final logs = setLogsByExercise[e.id] ?? [];
      return WorkoutRunnerExerciseItem(
        id: e.id,
        exerciseId: e.exerciseId,
        exerciseName: e.exerciseNameSnapshot,
        sortOrder: e.sortOrder,
        sourceProgramExerciseId: e.sourceProgramExerciseId,
        sourceSavedWorkoutExerciseId: e.sourceSavedWorkoutExerciseId,
        sets: logs.map((l) {
          return WorkoutRunnerSetItem(
            id: l.id,
            exerciseId: l.exerciseId,
            setIndex: l.setIndex,
            setType: SetType.fromDb(l.setType),
            setIntent: SetIntent.fromDb(l.setIntent),
            prescribedRepsMin: l.prescribedRepsMin,
            prescribedRepsMax: l.prescribedRepsMax,
            prescribedWeightKg: l.prescribedWeightKg,
            prescribedRpeMin: l.prescribedRpeMin,
            prescribedRpeMax: l.prescribedRpeMax,
            actualReps: l.actualReps,
            actualWeightKg: l.actualWeightKg,
            actualDurationSeconds: l.actualDurationSeconds,
            actualDistanceMeters: l.actualDistanceMeters,
            actualRpe: l.actualRpe,
            actualRir: l.actualRir,
            performedAt: l.performedAt,
            completed: l.completed,
            skipped: l.skipped,
            notes: l.notes,
          );
        }).toList(),
        supersetGroupId: e.supersetGroupId,
        notes: e.notes,
      );
    }).toList();

    return WorkoutRunnerSessionViewData(
      sessionId: aggregate.session.id,
      name: aggregate.session.name,
      source: SessionSource.fromDb(aggregate.session.source)!,
      status: WorkoutSessionStatus.fromDb(aggregate.session.status),
      startedAt: aggregate.session.startedAt,
      exercises: exercises,
      programId: aggregate.session.programId,
      programWorkoutId: aggregate.session.programWorkoutId,
      savedWorkoutId: aggregate.session.savedWorkoutId,
      completedAt: aggregate.session.completedAt,
      durationSeconds: aggregate.session.durationSeconds,
      bodyweightKgAtSession: aggregate.session.bodyweightKgAtSession,
      notes: aggregate.session.notes,
      energyLevel: aggregate.session.energyLevel,
      perceivedDifficulty: aggregate.session.perceivedDifficulty,
    );
  }

  WorkoutSessionDraft toDraft(WorkoutRunnerSessionViewData viewData) {
    return WorkoutSessionDraft(
      id: viewData.sessionId,
      source: viewData.source,
      name: viewData.name,
      startedAt: viewData.startedAt,
      status: WorkoutSessionStatus.inProgress,
      exercises: viewData.exercises.map((e) {
        return WorkoutSessionExerciseDraft(
          id: e.id,
          exerciseId: e.exerciseId,
          exerciseNameSnapshot: e.exerciseName,
          sortOrder: e.sortOrder,
          setLogs: e.sets.map((s) {
            return SetLogDraft(
              id: s.id,
              exerciseId: s.exerciseId,
              setIndex: s.setIndex,
              setType: s.setType,
              setIntent: s.setIntent,
              prescribedRepsMin: s.prescribedRepsMin,
              prescribedRepsMax: s.prescribedRepsMax,
              prescribedWeightKg: s.prescribedWeightKg,
              prescribedRpeMin: s.prescribedRpeMin,
              prescribedRpeMax: s.prescribedRpeMax,
              actualReps: s.actualReps,
              actualWeightKg: s.actualWeightKg,
              actualDurationSeconds: s.actualDurationSeconds,
              actualDistanceMeters: s.actualDistanceMeters,
              actualRpe: s.actualRpe,
              actualRir: s.actualRir,
              performedAt: s.performedAt,
              completed: s.completed,
              skipped: s.skipped,
              notes: s.notes,
            );
          }).toList(),
          sourceProgramExerciseId: e.sourceProgramExerciseId,
          sourceSavedWorkoutExerciseId: e.sourceSavedWorkoutExerciseId,
          supersetGroupId: e.supersetGroupId,
          notes: e.notes,
        );
      }).toList(),
      programId: viewData.programId,
      programWorkoutId: viewData.programWorkoutId,
      savedWorkoutId: viewData.savedWorkoutId,
      bodyweightKgAtSession: viewData.bodyweightKgAtSession,
      notes: viewData.notes,
      energyLevel: viewData.energyLevel,
      perceivedDifficulty: viewData.perceivedDifficulty,
    );
  }
}
