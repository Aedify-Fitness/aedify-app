import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_editor_phase.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_editor_state.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_editor_mode.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CustomExerciseEditorArgs = ({
  CustomExerciseEditorMode mode,
  int? exerciseId,
});

class CustomExerciseEditorController
    extends AsyncNotifier<CustomExerciseEditorState> {
  CustomExerciseEditorController({required this.mode, this.exerciseId});

  final CustomExerciseEditorMode mode;
  final int? exerciseId;

  @override
  Future<CustomExerciseEditorState> build() async {
    if (mode == CustomExerciseEditorMode.create) {
      final draft = await ref
          .read(AppProviders.loadCustomExerciseDraftUseCaseProvider)
          .createEmptyDraft();
      return CustomExerciseEditorState(
        mode: mode,
        phase: CustomExerciseEditorPhase.editing,
        draft: draft,
        validationErrors: const [],
        isDirty: false,
      );
    }

    final draft = await ref
        .read(AppProviders.loadCustomExerciseDraftUseCaseProvider)
        .loadForEdit(exerciseId!);
    return CustomExerciseEditorState(
      mode: mode,
      phase: CustomExerciseEditorPhase.editing,
      draft: draft,
      validationErrors: const [],
      isDirty: false,
      exerciseId: exerciseId,
    );
  }

  Future<void> rename(String value) async {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(name: value),
        isDirty: true,
      ),
    );
  }

  Future<void> setModality(ExerciseModality modality) async {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(modality: modality),
        isDirty: true,
      ),
    );
  }

  Future<void> setEquipment(EquipmentTag? equipment) async {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(equipment: equipment),
        isDirty: true,
      ),
    );
  }

  Future<void> setDifficulty(ExerciseDifficulty? difficulty) async {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(difficulty: difficulty),
        isDirty: true,
      ),
    );
  }

  Future<void> toggleMuscleGroup(BodymapBucket bucket) async {
    final current = state.requireValue;
    final currentGroups = current.draft.muscleGroups;
    final updated = <BodymapBucket>{...currentGroups};
    if (updated.contains(bucket)) {
      updated.remove(bucket);
    } else {
      updated.add(bucket);
    }
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(muscleGroups: updated),
        isDirty: true,
        clearValidation: true,
      ),
    );
  }

  Future<void> addStep() async {
    final current = state.requireValue;
    final steps = [...current.draft.steps, ''];
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(steps: steps),
        isDirty: true,
      ),
    );
  }

  Future<void> updateStep({required int index, required String value}) async {
    final current = state.requireValue;
    final steps = [...current.draft.steps];
    if (index < steps.length) {
      steps[index] = value;
    }
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(steps: steps),
        isDirty: true,
      ),
    );
  }

  Future<void> removeStep(int index) async {
    final current = state.requireValue;
    final steps = [...current.draft.steps];
    if (index < steps.length) {
      steps.removeAt(index);
    }
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(steps: steps),
        isDirty: true,
      ),
    );
  }

  Future<void> save() async {
    final current = state.requireValue;

    final validator = ref.read(AppProviders.customExerciseValidatorProvider);
    final errors = validator.validate(current.draft);

    if (errors.isNotEmpty) {
      state = AsyncData(current.copyWith(validationErrors: errors));
      return;
    }

    state = AsyncData(
      current.copyWith(
        phase: CustomExerciseEditorPhase.saving,
        clearValidation: true,
      ),
    );

    try {
      if (current.mode == CustomExerciseEditorMode.create) {
        final id = await ref
            .read(AppProviders.saveCustomExerciseUseCaseProvider)
            .create(current.draft);
        state = AsyncData(
          current.copyWith(
            phase: CustomExerciseEditorPhase.saved,
            exerciseId: id,
            clearDirty: true,
          ),
        );
      } else {
        await ref
            .read(AppProviders.saveCustomExerciseUseCaseProvider)
            .update(exerciseId: current.exerciseId!, draft: current.draft);
        state = AsyncData(
          current.copyWith(
            phase: CustomExerciseEditorPhase.saved,
            clearDirty: true,
          ),
        );
      }
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          phase: CustomExerciseEditorPhase.failure,
          errorCode: 'save_failed',
          errorMessage: 'Could not save the custom exercise.',
        ),
      );
    }
  }

  Future<void> delete() async {
    final current = state.requireValue;
    if (current.exerciseId == null) return;

    state = AsyncData(
      current.copyWith(phase: CustomExerciseEditorPhase.deleting),
    );

    try {
      await ref
          .read(AppProviders.deleteCustomExerciseUseCaseProvider)
          .delete(current.exerciseId!);
      state = AsyncData(
        current.copyWith(phase: CustomExerciseEditorPhase.deleted),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          phase: CustomExerciseEditorPhase.failure,
          errorCode: 'delete_failed',
          errorMessage: 'Could not delete the custom exercise.',
        ),
      );
    }
  }

  void clearValidationErrors() {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(clearValidation: true));
  }

  void discardChanges() {
    // Reset dirty flag — the caller handles navigation
  }
}
