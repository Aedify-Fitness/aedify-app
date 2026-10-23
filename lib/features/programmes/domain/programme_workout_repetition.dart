import 'dart:convert';

import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';

/// Recognises repeated weekday workouts without relying on copied row IDs.
abstract final class ProgrammeWorkoutRepetition {
  static Set<int> repeatedSlots(ProgrammeBuilderDraft draft, int weekIndex) {
    final weeks = draft.weeks ?? [];
    if (weekIndex < 0 || weekIndex >= weeks.length) return {};
    final block = ProgrammeTrainingBlockDraft.forWeek(
      draft.trainingBlocks,
      weekIndex,
    );
    if (block == null || block.weekCount < 2) return {};
    final start = draft.trainingBlocks
        .takeWhile((item) => item.id != block.id)
        .fold<int>(0, (sum, item) => sum + item.weekCount);
    if (start + block.weekCount > weeks.length) return {};
    final signatures = <ProgrammeBuilderTemplateDraft, String>{};
    String signature(ProgrammeBuilderTemplateDraft template) =>
        signatures.putIfAbsent(template, () => _signature(template));
    final result = <int>{};
    final slots = weeks[weekIndex].slots ?? [];
    for (var si = 0; si < slots.length; si++) {
      final source = slots[si];
      if (source.template == null) continue;
      final key = signature(source.template!);
      var repeated = true;
      for (var wi = start; wi < start + block.weekCount; wi++) {
        final matching = (weeks[wi].slots ?? []).where(
          (slot) =>
              slot.scheduledDayIndex == source.scheduledDayIndex &&
              slot.template != null &&
              signature(slot.template!) == key,
        );
        if (matching.isEmpty) {
          repeated = false;
          break;
        }
      }
      if (repeated) result.add(si);
    }
    return result;
  }

  static String _signature(ProgrammeBuilderTemplateDraft template) {
    final groups = <String, int>{};
    return jsonEncode([
      template.name,
      template.goalTags,
      template.description,
      template.dayType?.name,
      template.estimatedDurationMinutes,
      template.restBetweenExercisesSeconds,
      for (final exercise in template.exercises)
        [
          exercise.exerciseId,
          exercise.sortOrder,
          exercise.exerciseRole?.name,
          exercise.programmeRole,
          exercise.notes,
          exercise.cuesJson,
          exercise.restBetweenExercisesSeconds,
          exercise.supersetOrder,
          if (exercise.supersetGroupId == null)
            null
          else
            groups.putIfAbsent(exercise.supersetGroupId!, () => groups.length),
          for (final set in exercise.sets)
            [
              set.setIndex,
              set.setType.name,
              set.setIntent?.name,
              set.prescribedRepsMin,
              set.prescribedRepsMax,
              set.prescribedRepsExact,
              set.durationSeconds,
              set.distanceMeters,
              set.weightPrescriptionType?.name,
              set.prescribedWeightKg,
              set.prescribedWeightPct1rm,
              set.prescribedWeightPctWorking,
              set.bodyweightMultiplier,
              set.prescribedRpeMin,
              set.prescribedRpeMax,
              set.prescribedRir,
              set.restSeconds,
              set.loadingModel?.name,
              set.percent1rmMin,
              set.percent1rmMax,
              set.rpeMin,
              set.rpeMax,
              set.loadSelectionNote,
              set.isCalibrationEstimate,
              set.derivedFromWorkingSetIndex,
              set.warmupWeightRuleJson,
            ],
        ],
    ]);
  }
}
