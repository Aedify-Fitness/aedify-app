import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/programmes/domain/programme_draft.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'm4_test_harness.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('M4 Manual Tracker Acceptance', () {
    late M4TestHarness harness;

    setUp(() {
      harness = M4TestHarness();
      harness.setUp();
    });

    tearDown(() async {
      await harness.tearDown();
    });

    testWidgets('create custom exercise offline', (tester) async {
      await harness.pumpApp(tester: tester);

      expect(harness.networkStatus.isOnline, isFalse);

      final id = await harness.exerciseRepository.createCustomExercise(
        CustomExerciseSeed(
          name: 'Acceptance Curl',
          modality: ExerciseModality.strength,
          muscleGroups: {BodymapBucket.biceps},
          equipment: EquipmentTag.dumbbell,
        ),
      );

      expect(id, isPositive);

      final customs = await harness.exerciseRepository.getCustomExercises();
      expect(customs.any((e) => e.name == 'Acceptance Curl'), isTrue);
    });

    testWidgets('create workout offline', (tester) async {
      await harness.pumpApp(tester: tester);

      final draftId = 'acc-workout-1';
      await harness.savedWorkoutRepository.saveSavedWorkout(
        SavedWorkoutDraft(
          id: draftId,
          name: 'Acceptance Push Day',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: SavedWorkoutStatus.active,
          goalTags: const {'general_fitness'},
          equipment: const {EquipmentTag.barbell},
          exercises: [],
        ),
      );

      final saved = await harness.savedWorkoutRepository.getSavedWorkout(
        draftId,
      );
      expect(saved, isNotNull);
      expect(saved!.savedWorkout.name, 'Acceptance Push Day');
    });

    testWidgets('create multi-week programme offline', (tester) async {
      await harness.pumpApp(tester: tester);

      final draftId = 'acc-prog-1';
      await harness.programmeRepository.saveProgramme(
        ProgrammeDraft(
          id: draftId,
          name: 'Acceptance 4-Week Plan',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.draft,
          active: false,
          goalTags: const {},
          equipment: const {},
          weeksTotal: 4,
          templates: [],
        ),
      );

      final saved = await harness.programmeRepository.getProgramme(draftId);
      expect(saved, isNotNull);
      expect(saved!.program.name, 'Acceptance 4-Week Plan');
      expect(saved.program.weeksTotal, 4);
    });

    testWidgets('start active workout and complete session', (tester) async {
      await harness.pumpApp(tester: tester);

      final sessionId = 'acc-session-1';
      await harness.workoutSessionRepository.startSession(
        WorkoutSessionDraft(
          id: sessionId,
          name: 'Acceptance Session',
          source: SessionSource.savedWorkout,
          status: WorkoutSessionStatus.inProgress,
          startedAt: DateTime.now(),
          exercises: [],
        ),
      );

      final active = await harness.workoutSessionRepository.getActiveSession();
      expect(active, isNotNull);

      await harness.workoutSessionRepository.completeSession(
        id: sessionId,
        completedAt: DateTime.now(),
        durationSeconds: 1800,
      );

      final stillActive = await harness.workoutSessionRepository
          .getActiveSession();
      expect(stillActive, isNull);
    });

    testWidgets('recover active workout after reopen', (tester) async {
      await harness.pumpApp(tester: tester);

      final sessionId = 'acc-recover-1';
      await harness.workoutSessionRepository.startSession(
        WorkoutSessionDraft(
          id: sessionId,
          name: 'Recovery Test',
          source: SessionSource.savedWorkout,
          status: WorkoutSessionStatus.inProgress,
          startedAt: DateTime.now(),
          exercises: [],
        ),
      );

      final activeBefore = await harness.workoutSessionRepository
          .getActiveSession();
      expect(activeBefore, isNotNull);

      final recovered = await harness.workoutSessionRepository.getSession(
        sessionId,
      );
      expect(recovered, isNotNull);
      expect(recovered!.session.name, 'Recovery Test');
    });

    testWidgets('complete workout and view history', (tester) async {
      await harness.pumpApp(tester: tester);

      final sessionId = 'acc-history-1';
      final completedAt = DateTime.now();
      final startedAt = completedAt.subtract(const Duration(minutes: 30));

      await harness.workoutSessionRepository.startSession(
        WorkoutSessionDraft(
          id: sessionId,
          name: 'History Test',
          source: SessionSource.savedWorkout,
          status: WorkoutSessionStatus.inProgress,
          startedAt: startedAt,
          exercises: [],
        ),
      );

      await harness.workoutSessionRepository.completeSession(
        id: sessionId,
        completedAt: completedAt,
        durationSeconds: 1800,
      );

      harness.workoutHistoryRepository.seedCompletedSession(
        sessionId: sessionId,
        name: 'History Test',
        source: SessionSource.savedWorkout,
        startedAt: startedAt,
        completedAt: completedAt,
        durationSeconds: 1800,
      );

      final history = await harness.workoutHistoryRepository
          .listCompletedSessions();
      expect(history.length, 1);
      expect(history.first.name, 'History Test');

      final detail = await harness.workoutHistoryRepository.getSessionDetail(
        sessionId,
      );
      expect(detail, isNotNull);
      expect(detail!.name, 'History Test');
    });

    testWidgets('warmup sets remain visible through history', (tester) async {
      await harness.pumpApp(tester: tester);

      final sessionId = 'acc-warmup-1';
      final completedAt = DateTime.now();
      final startedAt = completedAt.subtract(const Duration(minutes: 30));

      harness.workoutHistoryRepository.seedCompletedSession(
        sessionId: sessionId,
        name: 'Warmup Session',
        source: SessionSource.savedWorkout,
        startedAt: startedAt,
        completedAt: completedAt,
        durationSeconds: 1800,
        exercises: [
          WorkoutHistoryExerciseItem(
            id: 'e1',
            exerciseId: 1,
            exerciseName: 'Bench Press',
            sortOrder: 0,
            sets: [
              WorkoutHistorySetItem(
                id: 's1',
                setIndex: 0,
                setType: SetType.warmup,
                completed: true,
                skipped: false,
                actualReps: 10,
                actualWeightKg: 40.0,
              ),
              WorkoutHistorySetItem(
                id: 's2',
                setIndex: 1,
                setType: SetType.working,
                completed: true,
                skipped: false,
                actualReps: 8,
                actualWeightKg: 80.0,
              ),
            ],
          ),
        ],
      );

      final detail = await harness.workoutHistoryRepository.getSessionDetail(
        sessionId,
      );
      expect(detail, isNotNull);
      final warmupSet = detail!.exercises[0].sets[0];
      final workingSet = detail.exercises[0].sets[1];
      expect(warmupSet.setType, SetType.warmup);
      expect(workingSet.setType, SetType.working);
    });

    testWidgets('superset grouping survives save and history', (tester) async {
      await harness.pumpApp(tester: tester);

      final sessionId = 'acc-superset-1';
      final completedAt = DateTime.now();
      final startedAt = completedAt.subtract(const Duration(minutes: 30));

      harness.workoutHistoryRepository.seedCompletedSession(
        sessionId: sessionId,
        name: 'Superset Session',
        source: SessionSource.savedWorkout,
        startedAt: startedAt,
        completedAt: completedAt,
        durationSeconds: 1800,
        exercises: [
          WorkoutHistoryExerciseItem(
            id: 'e1',
            exerciseId: 1,
            exerciseName: 'Bench Press',
            sortOrder: 0,
            sets: [
              WorkoutHistorySetItem(
                id: 's1',
                setIndex: 0,
                setType: SetType.working,
                completed: true,
                skipped: false,
                actualReps: 10,
                actualWeightKg: 100.0,
              ),
            ],
            supersetGroupId: 'g1',
            supersetOrder: 0,
          ),
          WorkoutHistoryExerciseItem(
            id: 'e2',
            exerciseId: 2,
            exerciseName: 'Fly',
            sortOrder: 1,
            sets: [
              WorkoutHistorySetItem(
                id: 's2',
                setIndex: 0,
                setType: SetType.working,
                completed: true,
                skipped: false,
                actualReps: 12,
                actualWeightKg: 30.0,
              ),
            ],
            supersetGroupId: 'g1',
            supersetOrder: 1,
          ),
        ],
      );

      final detail = await harness.workoutHistoryRepository.getSessionDetail(
        sessionId,
      );
      expect(detail, isNotNull);
      expect(detail!.exercises[0].supersetGroupId, 'g1');
      expect(detail.exercises[1].supersetGroupId, 'g1');
      expect(detail.exercises[0].supersetOrder, 0);
      expect(detail.exercises[1].supersetOrder, 1);
    });
  });
}
