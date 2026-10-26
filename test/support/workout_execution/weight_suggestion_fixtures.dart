import 'package:aedify/features/workout_execution/domain/weight_suggestion.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

abstract final class WeightSuggestionFixtures {
  static final now = DateTime(2026, 10, 25, 12);
  static LoadReference reference({
    String id = 'history',
    double weight = 100,
    int reps = 5,
    double? rpe = 9,
    DateTime? date,
    LoadReferenceSource source = LoadReferenceSource.history,
    int exerciseId = 1,
  }) => LoadReference(
    id: id,
    exerciseId: exerciseId,
    weightKg: weight,
    reps: reps,
    rpe: rpe,
    performedAt: date ?? now.subtract(const Duration(days: 1)),
    source: source,
  );
  static WorkoutRunnerSetItem set({
    String id = 'active',
    bool completed = false,
    bool skipped = false,
    SetType type = SetType.working,
    int exerciseId = 1,
    double? weight,
    int? reps,
    double? rpe,
    bool targets = true,
    int index = 0,
  }) => WorkoutRunnerSetItem(
    id: id,
    exerciseId: exerciseId,
    setIndex: index,
    setType: type,
    performedAt: now,
    completed: completed,
    skipped: skipped,
    actualWeightKg: weight,
    actualReps: reps,
    actualRpe: rpe,
    prescribedRepsExact: targets ? 5 : null,
    prescribedRpeMin: targets ? 8 : null,
  );
  static WorkoutRunnerExerciseItem exercise({
    List<WorkoutRunnerSetItem>? sets,
    ExerciseLoggingType type = ExerciseLoggingType.repsWeight,
  }) => WorkoutRunnerExerciseItem(
    id: 'exercise',
    exerciseId: 1,
    exerciseName: 'Bench press',
    sortOrder: 0,
    sets: sets ?? [set()],
    loggingType: type,
  );
  static WorkoutRunnerSessionViewData session({
    WorkoutRunnerExerciseItem? member,
  }) => WorkoutRunnerSessionViewData(
    sessionId: 'session',
    name: 'Workout',
    source: SessionSource.standalone,
    status: WorkoutSessionStatus.inProgress,
    startedAt: now,
    exercises: [member ?? exercise()],
  );
  static WeightSuggestion? suggestion({
    List<LoadReference>? references,
    WorkoutRunnerExerciseItem? member,
    WeightSuggestionTarget target = const WeightSuggestionTarget(5, 8),
    bool supported = true,
  }) {
    final exercise = member ?? WeightSuggestionFixtures.exercise();
    return WeightSuggestionPolicy.calculate(
      evidence: WeightSuggestionEvidence(
        supported: supported,
        references: references ?? [reference()],
      ),
      session: session(member: exercise),
      exercise: exercise,
      set: exercise.sets.last,
      target: target,
      now: now,
    );
  }
}
