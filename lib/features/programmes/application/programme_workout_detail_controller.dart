import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:aedify/features/programmes/domain/programme_workout_detail_view_data.dart';
import 'package:aedify/shared/domain/training_day.dart';

class ProgrammeWorkoutDetailController {
  ProgrammeWorkoutDetailController._();

  static ProgrammeWorkoutDetailViewData? buildWorkoutDetail(
    ProgrammeAggregate aggregate,
    String workoutId,
    Map<int, String> exerciseNames,
  ) {
    final workout = aggregate.workouts.cast<ProgramWorkout?>().firstWhere(
      (w) => w?.id == workoutId,
      orElse: () => null,
    );
    if (workout == null) return null;

    final dayIdx = workout.scheduledDayIndex ?? 0;
    final dayLabel = TrainingDay.values[dayIdx].fullDisplayLabel;

    final template = aggregate.templates.cast<ProgramWorkoutTemplate?>().firstWhere(
      (t) => t?.id == workout.workoutTemplateId,
      orElse: () => null,
    );
    final durationMinutes = template?.estimatedDurationMinutes ?? 0;

    final workoutExercises = aggregate.exercises
        .where((e) => e.programWorkoutId == workoutId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final exerciseItems = <ExerciseDetailItem>[];
    for (final ex in workoutExercises) {
      final name = exerciseNames[ex.exerciseId] ?? 'Exercise ${ex.exerciseId}';
      final sets = aggregate.sets
          .where((s) => s.programExerciseId == ex.id)
          .toList()
        ..sort((a, b) => a.setIndex.compareTo(b.setIndex));

      final setItems = sets.map((s) {
        return SetPrescriptionItem(
          setIndex: s.setIndex,
          setType: s.setType,
          repsDisplay: _ProgrammeWorkoutDetailFormatting.formatReps(
            s.prescribedRepsExact,
            s.prescribedRepsMin,
            s.prescribedRepsMax,
          ),
          weightDisplay: _ProgrammeWorkoutDetailFormatting.formatWeight(
            s.prescribedWeightKg,
            s.prescribedWeightPct1rm,
          ),
          rpeDisplay: _ProgrammeWorkoutDetailFormatting.formatRpe(
            s.prescribedRpeMin,
            s.prescribedRpeMax,
            s.prescribedRir,
          ),
          restSeconds: s.restSeconds,
          notes: s.loadSelectionNote,
        );
      }).toList();

      exerciseItems.add(ExerciseDetailItem(name: name, sets: setItems));
    }

    return ProgrammeWorkoutDetailViewData(
      workoutName: workout.name,
      dayLabel: dayLabel,
      durationMinutes: durationMinutes,
      exercises: exerciseItems,
    );
  }
}

class _ProgrammeWorkoutDetailFormatting {
  _ProgrammeWorkoutDetailFormatting._();

  static String? formatReps(int? exact, int? min, int? max) {
    if (exact != null) return '$exact';
    if (min != null && max != null) return '$min-$max';
    if (min != null) return '$min+';
    if (max != null) return '0-$max';
    return null;
  }

  static String? formatWeight(double? kg, double? pct1rm) {
    if (kg != null && kg > 0) return '${kg.toStringAsFixed(1)} kg';
    if (pct1rm != null && pct1rm > 0) {
      return '${(pct1rm * 100).toStringAsFixed(0)}% 1RM';
    }
    return null;
  }

  static String? formatRpe(double? rpeMin, double? rpeMax, int? rir) {
    if (rpeMin != null && rpeMax != null) return 'RPE $rpeMin-$rpeMax';
    if (rpeMin != null) return 'RPE $rpeMin';
    if (rpeMax != null) return 'RPE ≤$rpeMax';
    if (rir != null) return 'RIR $rir';
    return null;
  }
}
