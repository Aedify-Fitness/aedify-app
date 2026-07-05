import 'dart:convert';

import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:uuid/uuid.dart';

import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart'
    as builder;
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/weight_prescription_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/exercise_role.dart';
import 'package:aedify/core/logging/app_logger.dart';

class LoadWorkoutDraftUseCase {
  const LoadWorkoutDraftUseCase({
    required SavedWorkoutRepository savedWorkoutRepository,
    ExerciseDao? exerciseDao,
  }) : _savedWorkoutRepository = savedWorkoutRepository,
       _exerciseDao = exerciseDao;

  static final _logger = AppLogger(name: 'LoadWorkoutDraftUseCase');

  final SavedWorkoutRepository _savedWorkoutRepository;
  final ExerciseDao? _exerciseDao;

  Future<WorkoutBuilderDraft> createEmptyDraft() async {
    _logger.debug('createEmptyDraft');
    return WorkoutBuilderDraft(
      id: const Uuid().v4(),
      name: '',
      source: WorkoutSource.manual,
      creationMethod: CreationMethod.manual,
      status: SavedWorkoutStatus.active,
      goalTags: [],
      equipment: [],
      exercises: [],
    );
  }

  Future<WorkoutBuilderDraft> loadForEdit(String savedWorkoutId) async {
    _logger.debug('loadForEdit — id: $savedWorkoutId');
    final aggregate = await _savedWorkoutRepository.getSavedWorkout(
      savedWorkoutId,
    );
    if (aggregate == null) {
      _logger.error('loadForEdit — workout not found: $savedWorkoutId');
      throw Exception(AppErrorStrings.workoutNotFoundWithId(savedWorkoutId));
    }

    final saved = aggregate.savedWorkout;

    final exerciseSets = <String, List<SavedWorkoutExerciseSet>>{};
    for (final set in aggregate.sets) {
      exerciseSets.putIfAbsent(set.savedWorkoutExerciseId, () => []);
      exerciseSets[set.savedWorkoutExerciseId]!.add(set);
    }

    final modalityMap = <int, String>{};
    if (_exerciseDao != null) {
      final exerciseIds = aggregate.exercises
          .map((e) => e.exerciseId)
          .toSet()
          .toList();
      for (final id in exerciseIds) {
        final ex = await _exerciseDao.getExerciseById(id);
        if (ex != null) modalityMap[id] = ex.modality;
      }
    }

    return WorkoutBuilderDraft(
      id: saved.id,
      name: saved.name,
      source: WorkoutSource.fromDb(saved.source)!,
      creationMethod: CreationMethod.fromDb(saved.creationMethod)!,
      status: SavedWorkoutStatus.fromDb(saved.status),
      goalTags: (jsonDecode(saved.goalTagsJson) as List<dynamic>)
          .cast<String>(),
      equipment: [],
      description: null,
      estimatedDurationMinutes: null,
      restBetweenExercisesSeconds: saved.restBetweenExercisesSeconds,
      exercises: aggregate.exercises.map((e) {
        final sets = exerciseSets[e.id] ?? [];
        return WorkoutBuilderExerciseDraft(
          id: e.id,
          exercise: ExerciseReference(
            exerciseId: e.exerciseId,
            name: e.exerciseRef ?? '',
            modality: modalityMap[e.exerciseId] ?? '',
          ),
          sortOrder: e.sortOrder,
          exerciseRole: ExerciseRole.fromDb(e.exerciseRole),
          supersetGroupId: e.supersetGroupId,
          supersetOrder: e.supersetOrder,
          notes: e.notes,
          restBetweenExercisesSeconds: e.restBetweenExercisesSeconds,
          sets: sets.map((s) {
            return builder.SetPrescriptionDraft(
              id: s.id,
              setIndex: s.setIndex,
              setType: SetType.fromDb(s.setType),
              setIntent: SetIntent.fromDb(s.setIntent),
              prescribedRepsMin: s.prescribedRepsMin,
              prescribedRepsMax: s.prescribedRepsMax,
              prescribedRepsExact: s.prescribedRepsExact,
              durationSeconds: s.durationSeconds,
              distanceMeters: s.distanceMeters,
              weightPrescriptionType: WeightPrescriptionType.fromDb(
                s.weightPrescriptionType,
              ),
              prescribedWeightKg: s.prescribedWeightKg,
              prescribedRpeMin: s.prescribedRpeMin,
              prescribedRpeMax: s.prescribedRpeMax,
              prescribedRir: s.prescribedRir,
              restSeconds: s.restSeconds,
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
