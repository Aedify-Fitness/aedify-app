import 'package:aedify/core/validation/draft_validation_result.dart';
import 'package:aedify/core/validation/validated_programme_draft.dart';
import 'package:aedify/core/validation/validated_workout_draft.dart';

abstract class DraftValidationService {
  DraftValidationResult validateWorkoutDraft(ValidatedWorkoutDraft draft);

  DraftValidationResult validateProgrammeDraft(ValidatedProgrammeDraft draft);
}
