import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/features/programmes/application/programme_workout_detail_controller.dart';
import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/workout_detail_button_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SavedRepository implements SavedWorkoutRepository {
  List<SavedWorkoutAggregate> workouts = [_Fixtures.saved()];
  bool shouldThrow = false;
  Completer<List<SavedWorkoutAggregate>>? pending;
  Completer<void>? loadStarted;
  int loads = 0;

  @override
  Future<List<SavedWorkoutAggregate>> listSavedWorkouts({
    String? status,
  }) async {
    loads++;
    if (shouldThrow) throw StateError('fixture storage failure');
    final waiting = pending;
    if (waiting != null) {
      loadStarted?.complete();
      return waiting.future;
    }
    return workouts;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProgrammeRepository implements ProgrammeRepository {
  ProgrammeAggregate? aggregate = _Fixtures.programme();
  bool shouldThrow = false;

  @override
  Future<ProgrammeAggregate?> getProgramme(String id) async {
    if (shouldThrow) throw StateError('fixture storage failure');
    return aggregate;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SessionDao extends WorkoutSessionDao {
  _SessionDao(super.db);

  WorkoutSession? active;
  List<WorkoutSession> completed = [];

  @override
  Future<WorkoutSession?> getActiveSession() async => active;

  @override
  Future<List<WorkoutSession>> getCompletedByProgramWorkoutIds(
    List<String> programWorkoutIds,
  ) async => completed;
}

class _ExerciseDao extends ExerciseDao {
  _ExerciseDao(super.db);

  @override
  Future<Exercise?> getExerciseById(int id) async => _Fixtures.exercise(id);
}

class _Fixtures {
  _Fixtures._();

  static final now = DateTime(2026, 10, 23);
  static const savedArgs = (programId: null, workoutId: 'saved');
  static const programmeArgs = (programId: 'programme', workoutId: 'workout-0');

  static SavedWorkoutAggregate saved({String? loggingType = 'duration'}) {
    return SavedWorkoutAggregate(
      savedWorkout: SavedWorkout(
        id: 'saved',
        name: 'Steady session',
        source: 'manual',
        creationMethod: 'manual',
        status: 'active',
        goalTagsJson: '[]',
        equipmentJson: '[]',
        imported: false,
        createdAt: now,
        updatedAt: now,
      ),
      exercises: [
        SavedWorkoutExercise(
          id: 'saved-exercise',
          savedWorkoutId: 'saved',
          exerciseId: 1,
          loggingType: loggingType,
          sortOrder: 0,
          createdAt: now,
        ),
      ],
      sets: [
        SavedWorkoutExerciseSet(
          id: 'saved-working',
          savedWorkoutExerciseId: 'saved-exercise',
          setIndex: 1,
          setType: 'working',
          durationSeconds: 60,
          isCalibrationEstimate: false,
          createdAt: now,
        ),
        SavedWorkoutExerciseSet(
          id: 'saved-warmup',
          savedWorkoutExerciseId: 'saved-exercise',
          setIndex: 0,
          setType: 'warmup',
          durationSeconds: 30,
          restSeconds: 45,
          loadSelectionNote: 'Use a comfortable effort.',
          isCalibrationEstimate: false,
          createdAt: now,
        ),
      ],
    );
  }

  static ProgrammeAggregate programme({bool scheduled = true}) =>
      ProgrammeAggregate(
        program: Program(
          id: 'programme',
          name: 'Steady programme',
          source: 'manual',
          creationMethod: 'manual',
          status: 'active',
          active: true,
          goalTagsJson: '[]',
          equipmentJson: '[]',
          imported: false,
          sourceFileRetained: false,
          createdAt: now,
          updatedAt: now,
        ),
        templates: [],
        weeks: [
          const ProgramWeek(id: 'week', programId: 'programme', weekNumber: 1),
        ],
        workouts: [
          for (var day = 0; day < 2; day++)
            ProgramWorkout(
              id: 'workout-$day',
              programId: 'programme',
              programWeekId: 'week',
              occurrenceRef: 'day-$day',
              name: 'Session $day',
              scheduledDayIndex: scheduled ? day : null,
              status: 'planned',
              createdAt: now,
              updatedAt: now,
            ),
        ],
        exercises: const [],
        sets: const [],
        revisions: const [],
      );

  static WorkoutSession session({
    String? programId,
    String? programWorkoutId,
    String? savedWorkoutId,
    bool completed = false,
  }) => WorkoutSession(
    id: completed ? 'completed' : 'active',
    source: programId == null ? 'saved_workout' : 'programme',
    programId: programId,
    programWorkoutId: programWorkoutId,
    savedWorkoutId: savedWorkoutId,
    name: 'Session',
    status: completed ? 'completed' : 'in_progress',
    startedAt: now,
    completedAt: completed ? now : null,
    createdAt: now,
    updatedAt: now,
  );

  static Exercise exercise(int id) => Exercise(
    id: id,
    isCustom: false,
    source: 'test',
    name: 'Exercise $id',
    nameNormalized: 'exercise $id',
    primaryMusclesJson: '[]',
    muscleGroupsJson: '[]',
    modality: 'strength',
    loggingType: 'repsWeight',
    gripsJson: '[]',
    stepsJson: '[]',
    isFavorite: false,
    isSubstitutedOut: false,
    importedFromShare: false,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AppDatabase database;
  late _SavedRepository savedRepository;
  late _ProgrammeRepository programmeRepository;
  late _SessionDao sessions;
  late ProviderContainer container;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    savedRepository = _SavedRepository();
    programmeRepository = _ProgrammeRepository();
    sessions = _SessionDao(database);
    container = ProviderContainer(
      overrides: [
        AppProviders.savedWorkoutRepositoryProvider.overrideWithValue(
          savedRepository,
        ),
        AppProviders.programmeRepositoryProvider.overrideWithValue(
          programmeRepository,
        ),
        AppProviders.workoutSessionDaoProvider.overrideWithValue(sessions),
        AppProviders.exerciseDaoProvider.overrideWithValue(
          _ExerciseDao(database),
        ),
        AppProviders.activeWorkoutSessionProvider.overrideWith(
          (ref) async => null,
        ),
      ],
    );
    await container.read(AppProviders.activeWorkoutSessionProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  group('saved workout action guards', () {
    test('starts when no session is active', () async {
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider(
          _Fixtures.savedArgs,
        ).future,
      );
      expect(detail!.buttonState, WorkoutDetailButtonState.start);
      expect(detail.workoutName, 'Steady session');
    });

    test('resumes the matching saved workout', () async {
      sessions.active = _Fixtures.session(savedWorkoutId: 'saved');
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider(
          _Fixtures.savedArgs,
        ).future,
      );
      expect(detail!.buttonState, WorkoutDetailButtonState.resume);
    });

    test('hides start while another workout is active', () async {
      sessions.active = _Fixtures.session(savedWorkoutId: 'another');
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider(
          _Fixtures.savedArgs,
        ).future,
      );
      expect(detail!.buttonState, WorkoutDetailButtonState.hidden);
    });

    test('returns null for a missing saved workout', () async {
      savedRepository.workouts = [];
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider(
          _Fixtures.savedArgs,
        ).future,
      );
      expect(detail, isNull);
    });
  });

  group('programme workout action guards', () {
    test('starts the current scheduled occurrence', () async {
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider(
          _Fixtures.programmeArgs,
        ).future,
      );
      expect(detail!.buttonState, WorkoutDetailButtonState.start);
      expect(detail.programmeName, 'Steady programme');
      expect(detail.dayLabel, 'Monday');
    });

    test('hides start for a future occurrence', () async {
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider((
          programId: 'programme',
          workoutId: 'workout-1',
        )).future,
      );
      expect(detail!.buttonState, WorkoutDetailButtonState.hidden);
    });

    test('does not invent a weekday for an unscheduled occurrence', () async {
      programmeRepository.aggregate = _Fixtures.programme(scheduled: false);
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider(
          _Fixtures.programmeArgs,
        ).future,
      );
      expect(detail!.workoutName, 'Session 0');
      expect(detail.dayLabel, isEmpty);
      expect(detail.buttonState, WorkoutDetailButtonState.hidden);
    });

    test('resumes a matching programme and occurrence', () async {
      sessions.active = _Fixtures.session(
        programId: 'programme',
        programWorkoutId: 'workout-0',
      );
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider(
          _Fixtures.programmeArgs,
        ).future,
      );
      expect(detail!.buttonState, WorkoutDetailButtonState.resume);
    });

    test(
      'does not resume an occurrence belonging to another programme',
      () async {
        sessions.active = _Fixtures.session(
          programId: 'other-programme',
          programWorkoutId: 'workout-0',
        );
        final detail = await container.read(
          AppProviders.workoutDetailControllerProvider(
            _Fixtures.programmeArgs,
          ).future,
        );
        expect(detail!.buttonState, WorkoutDetailButtonState.hidden);
      },
    );

    test('hides start while another saved workout is active', () async {
      sessions.active = _Fixtures.session(savedWorkoutId: 'saved');
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider(
          _Fixtures.programmeArgs,
        ).future,
      );
      expect(detail!.buttonState, WorkoutDetailButtonState.hidden);
    });

    test(
      'completed occurrence remains hidden with a matching active session',
      () async {
        sessions.active = _Fixtures.session(
          programId: 'programme',
          programWorkoutId: 'workout-0',
        );
        sessions.completed = [
          _Fixtures.session(
            programId: 'programme',
            programWorkoutId: 'workout-0',
            completed: true,
          ),
        ];
        final detail = await container.read(
          AppProviders.workoutDetailControllerProvider(
            _Fixtures.programmeArgs,
          ).future,
        );
        expect(detail!.buttonState, WorkoutDetailButtonState.hidden);
      },
    );

    test('returns null when the programme is missing', () async {
      programmeRepository.aggregate = null;
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider(
          _Fixtures.programmeArgs,
        ).future,
      );
      expect(detail, isNull);
    });

    test('returns null when the occurrence is missing', () async {
      final detail = await container.read(
        AppProviders.workoutDetailControllerProvider((
          programId: 'programme',
          workoutId: 'missing',
        )).future,
      );
      expect(detail, isNull);
    });
  });

  group('refresh and failure recovery', () {
    test('reports initial repository errors through provider state', () async {
      savedRepository.shouldThrow = true;
      final provider = AppProviders.workoutDetailControllerProvider(
        _Fixtures.savedArgs,
      );
      await expectLater(container.read(provider.future), throwsStateError);
      expect(container.read(provider).hasError, isTrue);
    });

    test('reports programme load errors through provider state', () async {
      programmeRepository.shouldThrow = true;
      final provider = AppProviders.workoutDetailControllerProvider(
        _Fixtures.programmeArgs,
      );
      await expectLater(container.read(provider.future), throwsStateError);
      expect(container.read(provider).hasError, isTrue);
    });

    test('reload re-evaluates active-session eligibility', () async {
      final provider = AppProviders.workoutDetailControllerProvider(
        _Fixtures.savedArgs,
      );
      await container.read(provider.future);
      sessions.active = _Fixtures.session(savedWorkoutId: 'saved');
      await container.read(provider.notifier).reload();
      expect(
        container.read(provider).requireValue!.buttonState,
        WorkoutDetailButtonState.resume,
      );
    });

    test(
      'reload failure is retryable without escaping to the caller',
      () async {
        final provider = AppProviders.workoutDetailControllerProvider(
          _Fixtures.savedArgs,
        );
        await container.read(provider.future);
        savedRepository.shouldThrow = true;
        await container.read(provider.notifier).reload();
        expect(container.read(provider).hasError, isTrue);
        savedRepository.shouldThrow = false;
        await container.read(provider.notifier).reload();
        expect(container.read(provider).hasError, isFalse);
        expect(
          container.read(provider).requireValue!.workoutName,
          'Steady session',
        );
      },
    );

    for (final args in [_Fixtures.savedArgs, _Fixtures.programmeArgs]) {
      test('refresh trigger re-evaluates ${args.workoutId}', () async {
        final provider = AppProviders.workoutDetailControllerProvider(args);
        await container.read(provider.future);
        sessions.active = _Fixtures.session(savedWorkoutId: 'another');
        container
            .read(AppProviders.homeRefreshTriggerProvider.notifier)
            .state++;
        await container.read(provider.future);
        expect(
          container.read(provider).requireValue!.buttonState,
          WorkoutDetailButtonState.hidden,
        );
      });

      test('active-session changes re-evaluate ${args.workoutId}', () async {
        final provider = AppProviders.workoutDetailControllerProvider(args);
        await container.read(provider.future);
        sessions.active = _Fixtures.session(savedWorkoutId: 'another');
        container.invalidate(AppProviders.activeWorkoutSessionProvider);
        await container.read(AppProviders.activeWorkoutSessionProvider.future);
        final detail = await container.read(provider.future);
        expect(detail!.buttonState, WorkoutDetailButtonState.hidden);
      });
    }

    test('a pending reload can finish after provider disposal', () async {
      final provider = AppProviders.workoutDetailControllerProvider(
        _Fixtures.savedArgs,
      );
      await container.read(provider.future);
      final pending = Completer<List<SavedWorkoutAggregate>>();
      final started = Completer<void>();
      savedRepository.pending = pending;
      savedRepository.loadStarted = started;
      final reloading = container.read(provider.notifier).reload();
      await started.future;
      container.invalidate(provider);
      await reloading;
      expect(pending.isCompleted, isFalse);
      pending.complete([_Fixtures.saved()]);
    });

    test('an older reload cannot replace a newer refresh result', () async {
      final provider = AppProviders.workoutDetailControllerProvider(
        _Fixtures.savedArgs,
      );
      await container.read(provider.future);
      final pending = Completer<List<SavedWorkoutAggregate>>();
      final started = Completer<void>();
      savedRepository.pending = pending;
      savedRepository.loadStarted = started;
      final reloading = container.read(provider.notifier).reload();
      await started.future;
      savedRepository.pending = null;
      savedRepository.workouts = [];
      container.invalidate(provider);
      expect(await container.read(provider.future), isNull);
      pending.complete([_Fixtures.saved()]);
      await reloading;
      expect(container.read(provider).requireValue, isNull);
    });
  });

  group('prescription snapshots', () {
    test(
      'preserves duration occurrence even when reference type differs',
      () async {
        final detail = await container.read(
          AppProviders.workoutDetailControllerProvider(
            _Fixtures.savedArgs,
          ).future,
        );
        final exercise = detail!.exercises.single;
        expect(exercise.loggingType, ExerciseLoggingType.duration);
        expect(exercise.sets.map((set) => set.setType), ['warmup', 'working']);
        expect(exercise.sets.map((set) => set.durationSeconds), [30, 60]);
        expect(exercise.sets.first.restSeconds, 45);
        expect(exercise.sets.first.notes, 'Use a comfortable effort.');
      },
    );

    test(
      'preserves reps-only occurrence when the reference row is missing',
      () {
        final detail = ProgrammeWorkoutDetailController.buildSavedWorkoutDetail(
          _Fixtures.saved(loggingType: 'repsOnly'),
          {},
        );
        expect(
          detail!.exercises.single.loggingType,
          ExerciseLoggingType.repsOnly,
        );
      },
    );

    test('falls back to reference type for legacy occurrences', () {
      for (final loggingType in <String?>[null, '']) {
        final detail = ProgrammeWorkoutDetailController.buildSavedWorkoutDetail(
          _Fixtures.saved(loggingType: loggingType),
          {1: _Fixtures.exercise(1)},
        );
        expect(
          detail!.exercises.single.loggingType,
          ExerciseLoggingType.repsWeight,
        );
      }
    });

    test('does not mutate saved aggregate exercise ordering', () {
      final original = _Fixtures.saved();
      final exercises = [
        original.exercises.single.copyWith(id: 'second', sortOrder: 1),
        original.exercises.single,
      ];
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: original.savedWorkout,
        exercises: List.unmodifiable(exercises),
        sets: original.sets,
      );
      final detail = ProgrammeWorkoutDetailController.buildSavedWorkoutDetail(
        aggregate,
        {1: _Fixtures.exercise(1)},
      );
      expect(aggregate.exercises.first.id, 'second');
      expect(detail!.exercises.first.sets, isNotEmpty);
      expect(detail.exercises.last.sets, isEmpty);
    });
  });
}
