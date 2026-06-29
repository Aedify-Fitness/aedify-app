import 'package:aedify/core/db/app_database.dart';
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

class LoadWorkoutDraftUseCase {
  const LoadWorkoutDraftUseCase({
    required SavedWorkoutRepository savedWorkoutRepository,
  }) : _savedWorkoutRepository = savedWorkoutRepository;

  final SavedWorkoutRepository _savedWorkoutRepository;

  Future<WorkoutBuilderDraft> createEmptyDraft() async {
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
    final aggregate = await _savedWorkoutRepository.getSavedWorkout(
      savedWorkoutId,
    );
    if (aggregate == null) {
      throw Exception(AppErrorStrings.workoutNotFoundWithId(savedWorkoutId));
    }

    final saved = aggregate.savedWorkout;

    final exerciseSets = <String, List<SavedWorkoutExerciseSet>>{};
    for (final set in aggregate.sets) {
      exerciseSets.putIfAbsent(set.savedWorkoutExerciseId, () => []);
      exerciseSets[set.savedWorkoutExerciseId]!.add(set);
    }

    return WorkoutBuilderDraft(
      id: saved.id,
      name: saved.name,
      source: WorkoutSource.fromDb(saved.source)!,
      creationMethod: CreationMethod.fromDb(saved.creationMethod)!,
      status: SavedWorkoutStatus.fromDb(saved.status),
      goalTags: [],
      equipment: [],
      description: null,
      estimatedDurationMinutes: null,
      exercises: aggregate.exercises.map((e) {
        final sets = exerciseSets[e.id] ?? [];
        return WorkoutBuilderExerciseDraft(
          id: e.id,
          exercise: ExerciseReference(
            exerciseId: e.exerciseId,
            name: '',
            modality: '',
          ),
          sortOrder: e.sortOrder,
          exerciseRole: ExerciseRole.fromDb(e.exerciseRole),
          supersetGroupId: e.supersetGroupId,
          supersetOrder: e.supersetOrder,
          notes: e.notes,
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
