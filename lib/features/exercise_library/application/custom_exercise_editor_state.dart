import 'package:aedify/features/exercise_library/application/custom_exercise_editor_phase.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_editor_mode.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

class CustomExerciseEditorState {
  const CustomExerciseEditorState({
    required this.mode,
    required this.phase,
    required this.draft,
    required this.validationErrors,
    required this.isDirty,
    this.exerciseId,
    this.errorCode,
    this.errorMessage,
  });

  final CustomExerciseEditorMode mode;
  final CustomExerciseEditorPhase phase;
  final CustomExerciseDraft draft;
  final List<CustomExerciseValidationError> validationErrors;
  final bool isDirty;
  final int? exerciseId;
  final String? errorCode;
  final String? errorMessage;

  bool get isLoading => phase == CustomExerciseEditorPhase.loading;
  bool get isSaving =>
      phase == CustomExerciseEditorPhase.saving ||
      phase == CustomExerciseEditorPhase.deleting;
  bool get hasValidationErrors => validationErrors.isNotEmpty;

  CustomExerciseEditorState copyWith({
    CustomExerciseEditorMode? mode,
    CustomExerciseEditorPhase? phase,
    CustomExerciseDraft? draft,
    List<CustomExerciseValidationError>? validationErrors,
    bool? isDirty,
    int? exerciseId,
    String? errorCode,
    String? errorMessage,
    bool clearErrors = false,
    bool clearDirty = false,
    bool clearValidation = false,
  }) {
    return CustomExerciseEditorState(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      draft: draft ?? this.draft,
      validationErrors: clearValidation
          ? const []
          : validationErrors ?? this.validationErrors,
      isDirty: clearDirty ? false : (isDirty ?? this.isDirty),
      exerciseId: exerciseId ?? this.exerciseId,
      errorCode: clearErrors ? null : (errorCode ?? this.errorCode),
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory CustomExerciseEditorState.initial({
    required CustomExerciseEditorMode mode,
  }) {
    return CustomExerciseEditorState(
      mode: mode,
      phase: CustomExerciseEditorPhase.loading,
      draft: const CustomExerciseDraft(
        name: '',
        muscleGroups: {},
        modality: ExerciseModality.strength,
      ),
      validationErrors: const [],
      isDirty: false,
    );
  }
}
