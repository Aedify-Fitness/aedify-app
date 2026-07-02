import 'package:aedify/core/logging/app_logger.dart';
import 'package:uuid/uuid.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/set_log_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_exercise_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_mapper.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

class StartWorkoutSessionUseCase {
  const StartWorkoutSessionUseCase({
    required WorkoutSessionRepository workoutSessionRepository,
    required SavedWorkoutRepository savedWorkoutRepository,
    required ProgrammeRepository programmeRepository,
    required ExerciseRepository exerciseRepository,
    required WorkoutRunnerMapper mapper,
    Uuid? uuid,
  }) : _workoutSessionRepository = workoutSessionRepository,
       _savedWorkoutRepository = savedWorkoutRepository,
       _programmeRepository = programmeRepository,
       _exerciseRepository = exerciseRepository,
       _mapper = mapper,
       _uuid = uuid ?? const Uuid();

  static final _logger = AppLogger(name: 'StartWorkoutSessionUseCase');

  final WorkoutSessionRepository _workoutSessionRepository;
  final SavedWorkoutRepository _savedWorkoutRepository;
  final ProgrammeRepository _programmeRepository;
  final ExerciseRepository _exerciseRepository;
  final WorkoutRunnerMapper _mapper;
  final Uuid _uuid;

  Future<WorkoutRunnerSessionViewData> startFromSavedWorkout(
    String savedWorkoutId,
  ) async {
    _logger.info('startFromSavedWorkout — id: $savedWorkoutId');
    final aggregate = await _savedWorkoutRepository.getSavedWorkout(
      savedWorkoutId,
    );
    if (aggregate == null) {
      throw StateError('Saved workout not found: $savedWorkoutId');
    }

    final now = DateTime.now();
    final sessionId = _uuid.v4();

    final exercises = aggregate.exercises.map((e) {
      final exerciseName = e.exerciseRef ?? e.exerciseId.toString();
      final exerciseSets = aggregate.sets
          .where((s) => s.savedWorkoutExerciseId == e.id)
          .toList();

      return WorkoutSessionExerciseDraft(
        id: _uuid.v4(),
        exerciseId: e.exerciseId,
        exerciseNameSnapshot: exerciseName,
        sortOrder: e.sortOrder,
        setLogs: exerciseSets
            .map(
              (s) => SetLogDraft(
                id: _uuid.v4(),
                exerciseId: e.exerciseId,
                setIndex: s.setIndex,
                setType: SetType.fromDb(s.setType),
                setIntent: SetIntent.fromDb(s.setIntent),
                prescribedRepsMin: s.prescribedRepsMin,
                prescribedRepsMax: s.prescribedRepsMax,
                prescribedWeightKg: s.prescribedWeightKg,
                prescribedRpeMin: s.prescribedRpeMin,
                prescribedRpeMax: s.prescribedRpeMax,
                performedAt: now,
                completed: false,
                skipped: false,
              ),
            )
            .toList(),
        sourceSavedWorkoutExerciseId: e.id,
        supersetGroupId: e.supersetGroupId,
        notes: e.notes,
      );
    }).toList();

    final draft = WorkoutSessionDraft(
      id: sessionId,
      source: SessionSource.savedWorkout,
      name: aggregate.savedWorkout.name,
      startedAt: now,
      status: WorkoutSessionStatus.inProgress,
      exercises: exercises,
      savedWorkoutId: savedWorkoutId,
    );

    await _workoutSessionRepository.startSession(draft);

    final aggregateResult = await _workoutSessionRepository.getSession(
      sessionId,
    );
    _logger.info('startFromSavedWorkout — success: $sessionId');
    return _mapper.toViewData(aggregateResult!);
  }

  Future<WorkoutRunnerSessionViewData> startFromProgramWorkout({
    required String programId,
    required String programWorkoutId,
  }) async {
    _logger.info(
      'startFromProgramWorkout — programId: $programId, workoutId: $programWorkoutId',
    );
    final aggregate = await _programmeRepository.getProgramme(programId);
    if (aggregate == null) {
      throw StateError('Programme not found: $programId');
    }

    final workout = aggregate.workouts.firstWhere(
      (w) => w.id == programWorkoutId,
    );
    final now = DateTime.now();
    final sessionId = _uuid.v4();

    final programExercises = aggregate.exercises
        .where((e) => e.programWorkoutId == programWorkoutId)
        .toList();

    final nameMap = await _buildExerciseNameMap(
      programExercises.map((e) => e.exerciseId),
    );

    final exercises = programExercises.map((e) {
      final exerciseSets = aggregate.sets
          .where((s) => s.programExerciseId == e.id)
          .toList();

      return WorkoutSessionExerciseDraft(
        id: _uuid.v4(),
        exerciseId: e.exerciseId,
        exerciseNameSnapshot: nameMap[e.exerciseId] ?? e.exerciseId.toString(),
        sortOrder: e.sortOrder,
        setLogs: exerciseSets
            .map(
              (s) => SetLogDraft(
                id: _uuid.v4(),
                exerciseId: e.exerciseId,
                setIndex: s.setIndex,
                setType: SetType.fromDb(s.setType),
                setIntent: SetIntent.fromDb(s.setIntent),
                prescribedRepsMin: s.prescribedRepsMin,
                prescribedRepsMax: s.prescribedRepsMax,
                prescribedWeightKg: s.prescribedWeightKg,
                prescribedRpeMin: s.prescribedRpeMin,
                prescribedRpeMax: s.prescribedRpeMax,
                performedAt: now,
                completed: false,
                skipped: false,
              ),
            )
            .toList(),
        sourceProgramExerciseId: e.id,
        supersetGroupId: e.supersetGroupId,
        notes: e.notes,
      );
    }).toList();

    final draft = WorkoutSessionDraft(
      id: sessionId,
      source: SessionSource.program,
      name: workout.name,
      startedAt: now,
      status: WorkoutSessionStatus.inProgress,
      exercises: exercises,
      programId: programId,
      programWorkoutId: programWorkoutId,
    );

    await _workoutSessionRepository.startSession(draft);

    final aggregateResult = await _workoutSessionRepository.getSession(
      sessionId,
    );
    _logger.info('startFromProgramWorkout — success: $sessionId');
    return _mapper.toViewData(aggregateResult!);
  }

  Future<Map<int, String>> _buildExerciseNameMap(
    Iterable<int> exerciseIds,
  ) async {
    final map = <int, String>{};
    for (final id in exerciseIds) {
      final detail = await _exerciseRepository.getExerciseDetail(id);
      map[id] = detail?.name ?? id.toString();
    }
    return map;
  }
}
