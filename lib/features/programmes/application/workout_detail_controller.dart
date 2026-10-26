import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/features/programmes/application/programme_workout_detail_controller.dart';
import 'package:aedify/features/programmes/application/today_workout_resolver.dart';
import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/domain/programme_workout_detail_view_data.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/shared/domain/workout_detail_button_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads local workout prescriptions and guards session entry actions.
class WorkoutDetailController
    extends AsyncNotifier<ProgrammeWorkoutDetailViewData?> {
  WorkoutDetailController(this._args);

  final ({String? programId, String workoutId}) _args;

  @override
  Future<ProgrammeWorkoutDetailViewData?> build() {
    ref.watch(AppProviders.homeRefreshTriggerProvider);
    ref.watch(AppProviders.activeWorkoutSessionProvider);
    final sessionDao = ref.read(AppProviders.workoutSessionDaoProvider);
    final exerciseDao = ref.read(AppProviders.exerciseDaoProvider);
    final programId = _args.programId;
    if (programId != null) {
      return _loadProgrammeDetail(
        ref.read(AppProviders.programmeRepositoryProvider),
        sessionDao,
        exerciseDao,
        programId,
      );
    }
    return _loadSavedWorkoutDetail(
      ref.read(AppProviders.savedWorkoutRepositoryProvider),
      sessionDao,
      exerciseDao,
    );
  }

  /// Reloads local data and exposes recoverable failures through provider state.
  Future<void> reload() async {
    if (!ref.mounted) return;
    ref.invalidateSelf();
    final refreshed = future;
    final disposed = Completer<void>();
    final removeDisposeListener = ref.onDispose(disposed.complete);
    try {
      await Future.any<void>([
        AsyncValue.guard(() => refreshed).then((_) {}),
        disposed.future,
      ]);
    } finally {
      removeDisposeListener();
    }
  }

  Future<ProgrammeWorkoutDetailViewData?> _loadProgrammeDetail(
    ProgrammeRepository repository,
    WorkoutSessionDao sessionDao,
    ExerciseDao exerciseDao,
    String programId,
  ) async {
    final aggregate = await repository.getProgramme(programId);
    if (aggregate == null) return null;

    final resolution = await TodayWorkoutResolver(
      sessionDao: sessionDao,
    ).resolve(aggregate: aggregate, now: DateTime.now());
    final activeSession = await sessionDao.getActiveSession();
    final isCompleted = resolution.completedWorkoutIds.contains(
      _args.workoutId,
    );
    final isMatchingSession =
        activeSession != null &&
        activeSession.programId == programId &&
        activeSession.programWorkoutId == _args.workoutId;

    final WorkoutDetailButtonState buttonState;
    if (isCompleted) {
      buttonState = WorkoutDetailButtonState.hidden;
    } else if (isMatchingSession) {
      buttonState = WorkoutDetailButtonState.resume;
    } else if (activeSession != null) {
      buttonState = WorkoutDetailButtonState.hidden;
    } else if (resolution.todayWorkoutId == _args.workoutId) {
      buttonState = WorkoutDetailButtonState.start;
    } else {
      buttonState = WorkoutDetailButtonState.hidden;
    }

    final exerciseModels = await _loadExerciseModels(
      exerciseDao,
      aggregate.exercises
          .where((exercise) => exercise.programWorkoutId == _args.workoutId)
          .map((exercise) => exercise.exerciseId),
    );
    return ProgrammeWorkoutDetailController.buildWorkoutDetail(
      aggregate,
      _args.workoutId,
      exerciseModels,
      buttonState: buttonState,
    );
  }

  Future<ProgrammeWorkoutDetailViewData?> _loadSavedWorkoutDetail(
    SavedWorkoutRepository repository,
    WorkoutSessionDao sessionDao,
    ExerciseDao exerciseDao,
  ) async {
    final aggregates = await repository.listSavedWorkouts();
    final aggregate = aggregates
        .where((aggregate) => aggregate.savedWorkout.id == _args.workoutId)
        .firstOrNull;
    if (aggregate == null) return null;

    final activeSession = await sessionDao.getActiveSession();
    final WorkoutDetailButtonState buttonState;
    if (activeSession?.savedWorkoutId == _args.workoutId) {
      buttonState = WorkoutDetailButtonState.resume;
    } else if (activeSession != null) {
      buttonState = WorkoutDetailButtonState.hidden;
    } else {
      buttonState = WorkoutDetailButtonState.start;
    }

    final exerciseModels = await _loadExerciseModels(
      exerciseDao,
      aggregate.exercises.map((exercise) => exercise.exerciseId),
    );
    return ProgrammeWorkoutDetailController.buildSavedWorkoutDetail(
      aggregate,
      exerciseModels,
      buttonState: buttonState,
    );
  }

  Future<Map<int, Exercise>> _loadExerciseModels(
    ExerciseDao dao,
    Iterable<int> exerciseIds,
  ) async {
    final exerciseModels = <int, Exercise>{};
    for (final id in exerciseIds.toSet()) {
      final exercise = await dao.getExerciseById(id);
      if (exercise != null) exerciseModels[id] = exercise;
    }
    return exerciseModels;
  }
}
