import 'package:aedify/core/validation/draft_validation_service.dart';
import 'package:aedify/features/programmes/application/programme_builder_validation_adapter.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/core/logging/app_logger.dart';

class ProgrammeBuilderValidator {
  const ProgrammeBuilderValidator({
    required this.validationService,
    required this.adapter,
  });

  static final _logger = AppLogger(name: 'ProgrammeBuilderValidator');

  final DraftValidationService validationService;
  final ProgrammeBuilderValidationAdapter adapter;

  List<ProgrammeBuilderValidationError> validate(ProgrammeBuilderDraft draft) {
    final validated = adapter.toValidatedDraft(draft);
    final result = validationService.validateProgrammeDraft(validated);
    _logger.debug('validate — ${result.issues.length} errors');
    final errors = adapter.toFeatureErrors(result);

    // Programme-builder-specific: enforce day assignment for >7 slots
    errors.addAll(_validateSlotDays(draft));

    // Programme-builder-specific: goals must be assigned
    errors.addAll(_validateGoals(draft));

    return errors;
  }

  List<ProgrammeBuilderValidationError> _validateSlotDays(
    ProgrammeBuilderDraft draft,
  ) {
    final errors = <ProgrammeBuilderValidationError>[];
    final weeks = draft.weeks ?? [];

    for (var wi = 0; wi < weeks.length; wi++) {
      final slots = weeks[wi].slots ?? [];
      if (slots.length > 7) {
        for (var si = 0; si < slots.length; si++) {
          if (slots[si].scheduledDay == null) {
            errors.add(
              ProgrammeBuilderValidationError(
                scope: ProgrammeBuilderValidationScope.workoutSlot,
                code: AppErrorCodes.noScheduledDay,
                message: AppStrings.scheduledDayRequired,
                weekIndex: wi,
                slotIndex: si,
              ),
            );
          }
        }
      }
    }

    return errors;
  }

  List<ProgrammeBuilderValidationError> _validateGoals(
    ProgrammeBuilderDraft draft,
  ) {
    final errors = <ProgrammeBuilderValidationError>[];
    final goals = draft.goalTags;
    if (goals == null || goals.isEmpty) {
      errors.add(
        const ProgrammeBuilderValidationError(
          scope: ProgrammeBuilderValidationScope.programme,
          code: AppErrorCodes.noGoals,
          message: AppStrings.programmeGoalsRequired,
        ),
      );
    }
    return errors;
  }
}
