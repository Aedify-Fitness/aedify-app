import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/saved_workout_dao.dart';
import 'package:aedify/core/db/daos/saved_workout_exercise_dao.dart';
import 'package:aedify/core/db/daos/saved_workout_exercise_set_dao.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_exercise_draft.dart';
import 'dart:convert';

class DriftSavedWorkoutRepository implements SavedWorkoutRepository {
  DriftSavedWorkoutRepository({
    required AppDatabase database,
    required SavedWorkoutDao savedWorkoutDao,
    required SavedWorkoutExerciseDao savedWorkoutExerciseDao,
    required SavedWorkoutExerciseSetDao savedWorkoutExerciseSetDao,
  }) : _database = database,
       _savedWorkoutDao = savedWorkoutDao,
       _savedWorkoutExerciseDao = savedWorkoutExerciseDao,
       _savedWorkoutExerciseSetDao = savedWorkoutExerciseSetDao;

  final AppDatabase _database;
  final SavedWorkoutDao _savedWorkoutDao;
  final SavedWorkoutExerciseDao _savedWorkoutExerciseDao;
  final SavedWorkoutExerciseSetDao _savedWorkoutExerciseSetDao;

  @override
  Future<SavedWorkoutAggregate?> getSavedWorkout(String id) async {
    final savedWorkout = await _savedWorkoutDao.getById(id);
    if (savedWorkout == null) return null;
    return _buildAggregate(savedWorkout);
  }

  @override
  Future<List<SavedWorkoutAggregate>> listSavedWorkouts({
    String? status,
  }) async {
    final workouts = status != null
        ? await _savedWorkoutDao.getByStatus(status)
        : await _savedWorkoutDao.getAll();

    final results = <SavedWorkoutAggregate>[];
    for (final w in workouts) {
      results.add(await _buildAggregate(w));
    }
    return results;
  }

  @override
  Future<String> saveSavedWorkout(SavedWorkoutDraft draft) async {
    return _database.inTransaction(() async {
      final savedWorkoutId = draft.id;
      final now = DateTime.now();
      final existing = await _savedWorkoutDao.getById(savedWorkoutId);

      await _writeSavedWorkoutRoot(
        draft: draft,
        savedWorkoutId: savedWorkoutId,
        now: now,
        existing: existing,
      );

      await _deleteSavedWorkoutHierarchy(savedWorkoutId);

      for (final exercise in draft.exercises) {
        await _insertSavedWorkoutExercise(
          savedWorkoutId: savedWorkoutId,
          exercise: exercise,
          now: now,
        );
      }

      return savedWorkoutId;
    });
  }

