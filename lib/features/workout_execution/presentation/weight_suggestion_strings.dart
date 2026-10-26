import 'package:aedify/shared/domain/rpe_load_estimator.dart';
import 'package:aedify/features/workout_execution/domain/weight_suggestion.dart';

abstract final class WeightSuggestionStrings {
  static const estimateWeight = 'Estimate weight';
  static const useWeight = 'Use weight';
  static const why = 'How this was estimated';
  static const changeTarget = 'Edit estimate';
  static const calculate = 'Show estimate';
  static const title = 'Weight suggestion';
  static const reps = 'Target reps';
  static const rpe = 'Target RPE';
  static const noHistory =
      'Log a working set with weight, reps and RPE to get an estimate, or add a known 1RM in your profile.';
  static const enterTarget =
      'Choose reps and RPE for an optional weight estimate.';
  static const hint = 'A starting estimate. Adjust for how the set feels.';
  static const rounding =
      'Rounded down for a starting estimate. Edit the weight to match your equipment.';
  static const method =
      'Uses an RPE-adjusted Epley estimate. This is separate from analytics e1RM and does not change your prescribed targets.';
  static const existingWeight =
      'Your entered weight is kept. Clear it before using a suggestion.';
  static const noChange =
      'Changing this estimate target only changes the suggestion.';
  static const checking = 'Checking recent working sets…';
  static String number(num value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
  static String target(WeightSuggestionTarget value) =>
      '${value.reps} reps @ RPE ${number(value.rpe)}';
  static String suggested(double weightKg) =>
      'Suggested ${number(weightKg)} kg';
  static String setTarget(
    String exercise,
    int index,
    WeightSuggestionTarget value,
  ) => '$exercise · Set ${index + 1} · ${target(value)}';
  static String date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  static String calculation(WeightSuggestion suggestion) =>
      'Effort-adjusted strength estimate: ${number(suggestion.reference.strengthKg!)} kg. '
      'Target load before rounding: ${number(RpeLoadEstimator.rawLoad(suggestion.reference.strengthKg!, suggestion.target.reps, suggestion.target.rpe)!)} kg.';
  static String reference(WeightSuggestion value) {
    final source = value.reference;
    final day = date(source.performedAt.toLocal());
    return switch (source.source) {
      LoadReferenceSource.knownMax =>
        'Based on your known 1RM: ${number(source.weightKg)} kg · $day',
      LoadReferenceSource.currentWorkout =>
        'Based on your latest logged working set in this workout: ${number(source.weightKg)} kg × ${source.reps} @ RPE ${number(source.rpe!)} · $day',
      LoadReferenceSource.history =>
        'Based on ${value.referenceCount == 1 ? 'a recent working set' : '${value.referenceCount} recent working sets'}. Reference: ${number(source.weightKg)} kg × ${source.reps} @ RPE ${number(source.rpe!)} · $day',
    };
  }
}
