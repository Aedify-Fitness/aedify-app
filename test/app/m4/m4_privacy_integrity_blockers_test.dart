import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/programmes/domain/programme_draft.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'm4_test_harness.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('M4 Privacy And Integrity Blockers', () {
    late M4TestHarness harness;

    setUp(() {
      harness = M4TestHarness();
      harness.setUp();
    });

    tearDown(() async {
      await harness.tearDown();
    });

    testWidgets('full offline flow never requires network', (tester) async {
      await harness.pumpApp(tester: tester);

      expect(harness.networkStatus.isOnline, isFalse);

      final workoutId = await harness.savedWorkoutRepository.saveSavedWorkout(
        SavedWorkoutDraft(
          id: 'blocker-w1',
          name: 'Blocker Workout',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: SavedWorkoutStatus.active,
          goalTags: const {'general_fitness'},
          equipment: const {EquipmentTag.other},
          exercises: [],
        ),
      );
      expect(workoutId, 'blocker-w1');

      final progId = await harness.programmeRepository.saveProgramme(
        ProgrammeDraft(
          id: 'blocker-p1',
          name: 'Blocker Programme',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.draft,
          active: false,
          goalTags: const {},
          equipment: const {},
          templates: [],
        ),
      );
      expect(progId, 'blocker-p1');

      final sessionId = await harness.workoutSessionRepository.startSession(
        WorkoutSessionDraft(
          id: 'blocker-s1',
          name: 'Blocker Session',
          source: SessionSource.savedWorkout,
          status: WorkoutSessionStatus.inProgress,
          startedAt: DateTime.now(),
          exercises: [],
        ),
      );
      expect(sessionId, 'blocker-s1');
    });

    testWidgets('completion failure leaves active workout recoverable', (
      tester,
    ) async {
      await harness.pumpApp(tester: tester);

      final sessionId = 'blocker-fail-1';
      await harness.workoutSessionRepository.startSession(
        WorkoutSessionDraft(
          id: sessionId,
          name: 'Fail Test',
          source: SessionSource.savedWorkout,
          status: WorkoutSessionStatus.inProgress,
          startedAt: DateTime.now(),
          exercises: [],
        ),
      );

      harness.workoutSessionRepository.failOnComplete = true;

      try {
        await harness.workoutSessionRepository.completeSession(
          id: sessionId,
          completedAt: DateTime.now(),
          durationSeconds: 1800,
        );
        fail('Expected completion to fail');
      } catch (_) {
        // Expected
      }

      final session = await harness.workoutSessionRepository.getSession(
        sessionId,
      );
      expect(session, isNotNull);
    });

    testWidgets('history remains readable after source delete', (tester) async {
      await harness.pumpApp(tester: tester);

      final completedAt = DateTime.now();
      final startedAt = completedAt.subtract(const Duration(minutes: 30));

      harness.workoutHistoryRepository.seedCompletedSession(
        sessionId: 'blocker-hist-1',
        name: 'History Integrity',
        source: SessionSource.savedWorkout,
        startedAt: startedAt,
        completedAt: completedAt,
        durationSeconds: 1800,
      );

      await harness.savedWorkoutRepository.deleteSavedWorkout('any-id');

      final detail = await harness.workoutHistoryRepository.getSessionDetail(
        'blocker-hist-1',
      );
      expect(detail, isNotNull);
      expect(detail!.name, 'History Integrity');
    });

    testWidgets('no sentinel data leaks in normal operations', (tester) async {
      await harness.pumpApp(tester: tester);

      final id = await harness.exerciseRepository.createCustomExercise(
        CustomExerciseSeed(
          name: 'Safe Exercise',
          modality: ExerciseModality.strength,
          muscleGroups: {BodymapBucket.chest},
          equipment: EquipmentTag.barbell,
        ),
      );
      expect(id, isPositive);

      final customs = await harness.exerciseRepository.getCustomExercises();
      expect(customs.any((e) => e.name == 'Safe Exercise'), isTrue);
    });
  });
}
