import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/set_effort.dart';
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
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/features/workout_execution/domain/workout_launch_strings.dart';

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
    _logger.info('startFromSavedWorkout');
    final aggregate = await _savedWorkoutRepository.getSavedWorkout(
      savedWorkoutId,
    );
    if (aggregate == null) {
      throw StateError(AppErrorStrings.workoutNotFoundWithId(savedWorkoutId));
    }

    final now = DateTime.now();
    final sessionId = _uuid.v4();
    final workoutRest = aggregate.savedWorkout.restBetweenExercisesSeconds;
    final details = await _buildExerciseDetails(
      aggregate.exercises.map((e) => e.exerciseId),
    );

    final exercises = aggregate.exercises.map((e) {
      final exerciseName =
          details[e.exerciseId]?.name ??
          e.exerciseRef ??
          e.exerciseId.toString();
      final exerciseSets = aggregate.sets
          .where((s) => s.savedWorkoutExerciseId == e.id)
          .toList();

      return WorkoutSessionExerciseDraft(
        id: _uuid.v4(),
        exerciseId: e.exerciseId,
        exerciseNameSnapshot: exerciseName,
        sortOrder: e.sortOrder,
        loggingType: e.loggingType == null
            ? details[e.exerciseId]?.loggingType
            : ExerciseLoggingType.fromDbWithDefault(e.loggingType),
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
                prescribedRepsExact: s.prescribedRepsExact,
                prescribedWeightKg: s.prescribedWeightKg,
                prescribedRpeMin: s.prescribedRpeMin,
                prescribedRpeMax: s.prescribedRpeMax,
                prescribedRir: s.prescribedRir,
                actualRpe: SetEffort.initialRpe(
                  rir: s.prescribedRir,
                  rpeMin: s.prescribedRpeMin,
                  rpeMax: s.prescribedRpeMax,
                ),
                actualRir: SetEffort.rirFromRpe(
                  SetEffort.initialRpe(
                    rir: s.prescribedRir,
                    rpeMin: s.prescribedRpeMin,
                    rpeMax: s.prescribedRpeMax,
                  ),
                ),
                prescribedDurationSeconds: s.durationSeconds,
                prescribedDistanceMeters: s.distanceMeters,
                restSeconds: s.restSeconds,
                performedAt: now,
                completed: false,
                skipped: false,
              ),
            )
            .toList(),
        sourceSavedWorkoutExerciseId: e.id,
        supersetGroupId: e.supersetGroupId,
        restBetweenExercisesSeconds:
            e.restBetweenExercisesSeconds ?? workoutRest,
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
    _logger.info('startFromSavedWorkout succeeded');
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

    final int? workoutRest;
    if (workout.workoutTemplateId != null) {
      final found = aggregate.templates.where(
        (t) => t.id == workout.workoutTemplateId,
      );
      workoutRest = found.isNotEmpty
          ? found.first.restBetweenExercisesSeconds
          : null;
    } else {
      workoutRest = null;
    }

    final programExercises = aggregate.exercises
        .where((e) => e.programWorkoutId == programWorkoutId)
        .toList();

    final nameMap = await _buildExerciseNameMap(
      programExercises.map((e) => e.exerciseId),
    );
    final details = await _buildExerciseDetails(
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
        loggingType: details[e.exerciseId]?.loggingType,
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
                prescribedRepsExact: s.prescribedRepsExact,
                prescribedWeightKg: s.prescribedWeightKg,
                prescribedRpeMin: s.prescribedRpeMin,
                prescribedRpeMax: s.prescribedRpeMax,
                prescribedRir: s.prescribedRir,
                actualRpe: SetEffort.initialRpe(
                  rir: s.prescribedRir,
                  rpeMin: s.prescribedRpeMin,
                  rpeMax: s.prescribedRpeMax,
                ),
                actualRir: SetEffort.rirFromRpe(
                  SetEffort.initialRpe(
                    rir: s.prescribedRir,
                    rpeMin: s.prescribedRpeMin,
                    rpeMax: s.prescribedRpeMax,
                  ),
                ),
                prescribedDurationSeconds: s.durationSeconds,
                prescribedDistanceMeters: s.distanceMeters,
                restSeconds: s.restSeconds,
                performedAt: now,
                completed: false,
                skipped: false,
              ),
            )
            .toList(),
        sourceProgramExerciseId: e.id,
        supersetGroupId: e.supersetGroupId,
        restBetweenExercisesSeconds: workoutRest,
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

  /// Starts a local session without requiring a saved plan.
  Future<WorkoutRunnerSessionViewData> startStandalone() async {
    final draft = WorkoutSessionDraft(
      id: _uuid.v4(),
      source: SessionSource.standalone,
      name: WorkoutLaunchStrings.standaloneName,
      startedAt: DateTime.now(),
      status: WorkoutSessionStatus.inProgress,
      exercises: const [],
    );
    await _workoutSessionRepository.startSession(draft);
    return _mapper.toViewData(
      (await _workoutSessionRepository.getSession(draft.id))!,
    );
  }

  /// Creates a new session from the saved historical snapshot, with fresh IDs
  /// and no actual results or links that could change the original programme.
  Future<WorkoutRunnerSessionViewData> repeatCompleted(String sessionId) async {
    final previous = await _workoutSessionRepository.getSession(sessionId);
    if (previous == null ||
        previous.session.status != WorkoutSessionStatus.completed.dbValue ||
        previous.exercises.isEmpty) {
      throw StateError(AppErrorStrings.workoutCannotRepeat);
    }
    final now = DateTime.now();
    final groups = <String, String>{};
    final details = await _buildExerciseDetails(
      previous.setLogs.map((set) => set.exerciseId),
    );
    final exercises = <WorkoutSessionExerciseDraft>[];
    for (final exercise in previous.exercises) {
      final logs = previous.setLogs
          .where((set) => set.workoutSessionExerciseId == exercise.id)
          .toList();
      // A mid-session swap can retain completed logs for the original exercise.
      // Give each performed exercise its own entry in the new session.
      for (final exerciseId in logs.map((set) => set.exerciseId).toSet()) {
        final ownLogs = logs
            .where((set) => set.exerciseId == exerciseId)
            .toList();
        exercises.add(
          WorkoutSessionExerciseDraft(
            id: _uuid.v4(),
            exerciseId: exerciseId,
            exerciseNameSnapshot: exerciseId == exercise.exerciseId
                ? exercise.exerciseNameSnapshot
                : details[exerciseId]?.name ?? exerciseId.toString(),
            sortOrder: exercises.length,
            loggingType: exerciseId == exercise.exerciseId
                ? (exercise.loggingType == null
                      ? null
                      : ExerciseLoggingType.fromDbWithDefault(
                          exercise.loggingType,
                        ))
                : details[exerciseId]?.loggingType,
            supersetGroupId: exercise.supersetGroupId == null
                ? null
                : groups.putIfAbsent(exercise.supersetGroupId!, _uuid.v4),
            restBetweenExercisesSeconds: exercise.restBetweenExercisesSeconds,
            notes: exercise.notes,
            setLogs: ownLogs.indexed.map((entry) {
              final set = entry.$2;
              return SetLogDraft(
                id: _uuid.v4(),
                exerciseId: exerciseId,
                setIndex: entry.$1,
                setType: SetType.fromDb(set.setType),
                setIntent: SetIntent.fromDb(set.setIntent),
                prescribedRepsMin: set.prescribedRepsMin,
                prescribedRepsMax: set.prescribedRepsMax,
                prescribedRepsExact:
                    set.prescribedRepsExact ??
                    (set.prescribedRepsMin == null &&
                            set.prescribedRepsMax == null
                        ? set.actualReps
                        : null),
                prescribedWeightKg:
                    set.prescribedWeightKg ?? set.actualWeightKg,
                prescribedRpeMin: set.prescribedRpeMin,
                prescribedRpeMax: set.prescribedRpeMax,
                prescribedRir: set.prescribedRir,
                actualRpe: SetEffort.initialRpe(
                  rir: set.prescribedRir,
                  rpeMin: set.prescribedRpeMin,
                  rpeMax: set.prescribedRpeMax,
                ),
                actualRir: SetEffort.rirFromRpe(
                  SetEffort.initialRpe(
                    rir: set.prescribedRir,
                    rpeMin: set.prescribedRpeMin,
                    rpeMax: set.prescribedRpeMax,
                  ),
                ),
                prescribedDurationSeconds:
                    set.prescribedDurationSeconds ?? set.actualDurationSeconds,
                prescribedDistanceMeters:
                    set.prescribedDistanceMeters ?? set.actualDistanceMeters,
                restSeconds: set.restSeconds,
                performedAt: now,
                completed: false,
                skipped: false,
              );
            }).toList(),
          ),
        );
      }
    }
    if (exercises.isEmpty) {
      throw StateError(AppErrorStrings.workoutCannotRepeat);
    }
    final draft = WorkoutSessionDraft(
      id: _uuid.v4(),
      source: SessionSource.standalone,
      name: previous.session.name,
      startedAt: now,
      status: WorkoutSessionStatus.inProgress,
      exercises: exercises,
    );
    await _workoutSessionRepository.startSession(draft);
    return _mapper.toViewData(
      (await _workoutSessionRepository.getSession(draft.id))!,
    );
  }

  Future<Map<int, ExerciseDetailViewData?>> _buildExerciseDetails(
    Iterable<int> ids,
  ) async {
    final details = <int, ExerciseDetailViewData?>{};
    for (final id in ids.toSet()) {
      details[id] = await _exerciseRepository.getExerciseDetail(id);
    }
    return details;
  }
}
