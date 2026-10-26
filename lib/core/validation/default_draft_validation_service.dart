import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/validation/draft_validation_code.dart';
import 'package:aedify/core/validation/draft_validation_issue.dart';
import 'package:aedify/core/validation/draft_validation_path.dart';
import 'package:aedify/core/validation/draft_validation_result.dart';
import 'package:aedify/core/validation/draft_validation_scope.dart';
import 'package:aedify/core/validation/draft_validation_service.dart';
import 'package:aedify/core/validation/validated_exercise_draft.dart';
import 'package:aedify/core/validation/validated_programme_draft.dart';
import 'package:aedify/core/validation/validated_programme_template_draft.dart';
import 'package:aedify/core/validation/validated_programme_week_draft.dart';
import 'package:aedify/core/validation/validated_set_draft.dart';
import 'package:aedify/core/validation/validated_workout_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';

class DefaultDraftValidationService implements DraftValidationService {
  const DefaultDraftValidationService();

  static final _logger = AppLogger(name: 'DefaultDraftValidationService');

  static const _modalitiesWithoutWeight = {
    'bodyweight',
    'cardio',
    'mobility',
    'stretching',
  };

  @override
  DraftValidationResult validateWorkoutDraft(ValidatedWorkoutDraft draft) {
    final issues = <DraftValidationIssue>[];

    if (draft.name.trim().isEmpty) {
      issues.add(
        const DraftValidationIssue(
          scope: DraftValidationScope.root,
          code: DraftValidationCode.missingName,
          message: AppStrings.workoutNameRequired,
        ),
      );
    }

    if (draft.exercises.isEmpty) {
      issues.add(
        const DraftValidationIssue(
          scope: DraftValidationScope.root,
          code: DraftValidationCode.noExercises,
          message: AppStrings.addAtLeastOneExercise,
        ),
      );
    }

    for (final exercise in draft.exercises) {
      issues.addAll(_validateExercise(exercise));
    }

    issues.addAll(_validateSupersets(draft.exercises));

    final result = DraftValidationResult(issues: issues);
    _logger.debug('validateWorkoutDraft — issues: ${result.issues.length}');
    return result;
  }

  @override
  DraftValidationResult validateProgrammeDraft(ValidatedProgrammeDraft draft) {
    final issues = <DraftValidationIssue>[];

    if (draft.name.trim().isEmpty) {
      issues.add(
        const DraftValidationIssue(
          scope: DraftValidationScope.root,
          code: DraftValidationCode.missingName,
          message: AppStrings.programmeNameRequired,
        ),
      );
    }

    if (draft.weeks.isEmpty) {
      issues.add(
        const DraftValidationIssue(
          scope: DraftValidationScope.root,
          code: DraftValidationCode.noWeeks,
          message: AppStrings.addAtLeastOneWeek,
        ),
      );
    }

    if (draft.templates.isEmpty) {
      issues.add(
        const DraftValidationIssue(
          scope: DraftValidationScope.root,
          code: DraftValidationCode.noTemplates,
          message: AppStrings.addAtLeastOneTemplate,
        ),
      );
    }

    issues.addAll(_validateProgrammeWeeks(draft.weeks, draft.templates));
    issues.addAll(_validateProgrammeTemplates(draft.templates));

    final result = DraftValidationResult(issues: issues);
    _logger.debug('validateProgrammeDraft — issues: ${result.issues.length}');
    return result;
  }

  List<DraftValidationIssue> _validateExercise(
    ValidatedExerciseDraft exercise,
  ) {
    final issues = <DraftValidationIssue>[];

    if (exercise.sets.isEmpty) {
      issues.add(
        DraftValidationIssue(
          scope: DraftValidationScope.exercise,
          code: DraftValidationCode.noSets,
          message: AppStrings.addAtLeastOneSet,
          path: DraftValidationPath(exerciseId: exercise.id),
        ),
      );
    }

    for (final exerciseSet in exercise.sets) {
      issues.addAll(_validateSet(exercise, exerciseSet));
    }

    issues.addAll(_validateSetOrdering(exercise));

    return issues;
  }

