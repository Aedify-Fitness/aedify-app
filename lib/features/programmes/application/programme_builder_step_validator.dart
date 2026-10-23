import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/training_day.dart';

/// Requirements for moving between programme builder steps.
class ProgrammeBuilderStepValidator {
  ProgrammeBuilderStepValidator._();

  static List<ProgrammeBuilderValidationError> blocks(
    ProgrammeBuilderDraft draft,
  ) {
    final blocks = draft.trainingBlocks;
    if (blocks.isEmpty) {
      return const [
        ProgrammeBuilderValidationError(
          scope: ProgrammeBuilderValidationScope.programme,
          code: AppErrorCodes.noTrainingBlocks,
          message: AppStrings.trainingBlocksRequired,
        ),
      ];
    }
    return [
      if (blocks.any((block) => block.name.trim().isEmpty))
        const ProgrammeBuilderValidationError(
          scope: ProgrammeBuilderValidationScope.programme,
          code: AppErrorCodes.invalidTrainingBlocks,
          message: AppStrings.trainingBlockNameRequired,
        ),
      if (blocks.any((block) => block.weekCount < 1) ||
          blocks.fold<int>(0, (sum, block) => sum + block.weekCount) !=
              (draft.weeks?.length ?? 0) ||
          blocks.map((block) => block.id).toSet().length != blocks.length)
        const ProgrammeBuilderValidationError(
          scope: ProgrammeBuilderValidationScope.programme,
          code: AppErrorCodes.invalidTrainingBlocks,
          message: AppStrings.trainingBlockWeeksInvalid,
        ),
    ];
  }

  static List<ProgrammeBuilderValidationError> schedule(
    ProgrammeBuilderDraft draft,
  ) {
    final weeks = draft.weeks ?? [];
    if (weeks.isEmpty) {
      return const [
        ProgrammeBuilderValidationError(
          scope: ProgrammeBuilderValidationScope.programme,
          code: AppErrorCodes.noWeeks,
          message: AppStrings.addAtLeastOneWeek,
        ),
      ];
    }
    return [
      for (var wi = 0; wi < weeks.length; wi++)
        if (weeks[wi].slots?.isEmpty ?? true)
          ProgrammeBuilderValidationError(
            scope: ProgrammeBuilderValidationScope.week,
            code: AppErrorCodes.noSlots,
            message: AppStrings.programmeWeekNeedsWorkoutDay(
              weeks[wi].weekNumber,
            ),
            weekIndex: wi,
          ),
    ];
  }

  static List<ProgrammeBuilderValidationError> workouts(
    ProgrammeBuilderDraft draft,
  ) {
    final weeks = draft.weeks ?? [];
    return [
      ...schedule(draft),
      for (var wi = 0; wi < weeks.length; wi++)
        for (final slot in weeks[wi].slots ?? [])
          if (slot.template == null)
            ProgrammeBuilderValidationError(
              scope: ProgrammeBuilderValidationScope.workoutSlot,
              code: AppErrorCodes.missingTemplate,
              message: AppStrings.programmeDayNeedsWorkout(
                weeks[wi].weekNumber,
                (slot.scheduledDay ??
                        TrainingDay.values[slot.scheduledDayIndex %
                            TrainingDay.values.length])
                    .fullDisplayLabel,
              ),
              weekIndex: wi,
              slotIndex: slot.slotIndex,
            ),
    ];
  }
}
