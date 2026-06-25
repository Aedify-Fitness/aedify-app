import 'package:aedify/shared/constants/app_strings.dart';

enum PreferredUnit {
  metric(
    displayLabel: AppStrings.metricUnits,
    weightUnit: AppStrings.metricWeightUnit,
    heightUnit: AppStrings.metricHeightUnit,
    heightHint: AppStrings.metricHeightHint,
    weightHint: AppStrings.metricWeightHint,
    weightLabel: AppStrings.metricWeightLabel,
    heightLabel: AppStrings.metricHeightLabel,
  ),
  imperial(
    displayLabel: AppStrings.imperialUnits,
    heightUnit: AppStrings.imperialHeightUnit,
    weightUnit: AppStrings.imperialWeightUnit,
    heightHint: AppStrings.imperialHeightHint,
    weightHint: AppStrings.imperialWeightHint,
    weightLabel: AppStrings.imperialWeightLabel,
    heightLabel: AppStrings.imperialHeightLabel,
  );

  String get dbValue => name;

  final String heightUnit;
  final String weightUnit;
  final String weightHint;
  final String heightHint;
  final String heightLabel;
  final String weightLabel;
  final String displayLabel;

  const PreferredUnit({
    required this.heightUnit,
    required this.weightUnit,
    required this.weightHint,
    required this.heightHint,
    required this.weightLabel,
    required this.heightLabel,
    required this.displayLabel,
  });

  bool get isImperial => this == PreferredUnit.imperial;

  static PreferredUnit fromDb(String value) {
    return PreferredUnit.values.firstWhere((u) => u.dbValue == value);
  }

  double toImperialHeight(double cm) {
    if (isImperial) return cm;

    return cm / 2.54;
  }

  double toImperialWeight(double kg) {
    if (isImperial) return kg;

    return kg / 0.45359237;
  }

  double toMetricHeight(double inches) {
    if (!isImperial) return inches;

    return inches * 2.54;
  }

  double toMetricWeight(double lbs) {
    if (!isImperial) return lbs;

    return lbs * 0.45359237;
  }
}
