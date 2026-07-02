import 'package:aedify/core/validation/draft_validation_result.dart';
import 'package:aedify/core/validation/draft_validation_scope.dart';
import 'package:aedify/core/validation/validated_exercise_draft.dart';
import 'package:aedify/core/validation/validated_programme_draft.dart';
import 'package:aedify/core/validation/validated_programme_slot_draft.dart';
import 'package:aedify/core/validation/validated_programme_template_draft.dart';
import 'package:aedify/core/validation/validated_programme_week_draft.dart';
import 'package:aedify/core/validation/validated_set_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'package:aedify/core/logging/app_logger.dart';

class ProgrammeBuilderValidationAdapter {
  const ProgrammeBuilderValidationAdapter();

  static final _logger = AppLogger(name: 'ProgrammeBuilderValidationAdapter');

  ValidatedProgrammeDraft toValidatedDraft(ProgrammeBuilderDraft draft) {
    _logger.debug('toValidatedDraft — weeks: ${draft.weeks?.length ?? 0}');
    return ValidatedProgrammeDraft(
      name: draft.name,
      templates: draft.templates != null ? _buildTemplateDrafts(draft) : [],
      weeks:
          draft.weeks?.map((w) {
            return ValidatedProgrammeWeekDraft(
              weekNumber: w.weekNumber,
              slots:
                  w.slots?.map((s) {
                    return ValidatedProgrammeSlotDraft(
                      templateKey: s.template?.templateKey,
                      dayIndex: s.scheduledDayIndex,
                    );
                  }).toList() ??
                  [],
            );
          }).toList() ??
          [],
    );
  }

  List<ValidatedProgrammeTemplateDraft> _buildTemplateDrafts(
    ProgrammeBuilderDraft draft,
  ) {
    final seen = <String>{};
    final result = <ValidatedProgrammeTemplateDraft>[];
    for (final week in draft.weeks ?? []) {
      for (final slot in week.slots ?? []) {
        final t = slot.template;
        if (t != null && seen.add(t.id)) {
          result.add(
            ValidatedProgrammeTemplateDraft(
              templateKey: t.templateKey,
              exercises: t.exercises.map<ValidatedExerciseDraft>((ex) {
                return ValidatedExerciseDraft(
                  id: ex.id,
                  modality: 'strength',
                  sets: ex.sets.map<ValidatedSetDraft>((s) {
                    return ValidatedSetDraft(
                      id: s.id,
                      setType: s.setType,
                      prescribedRepsMin: s.prescribedRepsMin,
                      prescribedRepsMax: s.prescribedRepsMax,
                      prescribedRepsExact: s.prescribedRepsExact,
                      prescribedWeightKg: s.prescribedWeightKg,
                      prescribedRpeMin: s.prescribedRpeMin,
                      prescribedRpeMax: s.prescribedRpeMax,
                      prescribedRir: s.prescribedRir,
                      restSeconds: s.restSeconds,
                    );
                  }).toList(),
                  supersetGroupId: ex.supersetGroupId,
                  supersetOrder: ex.supersetOrder,
                  exerciseReferenceId: ex.exerciseId,
                );
              }).toList(),
            ),
          );
        }
      }
    }
    return result;
  }

  List<ProgrammeBuilderValidationError> toFeatureErrors(
    DraftValidationResult result,
  ) {
    return result.issues.map((issue) {
      return ProgrammeBuilderValidationError(
        scope: _mapScope(issue.scope),
        code: issue.code,
        message: issue.message,
        weekIndex: issue.path.weekIndex,
        slotIndex: issue.path.slotIndex,
        templateKey: issue.path.templateKey,
      );
    }).toList();
  }

  ProgrammeBuilderValidationScope _mapScope(DraftValidationScope scope) {
    return switch (scope) {
      DraftValidationScope.root => ProgrammeBuilderValidationScope.programme,
      DraftValidationScope.exercise =>
        ProgrammeBuilderValidationScope.programme,
      DraftValidationScope.exerciseSet =>
        ProgrammeBuilderValidationScope.programme,
      DraftValidationScope.week => ProgrammeBuilderValidationScope.week,
      DraftValidationScope.workoutSlot =>
        ProgrammeBuilderValidationScope.workoutSlot,
      DraftValidationScope.template =>
        ProgrammeBuilderValidationScope.programme,
      DraftValidationScope.schedule =>
        ProgrammeBuilderValidationScope.programme,
    };
  }
}
