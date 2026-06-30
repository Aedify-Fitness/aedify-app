import 'package:aedify/core/validation/draft_validation_service.dart';
import 'package:aedify/features/programmes/application/programme_builder_validation_adapter.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';

class ProgrammeBuilderValidator {
  const ProgrammeBuilderValidator({
    required this.validationService,
    required this.adapter,
  });

  final DraftValidationService validationService;
  final ProgrammeBuilderValidationAdapter adapter;

  List<ProgrammeBuilderValidationError> validate(ProgrammeBuilderDraft draft) {
    final validated = adapter.toValidatedDraft(draft);
    final result = validationService.validateProgrammeDraft(validated);
    return adapter.toFeatureErrors(result);
  }
}
