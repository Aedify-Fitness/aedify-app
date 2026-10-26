import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_exercise_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_save_request.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart'
    as builder_set;
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart'
    as repo_set;
import 'package:aedify/core/logging/app_logger.dart';

class SaveWorkoutDraftUseCase {
  const SaveWorkoutDraftUseCase({
    required SavedWorkoutRepository savedWorkoutRepository,
  }) : _savedWorkoutRepository = savedWorkoutRepository;

  static final _logger = AppLogger(name: 'SaveWorkoutDraftUseCase');

  final SavedWorkoutRepository _savedWorkoutRepository;

  Future<String> save(WorkoutBuilderSaveRequest request) async {
    _logger.info(
      'save — name: ${request.draft.name}, exercises: ${request.draft.exercises.length}',
    );
    final builderDraft = request.draft;

    final repoDraft = SavedWorkoutDraft(
      id: builderDraft.id,
      name: builderDraft.name,
      source: builderDraft.source,
      creationMethod: builderDraft.creationMethod,
      status: builderDraft.status,
      goalTags: builderDraft.goalTags.toSet(),
      equipment: builderDraft.equipment.map(_equipmentTagFromString).toSet(),
      description: builderDraft.description,
      estimatedDurationMinutes: builderDraft.estimatedDurationMinutes,
      restBetweenExercisesSeconds: builderDraft.restBetweenExercisesSeconds,
      exercises: builderDraft.exercises.map((e) {
        return SavedWorkoutExerciseDraft(
          id: e.id,
          exerciseId: e.exercise.exerciseId,
          sortOrder: e.sortOrder,
          exerciseRef: e.exercise.name,
          loggingType: e.exercise.loggingType,
          exerciseRole: e.exerciseRole,
          supersetGroupId: e.supersetGroupId,
          supersetOrder: e.supersetOrder,
          notes: e.notes,
          cuesJson: null,
          restBetweenExercisesSeconds: e.restBetweenExercisesSeconds,
          sets: e.sets.map(_toRepoSets).toList(),
        );
      }).toList(),
    );

    return _savedWorkoutRepository.saveSavedWorkout(repoDraft);
  }

  repo_set.SetPrescriptionDraft _toRepoSets(
    builder_set.SetPrescriptionDraft s,
  ) {
    return repo_set.SetPrescriptionDraft(
      id: s.id,
      setIndex: s.setIndex,
      setType: s.setType,
      setIntent: s.setIntent,
      prescribedRepsMin: s.prescribedRepsMin,
      prescribedRepsMax: s.prescribedRepsMax,
      prescribedRepsExact: s.prescribedRepsExact,
      durationSeconds: s.durationSeconds,
      distanceMeters: s.distanceMeters,
      weightPrescriptionType: s.weightPrescriptionType,
      prescribedWeightKg: s.prescribedWeightKg,
      prescribedRpeMin: s.prescribedRpeMin,
      prescribedRpeMax: s.prescribedRpeMax,
      prescribedRir: s.prescribedRir,
      restSeconds: s.restSeconds,
    );
  }

  EquipmentTag _equipmentTagFromString(String value) {
    return switch (value) {
      'bodyweight' => EquipmentTag.bodyweight,
      'dumbbell' => EquipmentTag.dumbbell,
      'barbell' => EquipmentTag.barbell,
      'kettlebell' => EquipmentTag.kettlebell,
      'bands' => EquipmentTag.bands,
      'cable' => EquipmentTag.cable,
      'machine' => EquipmentTag.machine,
      'smith_machine' => EquipmentTag.smithMachine,
      'pull_up_bar' => EquipmentTag.pullUpBar,
      'bench' => EquipmentTag.bench,
      'squat_rack' => EquipmentTag.squatRack,
      'cardio_machine' => EquipmentTag.cardioMachine,
      'ez_bar' => EquipmentTag.ezBar,
      _ => EquipmentTag.other,
    };
  }
}
