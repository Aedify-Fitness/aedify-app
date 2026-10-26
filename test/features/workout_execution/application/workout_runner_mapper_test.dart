import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_aggregate.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/features/workout_execution/domain/set_log_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_exercise_draft.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_mapper.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

void main() {
  final mapper = const WorkoutRunnerMapper();
  final now = DateTime(2025, 6, 1, 10, 0, 0);

  final aggregate = WorkoutSessionAggregate(
    session: WorkoutSession(
      id: 'session-1',
      source: 'saved_workout',
      name: 'Morning Push',
      startedAt: now,
      status: 'in_progress',
      programId: null,
      programWorkoutId: null,
      savedWorkoutId: 'sw-1',
      completedAt: null,
      durationSeconds: null,
      bodyweightKgAtSession: null,
      notes: 'Feeling good',
      energyLevel: 7,
      perceivedDifficulty: 6,
      createdAt: now,
      updatedAt: now,
    ),
    exercises: [
      WorkoutSessionExercise(
        id: 'ex-1',
        workoutSessionId: 'session-1',
        exerciseId: 1,
        exerciseNameSnapshot: 'Bench Press',
        sortOrder: 0,
        sourceProgramExerciseId: null,
        sourceSavedWorkoutExerciseId: 'saved-ex-1',
        supersetGroupId: null,
        notes: null,
      ),
      WorkoutSessionExercise(
        id: 'ex-2',
        workoutSessionId: 'session-1',
        exerciseId: 2,
        exerciseNameSnapshot: 'Squat',
        sortOrder: 1,
        sourceProgramExerciseId: null,
        sourceSavedWorkoutExerciseId: null,
        supersetGroupId: null,
        notes: 'Deep',
      ),
    ],
    setLogs: [
      SetLog(
        id: 'set-1',
        workoutSessionExerciseId: 'ex-1',
        exerciseId: 1,
        performedAt: now,
        setIndex: 0,
        setType: 'working',
        setIntent: null,
        prescribedRepsMin: 8,
        prescribedRepsMax: 12,
        prescribedWeightKg: 60.0,
        prescribedRpeMin: null,
        prescribedRpeMax: null,
        actualReps: null,
        actualWeightKg: null,
        actualDurationSeconds: null,
        actualDistanceMeters: null,
        actualRpe: null,
        actualRir: null,
        completed: false,
        skipped: false,
        isPr: false,
        estimated1rmKg: null,
        notes: null,
        createdAt: now,
        updatedAt: now,
      ),
      SetLog(
        id: 'set-2',
        workoutSessionExerciseId: 'ex-1',
        exerciseId: 1,
        performedAt: now,
        setIndex: 1,
        setType: 'working',
        setIntent: null,
        prescribedRepsMin: 8,
        prescribedRepsMax: 12,
        prescribedWeightKg: 60.0,
        prescribedRpeMin: null,
        prescribedRpeMax: null,
        actualReps: null,
        actualWeightKg: null,
        actualDurationSeconds: null,
        actualDistanceMeters: null,
        actualRpe: null,
        actualRir: null,
        completed: false,
        skipped: false,
        isPr: false,
        estimated1rmKg: null,
        notes: null,
        createdAt: now,
        updatedAt: now,
      ),
    ],
  );

  group('toViewData', () {
    test('maps aggregate to view data correctly', () {
      final result = mapper.toViewData(aggregate);

      expect(result.sessionId, 'session-1');
      expect(result.name, 'Morning Push');
      expect(result.source, SessionSource.savedWorkout);
      expect(result.status, WorkoutSessionStatus.inProgress);
      expect(result.startedAt, now);
      expect(result.savedWorkoutId, 'sw-1');
      expect(result.notes, 'Feeling good');
      expect(result.energyLevel, 7);
      expect(result.perceivedDifficulty, 6);
    });

    test('maps exercises with set logs grouped by exercise', () {
      final result = mapper.toViewData(aggregate);

      expect(result.exercises, hasLength(2));
      expect(result.exercises[0].exerciseName, 'Bench Press');
      expect(result.exercises[0].sortOrder, 0);
      expect(result.exercises[0].sourceSavedWorkoutExerciseId, 'saved-ex-1');
      expect(result.exercises[1].exerciseName, 'Squat');
      expect(result.exercises[1].sortOrder, 1);
      expect(result.exercises[1].notes, 'Deep');
    });

    test('maps set items within each exercise', () {
      final result = mapper.toViewData(aggregate);

      final benchSets = result.exercises[0].sets;
      expect(benchSets, hasLength(2));
      expect(benchSets[0].id, 'set-1');
      expect(benchSets[0].setIndex, 0);
      expect(benchSets[0].setType, SetType.working);
      expect(benchSets[0].prescribedRepsMin, 8);
      expect(benchSets[0].prescribedRepsMax, 12);
      expect(benchSets[0].prescribedWeightKg, 60.0);
      expect(benchSets[0].completed, isFalse);
      expect(benchSets[0].skipped, isFalse);
      expect(benchSets[1].id, 'set-2');
      expect(benchSets[1].setIndex, 1);
    });

    test('squat has no sets', () {
      final result = mapper.toViewData(aggregate);

      expect(result.exercises[1].sets, isEmpty);
    });
  });

  group('toDraft', () {
    test('converts view data back to draft', () {
      final viewData = mapper.toViewData(aggregate);
      final draft = mapper.toDraft(viewData);

      expect(draft.id, 'session-1');
      expect(draft.source, SessionSource.savedWorkout);
      expect(draft.name, 'Morning Push');
      expect(draft.status, WorkoutSessionStatus.inProgress);
      expect(draft.savedWorkoutId, 'sw-1');
      expect(draft.notes, 'Feeling good');
      expect(draft.energyLevel, 7);
      expect(draft.perceivedDifficulty, 6);
    });

    test('preserves exercise and set data in round trip', () {
      final viewData = mapper.toViewData(aggregate);
      final draft = mapper.toDraft(viewData);

      expect(draft.exercises, hasLength(2));
      expect(draft.exercises[0].exerciseNameSnapshot, 'Bench Press');
      expect(draft.exercises[0].sortOrder, 0);
      expect(draft.exercises[0].sourceSavedWorkoutExerciseId, 'saved-ex-1');

      final benchSets = draft.exercises[0].setLogs;
      expect(benchSets, hasLength(2));
      expect(benchSets[0].setIndex, 0);
      expect(benchSets[0].setType, SetType.working);
      expect(benchSets[0].prescribedRepsMin, 8);
      expect(benchSets[0].completed, isFalse);
      expect(benchSets[1].setIndex, 1);
      expect(benchSets[1].setType, SetType.working);

      final squatSets = draft.exercises[1].setLogs;
      expect(squatSets, isEmpty);
    });

    test('creates new draft instance', () {
      final viewData = mapper.toViewData(aggregate);
      final draft = mapper.toDraft(viewData);

      expect(draft, isA<WorkoutSessionDraft>());
      expect(draft.exercises[0], isA<WorkoutSessionExerciseDraft>());
      expect(draft.exercises[0].setLogs[0], isA<SetLogDraft>());
    });
  });
}
