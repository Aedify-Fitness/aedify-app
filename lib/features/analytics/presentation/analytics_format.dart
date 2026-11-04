import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:intl/intl.dart';

/// Display-only conversion; canonical records and comparison values stay intact.
abstract final class AnalyticsFormat {
  static String compact(double value) => NumberFormat.compact().format(value);
  static String date(DateTime date) =>
      DateFormat.yMMMd().format(date.toLocal());
  static String shortDate(DateTime date) =>
      DateFormat.MMMd().format(date.toLocal());
  static String number(double value, {int digits = 1}) =>
      NumberFormat.decimalPatternDigits(decimalDigits: digits).format(value);
  static String weight(
    double? value,
    PreferredUnit unit, {
    bool volume = false,
  }) =>
      value == null || !value.isFinite || !unit.toDisplayWeight(value).isFinite
      ? AppStrings.onboardingReviewEmptyValue
      : '${number(unit.toDisplayWeight(value), digits: volume ? 0 : 1)} ${unit.weightUnit}${volume ? ' ${AnalyticsStrings.volumeUnit}' : ''}';
  static String recordValue(PersonalRecord record, PreferredUnit unit) =>
      switch (record.type) {
        PersonalRecordType.maxReps || PersonalRecordType.maxRepsAtWeight =>
          '${record.value} ${AnalyticsStrings.repsUnit}',
        PersonalRecordType.volume => weight(
          record.value.toDouble(),
          unit,
          volume: true,
        ),
        PersonalRecordType.maxWeight || PersonalRecordType.estimatedOneRepMax =>
          weight(record.value.toDouble(), unit),
      };
  static String recordTitle(PersonalRecord record, PreferredUnit unit) =>
      record.type == PersonalRecordType.maxRepsAtWeight
      ? AnalyticsStrings.repRecordAtLoad(
          number(unit.toDisplayWeight(record.comparisonWeightKg!)),
          unit.weightUnit,
        )
      : AnalyticsStrings.recordTitle(record.type);
  static String range(AnalyticsRange range) => switch (range) {
    AnalyticsRange.fourWeeks => AnalyticsStrings.fourWeeks,
    AnalyticsRange.twelveWeeks => AnalyticsStrings.twelveWeeks,
    AnalyticsRange.allTime => AnalyticsStrings.allTime,
  };
}
