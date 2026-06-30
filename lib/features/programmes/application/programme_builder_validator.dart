import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class ProgrammeBuilderValidator {
  const ProgrammeBuilderValidator();

  List<ProgrammeBuilderValidationError> validate(ProgrammeBuilderDraft draft) {
    final errors = <ProgrammeBuilderValidationError>[];

    if (draft.name.trim().isEmpty) {
      errors.add(
        const ProgrammeBuilderValidationError(
          scope: ProgrammeBuilderValidationScope.programme,
          code: AppErrorCodes.missingName,
          message: AppStrings.programmeNameRequired,
        ),
      );
    }

    final weeks = draft.weeks;
    if (weeks == null || weeks.isEmpty) {
      errors.add(
        const ProgrammeBuilderValidationError(
          scope: ProgrammeBuilderValidationScope.programme,
          code: AppErrorCodes.noWeeks,
          message: AppStrings.addAtLeastOneWeek,
        ),
      );
    } else {
      for (var i = 0; i < weeks.length; i++) {
        final week = weeks[i];
        if (week.weekNumber != i + 1) {
          errors.add(
            ProgrammeBuilderValidationError(
              scope: ProgrammeBuilderValidationScope.week,
              code: AppErrorCodes.nonSequentialWeek,
              message: AppStrings.weekSequenceMismatch,
              weekIndex: i,
            ),
          );
        }

        final slots = week.slots;
        if (slots == null || slots.isEmpty) {
          errors.add(
            ProgrammeBuilderValidationError(
              scope: ProgrammeBuilderValidationScope.week,
              code: AppErrorCodes.noSlots,
              message: AppStrings.addAtLeastOneSlot,
              weekIndex: i,
            ),
          );
        } else {
          for (var j = 0; j < slots.length; j++) {
            final slot = slots[j];
            if (slot.template == null) {
              errors.add(
                ProgrammeBuilderValidationError(
                  scope: ProgrammeBuilderValidationScope.workoutSlot,
                  code: AppErrorCodes.missingTemplate,
                  message: AppStrings.selectTemplateForSlot,
                  weekIndex: i,
                  slotIndex: j,
                ),
              );
            }
          }
        }
      }
    }

    final templates = draft.templates;
    if (templates == null || templates.isEmpty) {
      errors.add(
        const ProgrammeBuilderValidationError(
          scope: ProgrammeBuilderValidationScope.programme,
          code: AppErrorCodes.noTemplates,
          message: AppStrings.addAtLeastOneTemplate,
        ),
      );
    }

    return errors;
  }
}
