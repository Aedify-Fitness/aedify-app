import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/week_type.dart';

/// Planned workload and phase previews derived from a programme draft.
class ProgrammeReviewSummary {
  const ProgrammeReviewSummary({
    required this.weekCount,
    required this.goalLabel,
    required this.minDaysPerWeek,
    required this.maxDaysPerWeek,
    required this.uniqueExerciseCount,
    required this.averageWeeklySets,
    required this.maxWeeklySets,
    required this.averageTargetRpe,
    required this.hasRirEstimates,
    required this.deloadWeekCount,
    required this.blocks,
  });

  final int weekCount;
  final String? goalLabel;
  final int minDaysPerWeek;
  final int maxDaysPerWeek;
  final int uniqueExerciseCount;
  final double averageWeeklySets;
  final int maxWeeklySets;
  final double? averageTargetRpe;
  final bool hasRirEstimates;
  final int deloadWeekCount;
  final List<ProgrammeReviewBlock> blocks;

  static String _goalLabel(GoalTag goal) => switch (goal) {
    GoalTag.buildMuscle => AppStrings.hypertrophyGoal,
    GoalTag.increaseStrength => AppStrings.strengthGoal,
    GoalTag.improveEndurance => AppStrings.enduranceGoal,
    GoalTag.loseWeight => AppStrings.onboardingGoalLoseWeight,
    GoalTag.generalFitness => AppStrings.onboardingGoalGeneralFitness,
    GoalTag.flexibility => AppStrings.onboardingGoalFlexibility,
  };

  static const int exercisePreviewLimit = 3;
  static const double maxRpe = 10;
  static const double minRpe = 1;

  factory ProgrammeReviewSummary.fromDraft(ProgrammeBuilderDraft draft) {
    final weeks = draft.weeks ?? [];
    final exerciseIds = <int>{};
    final weeklySets = <int>[];
    final weeklyDays = <int>[];
    final targetRpes = <double>[];
    var hasRirEstimates = false;
    for (final week in weeks) {
      var setCount = 0;
      final days = <int>{};
      for (final slot in week.slots ?? []) {
        days.add(slot.scheduledDayIndex);
        for (final exercise in slot.template?.exercises ?? []) {
          exerciseIds.add(exercise.exerciseId);
          for (final set in exercise.sets) {
            if (set.setType != SetType.working) continue;
            setCount++;
            final min = set.prescribedRpeMin ?? set.rpeMin;
            final max = set.prescribedRpeMax ?? set.rpeMax;
            if (min != null || max != null) {
              targetRpes.add(((min ?? max!) + (max ?? min!)) / 2);
            } else if (set.prescribedRir != null && set.prescribedRir! >= 0) {
              // RIR-based RPE is an estimate; never write it into prescriptions.
              targetRpes.add(
                (maxRpe - set.prescribedRir!).clamp(minRpe, maxRpe),
              );
              hasRirEstimates = true;
            }
          }
        }
      }
      weeklyDays.add(days.length);
      weeklySets.add(setCount);
    }
    final blocks = <ProgrammeReviewBlock>[];
    var firstWeek = 1;
    for (final block in draft.trainingBlocks) {
      final names = <int, String>{};
      for (final week in weeks.skip(firstWeek - 1).take(block.weekCount)) {
        for (final slot in week.slots ?? []) {
          for (final exercise in slot.template?.exercises ?? []) {
            names.putIfAbsent(
              exercise.exerciseId,
              () =>
                  exercise.exerciseRef ??
                  AppStrings.exerciseNumberLabel(exercise.exerciseId),
            );
          }
        }
      }
      blocks.add(
        ProgrammeReviewBlock(
          block: block,
          firstWeek: firstWeek,
          exerciseNames: names.values.take(exercisePreviewLimit).toList(),
          remainingExercises: (names.length - exercisePreviewLimit).clamp(
            0,
            names.length,
          ),
        ),
      );
      firstWeek += block.weekCount;
    }
    return ProgrammeReviewSummary(
      weekCount: weeks.length,
      goalLabel: draft.goalTags?.isNotEmpty == true
          ? _goalLabel(draft.goalTags!.first)
          : weeks
                .expand((week) => week.slots ?? [])
                .expand((slot) => slot.template?.goalTags ?? <String>[])
                .where((goal) => goal.trim().isNotEmpty)
                .firstOrNull,
      minDaysPerWeek: weeklyDays.isEmpty
          ? 0
          : weeklyDays.reduce((a, b) => a < b ? a : b),
      maxDaysPerWeek: weeklyDays.isEmpty
          ? 0
          : weeklyDays.reduce((a, b) => a > b ? a : b),
      uniqueExerciseCount: exerciseIds.length,
      averageWeeklySets: weeks.isEmpty
          ? 0
          : weeklySets.fold<int>(0, (sum, value) => sum + value) / weeks.length,
      maxWeeklySets: weeklySets.isEmpty
          ? 0
          : weeklySets.reduce((a, b) => a > b ? a : b),
      averageTargetRpe: targetRpes.isEmpty
          ? null
          : targetRpes.reduce((a, b) => a + b) / targetRpes.length,
      hasRirEstimates: hasRirEstimates,
      deloadWeekCount: weeks
          .where((week) => week.weekType == WeekType.deload)
          .length,
      blocks: blocks,
    );
  }
}

class ProgrammeReviewBlock {
  const ProgrammeReviewBlock({
    required this.block,
    required this.firstWeek,
    required this.exerciseNames,
    required this.remainingExercises,
  });

  final ProgrammeTrainingBlockDraft block;
  final int firstWeek;
  final List<String> exerciseNames;
  final int remainingExercises;
  int get lastWeek => firstWeek + block.weekCount - 1;
}
