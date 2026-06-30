import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'programme_builder_mode.dart';
import 'programme_builder_phase.dart';

class ProgrammeBuilderState {
  const ProgrammeBuilderState({
    required this.mode,
    required this.phase,
    required this.draft,
    required this.validationErrors,
    required this.isDirty,
    this.programmeId,
    this.errorCode,
    this.errorMessage,
  });

  final ProgrammeBuilderMode mode;
  final ProgrammeBuilderPhase phase;
  final ProgrammeBuilderDraft draft;
  final List<ProgrammeBuilderValidationError> validationErrors;
  final bool isDirty;
  final String? programmeId;
  final String? errorCode;
  final String? errorMessage;

  bool get isLoading => phase == ProgrammeBuilderPhase.loading;
  bool get isSaving => phase == ProgrammeBuilderPhase.saving;
  bool get hasValidationErrors => validationErrors.isNotEmpty;

  ProgrammeBuilderState copyWith({
    ProgrammeBuilderMode? mode,
    ProgrammeBuilderPhase? phase,
    ProgrammeBuilderDraft? draft,
    List<ProgrammeBuilderValidationError>? validationErrors,
    bool? isDirty,
    String? programmeId,
    String? errorCode,
    String? errorMessage,
  }) {
    return ProgrammeBuilderState(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      draft: draft ?? this.draft,
      validationErrors: validationErrors ?? this.validationErrors,
      isDirty: isDirty ?? this.isDirty,
      programmeId: programmeId ?? this.programmeId,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory ProgrammeBuilderState.initial({
    ProgrammeBuilderMode mode = ProgrammeBuilderMode.create,
    String? programmeId,
  }) {
    return ProgrammeBuilderState(
      mode: mode,
      phase: ProgrammeBuilderPhase.editing,
      draft: ProgrammeBuilderDraft(
        id: '',
        name: '',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: ProgramStatus.draft,
      ),
      validationErrors: [],
      isDirty: false,
      programmeId: programmeId,
    );
  }
}
