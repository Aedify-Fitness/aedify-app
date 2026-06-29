import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/workout_source.dart';

enum WorkoutBuilderMode { create, edit }

enum WorkoutBuilderPhase { loading, editing, saving, saved, failure, blocked }

class WorkoutBuilderState {
  const WorkoutBuilderState({
    required this.mode,
    required this.phase,
    required this.draft,
    required this.validationErrors,
    required this.isDirty,
    this.savedWorkoutId,
    this.errorCode,
    this.errorMessage,
  });

  final WorkoutBuilderMode mode;
  final WorkoutBuilderPhase phase;
  final WorkoutBuilderDraft draft;
  final List<WorkoutBuilderValidationError> validationErrors;
  final bool isDirty;
  final String? savedWorkoutId;
  final String? errorCode;
  final String? errorMessage;

  bool get isLoading => phase == WorkoutBuilderPhase.loading;
  bool get isSaving => phase == WorkoutBuilderPhase.saving;
  bool get hasValidationErrors => validationErrors.isNotEmpty;
  bool get isEmpty => draft.exercises.isEmpty;

  WorkoutBuilderState copyWith({
    WorkoutBuilderMode? mode,
    WorkoutBuilderPhase? phase,
    WorkoutBuilderDraft? draft,
    List<WorkoutBuilderValidationError>? validationErrors,
    bool? isDirty,
    String? savedWorkoutId,
    String? errorCode,
    String? errorMessage,
  }) {
    return WorkoutBuilderState(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      draft: draft ?? this.draft,
      validationErrors: validationErrors ?? this.validationErrors,
      isDirty: isDirty ?? this.isDirty,
      savedWorkoutId: savedWorkoutId ?? this.savedWorkoutId,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory WorkoutBuilderState.initial() {
    return WorkoutBuilderState(
      mode: WorkoutBuilderMode.create,
      phase: WorkoutBuilderPhase.editing,
      draft: WorkoutBuilderDraft(
        id: '',
        name: '',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: SavedWorkoutStatus.active,
        goalTags: [],
        equipment: [],
        exercises: [],
      ),
      validationErrors: [],
      isDirty: false,
    );
  }
}