  @override
  Future<void> archiveSavedWorkout(String id) async {
    final now = DateTime.now();
    await _savedWorkoutDao.archiveSavedWorkout(
      id: id,
      archivedAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteSavedWorkout(String id) async {
    final hasHistory = await _savedWorkoutDao
        .countSessionsReferencingSavedWorkout(id);
    if (hasHistory > 0) {
      final now = DateTime.now();
      await _savedWorkoutDao.archiveSavedWorkout(
        id: id,
        archivedAt: now,
        updatedAt: now,
      );
    } else {
      await _database.inTransaction(() async {
        await _deleteSavedWorkoutHierarchy(id);
        await _savedWorkoutDao.archiveSavedWorkout(
          id: id,
          archivedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }
  }

  Future<SavedWorkoutAggregate> _buildAggregate(
    SavedWorkout savedWorkout,
  ) async {
    final exercises = await _savedWorkoutExerciseDao.getBySavedWorkoutIdOrdered(
      savedWorkout.id,
    );

    final allSets = <SavedWorkoutExerciseSet>[];
    for (final e in exercises) {
      final sets = await _savedWorkoutExerciseSetDao
          .getBySavedWorkoutExerciseIdOrdered(e.id);
      allSets.addAll(sets);
    }

    return SavedWorkoutAggregate(
      savedWorkout: savedWorkout,
      exercises: exercises,
      sets: allSets,
    );
  }

  Future<void> _writeSavedWorkoutRoot({
    required SavedWorkoutDraft draft,
    required String savedWorkoutId,
    required DateTime now,
    required SavedWorkout? existing,
  }) async {
    final createdAt = existing?.createdAt ?? now;
    await _savedWorkoutDao.upsertSavedWorkout(
      _buildSavedWorkoutCompanion(
        draft: draft,
        savedWorkoutId: savedWorkoutId,
        now: now,
        createdAt: createdAt,
      ),
    );
  }

  Future<void> _deleteSavedWorkoutHierarchy(String savedWorkoutId) async {
    final exercises = await _savedWorkoutExerciseDao.getBySavedWorkoutIdOrdered(
      savedWorkoutId,
    );
    for (final e in exercises) {
      await _savedWorkoutExerciseSetDao.deleteBySavedWorkoutExerciseId(e.id);
    }
    await _savedWorkoutExerciseDao.deleteBySavedWorkoutId(savedWorkoutId);
  }

  Future<void> _insertSavedWorkoutExercise({
    required String savedWorkoutId,
    required SavedWorkoutExerciseDraft exercise,
    required DateTime now,
  }) async {
    await _savedWorkoutExerciseDao.upsertExercise(
      _buildSavedWorkoutExerciseCompanion(
        savedWorkoutId: savedWorkoutId,
        exercise: exercise,
        now: now,
      ),
    );

    for (final set in exercise.sets) {
      await _insertSavedWorkoutExerciseSet(
        savedWorkoutExerciseId: exercise.id,
        set: set,
        now: now,
      );
    }
  }

  Future<void> _insertSavedWorkoutExerciseSet({
    required String savedWorkoutExerciseId,
    required SetPrescriptionDraft set,
    required DateTime now,
  }) async {
    await _savedWorkoutExerciseSetDao.upsertSet(
      _buildSavedWorkoutExerciseSetCompanion(
        savedWorkoutExerciseId: savedWorkoutExerciseId,
        set: set,
        now: now,
      ),
    );
  }

  // --- Companion builders ---

  SavedWorkoutsCompanion _buildSavedWorkoutCompanion({
    required SavedWorkoutDraft draft,
    required String savedWorkoutId,
    required DateTime now,
    required DateTime createdAt,
  }) {
    return SavedWorkoutsCompanion(
      id: Value(savedWorkoutId),
      name: Value(draft.name),
      description: Value(draft.description),
      source: Value(draft.source),
      creationMethod: Value(draft.creationMethod),
      status: Value(draft.status),
      estimatedDurationMinutes: Value(draft.estimatedDurationMinutes),
      goalTagsJson: Value(jsonEncode(draft.goalTags)),
      equipmentJson: Value(jsonEncode(draft.equipment)),
      createdAt: Value(createdAt),
      updatedAt: Value(now),
    );
  }

  SavedWorkoutExercisesCompanion _buildSavedWorkoutExerciseCompanion({
    required String savedWorkoutId,
    required SavedWorkoutExerciseDraft exercise,
    required DateTime now,
  }) {
    return SavedWorkoutExercisesCompanion(
      id: Value(exercise.id),
      savedWorkoutId: Value(savedWorkoutId),
      exerciseId: Value(exercise.exerciseId),
      exerciseRef: Value(exercise.exerciseRef),
      exerciseRole: Value(exercise.exerciseRole),
      supersetGroupId: Value(exercise.supersetGroupId),
      supersetOrder: Value(exercise.supersetOrder),
      sortOrder: Value(exercise.sortOrder),
      notes: Value(exercise.notes),
      cuesJson: Value(exercise.cuesJson),
      createdAt: Value(now),
    );
  }

  SavedWorkoutExerciseSetsCompanion _buildSavedWorkoutExerciseSetCompanion({
    required String savedWorkoutExerciseId,
    required SetPrescriptionDraft set,
    required DateTime now,
  }) {
    return SavedWorkoutExerciseSetsCompanion(
      id: Value(set.id),
      savedWorkoutExerciseId: Value(savedWorkoutExerciseId),
      setIndex: Value(set.setIndex),
      setType: Value(set.setType),
      setIntent: Value(set.setIntent),
      prescribedRepsMin: Value(set.prescribedRepsMin),
      prescribedRepsMax: Value(set.prescribedRepsMax),
      prescribedRepsExact: Value(set.prescribedRepsExact),
      durationSeconds: Value(set.durationSeconds),
      distanceMeters: Value(set.distanceMeters),
      weightPrescriptionType: Value(set.weightPrescriptionType),
      prescribedWeightKg: Value(set.prescribedWeightKg),
      prescribedWeightPct1rm: Value(set.prescribedWeightPct1rm),
      prescribedWeightPctWorking: Value(set.prescribedWeightPctWorking),
      bodyweightMultiplier: Value(set.bodyweightMultiplier),
      prescribedRpeMin: Value(set.prescribedRpeMin),
      prescribedRpeMax: Value(set.prescribedRpeMax),
      prescribedRir: Value(set.prescribedRir),
      restSeconds: Value(set.restSeconds),
      loadingModel: Value(set.loadingModel),
      percent1rmMin: Value(set.percent1rmMin),
      percent1rmMax: Value(set.percent1rmMax),
      rpeMin: Value(set.rpeMin),
      rpeMax: Value(set.rpeMax),
      loadSelectionNote: Value(set.loadSelectionNote),
      isCalibrationEstimate: Value(set.isCalibrationEstimate),
      derivedFromWorkingSetIndex: Value(set.derivedFromWorkingSetIndex),
      warmupWeightRuleJson: Value(set.warmupWeightRuleJson),
      createdAt: Value(now),
    );
  }
}
