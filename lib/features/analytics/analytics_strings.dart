import 'package:aedify/features/analytics/domain/personal_record.dart';

/// Product copy for the local analytics screens and accessible chart data.
abstract final class AnalyticsStrings {
  static const introduction = 'See your training take shape.';
  static const refresh = 'Refresh trends';
  static const showAllRecords = 'Show all records';
  static const showFewerRecords = 'Show fewer records';
  static const targetMisses = 'Targets missed';
  static const highEffort = 'High effort logged';
  static const deloadPaused =
      'Plateau checks are paused for your recent deload.';
  static const unknownPlateauContext =
      'Programme context is unavailable. Review the saved workout schedule.';
  static const unsupportedPlateau =
      'Plateau checks use weighted strength exercises with reliable estimates.';
  static const inactivePlateau =
      'Plateau checks are paused for this inactive exercise.';
  static const localWorkingSets = 'Working sets · on this device';
  static const fourWeeks = '4 weeks';
  static const twelveWeeks = '12 weeks';
  static const allTime = 'All time';
  static const sessions = 'Sessions';
  static const workingSets = 'Working sets';
  static const weeklyVolume = 'Weekly training volume';
  static const sessionVolume = 'Volume by session';
  static const externalVolume = 'External-load volume';
  static const volumeHint =
      'Working sets × reps × external load. Warm-ups are excluded.';
  static const emptyTitle = 'Your progress starts with a session';
  static const emptyHint =
      'Complete a workout to see your working-set trends here.';
  static const emptyRange = 'No working sets in this range';
  static const emptyRangeHint =
      'Choose a wider range or log your next session.';
  static const noWeightedVolume =
      'Log weighted working sets to see volume. Reps-only and timed sets still count toward your sessions.';
  static const recentWorkouts = 'Recent workouts';
  static const recentRecords = 'Recent records';
  static const noRecordImprovements =
      'Your first performances establish baselines. New records appear as you improve.';
  static const exerciseTrends = 'Your exercises';
  static const estimatedStrength = 'Estimated strength';
  static const estimatedStrengthHint =
      'Epley estimates from 1–10-rep working sets. These are estimates, not tested maximums.';
  static const noStrengthEstimate =
      'No reliable strength estimate yet. Log a weighted strength set of 1–10 reps.';
  static const lowConfidence = 'Low-confidence estimate';
  static const highRepEstimates = 'Higher-rep estimates';
  static const highRepHint =
      'Above 10 reps, estimates are less reliable and do not establish strength records or plateau signals.';
  static const allTimeBests = 'Personal bests · all time';
  static const baseline = 'Baseline';
  static const loggedSets = 'Saved set history · all time';
  static const historyIncludesWarmups =
      'Includes completed warm-up and working sets. Open a workout to review or correct a log.';
  static const noSavedSets = 'No saved sets for this exercise yet.';
  static const reviewPlateau = 'Review your recent training';
  static const plateauHint =
      'Your latest three reliable strength estimates are flat or declining. Review your sessions before changing your plan.';
  static const plateauMinimum =
      'Plateau checks need four reliable sessions in 28 days and no recent deload.';
  static const dismissalHint = 'Dismiss for 14 days';
  static const plateauDismissed = 'Dismissed for 14 days';
  static const viewData = 'View chart data';
  static const sparseData =
      'One logged exposure. More sessions will build a trend.';
  static const thisWeek = 'This week so far';
  static const previousWeek = 'Previous week';
  static const noPreviousVolume = 'Log weighted sets in both weeks to compare';
  static const volumeComparison = 'Compared with the previous calendar week';
  static const repsUnit = 'reps';
  static const volumeUnit = '× reps';
  static const loggedOn = 'Logged on';
  static String sessionsAndSets(int sessions, int sets) =>
      '$sessions sessions · $sets working sets';
  static String chartSemantics(String title, int count, String unit) =>
      '$title. $count data points, $unit. Expand View chart data for dates and values.';
  static String estimateValue(String value, String unit) =>
      'Estimated $value $unit';
  static String repRecordAtLoad(String weight, String unit) =>
      'Reps at $weight $unit';
  static String signedChange(String percent) => '$percent% volume';
  static String recordTitle(PersonalRecordType type) => switch (type) {
    PersonalRecordType.maxWeight => 'Heaviest working set',
    PersonalRecordType.maxRepsAtWeight => 'Reps at load',
    PersonalRecordType.maxReps => 'Most reps',
    PersonalRecordType.volume => 'Best set volume',
    PersonalRecordType.estimatedOneRepMax => 'Estimated one-rep max',
  };
}