  List<DraftValidationIssue> _validateSet(
    ValidatedExerciseDraft exercise,
    ValidatedSetDraft setDraft,
  ) {
    final issues = <DraftValidationIssue>[];

    final path = DraftValidationPath(
      exerciseId: exercise.id,
      setId: setDraft.id,
    );

    final repsMin = setDraft.prescribedRepsMin;
    final repsMax = setDraft.prescribedRepsMax;
    final repsExact = setDraft.prescribedRepsExact;

    if (repsMin != null && repsMin < 1) {
      issues.add(
        DraftValidationIssue(
          scope: DraftValidationScope.exerciseSet,
          code: DraftValidationCode.invalidRepsMin,
          message: AppStrings.minRepsAtLeast1,
          path: path,
        ),
      );
    }

    if (repsMax != null && repsMax < 1) {
      issues.add(
        DraftValidationIssue(
          scope: DraftValidationScope.exerciseSet,
          code: DraftValidationCode.invalidRepsMax,
          message: AppStrings.maxRepsAtLeast1,
          path: path,
        ),
      );
    }

    if (repsExact != null && repsExact < 1) {
      issues.add(
        DraftValidationIssue(
          scope: DraftValidationScope.exerciseSet,
          code: DraftValidationCode.invalidRepsExact,
          message: AppStrings.repsAtLeast1,
          path: path,
        ),
      );
    }

    if (_requiresWeight(exercise.modality, setDraft.setType)) {
      if (setDraft.prescribedWeightKg != null &&
          setDraft.prescribedWeightKg! < 0) {
        issues.add(
          DraftValidationIssue(
            scope: DraftValidationScope.exerciseSet,
            code: DraftValidationCode.invalidWeight,
            message: AppStrings.enterValidWeight,
            path: path,
          ),
        );
      }
    }

    final rpeMin = setDraft.prescribedRpeMin;
    final rpeMax = setDraft.prescribedRpeMax;

    if (rpeMin != null && (rpeMin < 1 || rpeMin > 10)) {
      issues.add(
        DraftValidationIssue(
          scope: DraftValidationScope.exerciseSet,
          code: DraftValidationCode.invalidRpeMin,
          message: AppStrings.rpeMinBetween1And10,
          path: path,
        ),
      );
    }

    if (rpeMax != null && (rpeMax < 1 || rpeMax > 10)) {
      issues.add(
        DraftValidationIssue(
          scope: DraftValidationScope.exerciseSet,
          code: DraftValidationCode.invalidRpeMax,
          message: AppStrings.rpeMaxBetween1And10,
          path: path,
        ),
      );
    }

    if (rpeMin != null && rpeMax != null && rpeMin > rpeMax) {
      issues.add(
        DraftValidationIssue(
          scope: DraftValidationScope.exerciseSet,
          code: DraftValidationCode.rpeRange,
          message: AppStrings.rpeMinCannotExceedMax,
          path: path,
        ),
      );
    }

    final rir = setDraft.prescribedRir;
    if (rir != null && rir < 0) {
      issues.add(
        DraftValidationIssue(
          scope: DraftValidationScope.exerciseSet,
          code: DraftValidationCode.invalidRir,
          message: AppStrings.rirCannotBeNegative,
          path: path,
        ),
      );
    }

    final rest = setDraft.restSeconds;
    if (rest != null && rest < 0) {
      issues.add(
        DraftValidationIssue(
          scope: DraftValidationScope.exerciseSet,
          code: DraftValidationCode.invalidRest,
          message: AppStrings.restCannotBeNegative,
          path: path,
        ),
      );
    }

    return issues;
  }

  List<DraftValidationIssue> _validateProgrammeTemplates(
    List<ValidatedProgrammeTemplateDraft> templates,
  ) {
    final issues = <DraftValidationIssue>[];

    for (final template in templates) {
      for (final exercise in template.exercises) {
        issues.addAll(_validateExercise(exercise));
      }
      issues.addAll(_validateSupersets(template.exercises));
    }

    return issues;
  }

  List<DraftValidationIssue> _validateProgrammeWeeks(
    List<ValidatedProgrammeWeekDraft> weeks,
    List<ValidatedProgrammeTemplateDraft> templates,
  ) {
    final issues = <DraftValidationIssue>[];

    for (var i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      if (week.weekNumber != i + 1) {
        issues.add(
          DraftValidationIssue(
            scope: DraftValidationScope.week,
            code: DraftValidationCode.nonSequentialWeek,
            message: AppStrings.weekSequenceMismatch,
            path: DraftValidationPath(weekIndex: i),
          ),
        );
      }

      if (week.slots.isEmpty) {
        issues.add(
          DraftValidationIssue(
            scope: DraftValidationScope.week,
            code: DraftValidationCode.noSlots,
            message: AppStrings.addAtLeastOneSlot,
            path: DraftValidationPath(weekIndex: i),
          ),
        );
      }

      for (var j = 0; j < week.slots.length; j++) {
        final slot = week.slots[j];
        if (!_templateExists(slot.templateKey, templates)) {
          issues.add(
            DraftValidationIssue(
              scope: DraftValidationScope.workoutSlot,
              code: DraftValidationCode.missingTemplate,
              message: AppStrings.selectTemplateForSlot,
              path: DraftValidationPath(weekIndex: i, slotIndex: j),
            ),
          );
        }
      }
    }

    return issues;
  }

  List<DraftValidationIssue> _validateSetOrdering(
    ValidatedExerciseDraft exercise,
  ) {
    final issues = <DraftValidationIssue>[];
    var seenWorking = false;

    for (final setDraft in exercise.sets) {
      if (setDraft.setType == SetType.working) {
        seenWorking = true;
      } else if (setDraft.setType == SetType.warmup && seenWorking) {
        issues.add(
          DraftValidationIssue(
            scope: DraftValidationScope.exerciseSet,
            code: DraftValidationCode.warmupSetOrdering,
            message: AppStrings.warmupSetsMustComeFirst,
            path: DraftValidationPath(
              exerciseId: exercise.id,
              setId: setDraft.id,
            ),
          ),
        );
      }
    }

    return issues;
  }

  List<DraftValidationIssue> _validateSupersets(
    List<ValidatedExerciseDraft> exercises,
  ) {
    final issues = <DraftValidationIssue>[];
    final groups = <String, List<ValidatedExerciseDraft>>{};

    for (final ex in exercises) {
      final gid = ex.supersetGroupId;
      if (gid == null) continue;
      groups.putIfAbsent(gid, () => []).add(ex);
    }

    for (final entry in groups.entries) {
      if (entry.value.length < 2) {
        for (final ex in entry.value) {
          issues.add(
            DraftValidationIssue(
              scope: DraftValidationScope.exercise,
              code: DraftValidationCode.invalidSuperset,
              message: AppStrings.supersetInvalidSelection,
              path: DraftValidationPath(exerciseId: ex.id),
            ),
          );
        }
      }
    }

    return issues;
  }

  bool _requiresWeight(String modality, SetType setType) {
    if (_modalitiesWithoutWeight.contains(modality.toLowerCase())) {
      return false;
    }
    return setType == SetType.working || setType == SetType.warmup;
  }

  bool _templateExists(
    String? templateKey,
    List<ValidatedProgrammeTemplateDraft> templates,
  ) {
    if (templateKey == null) return false;
    return templates.any((t) => t.templateKey == templateKey);
  }
}
