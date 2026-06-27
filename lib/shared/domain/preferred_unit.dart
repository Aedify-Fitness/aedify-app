import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/unit_conversion.dart';

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

  double toDisplayWeight(double kilograms) {
    if (isImperial) return UnitConversion.kilogramsToPounds(kilograms);
    return kilograms;
  }

  double toDisplayHeight(double centimetres) {
    if (isImperial) return UnitConversion.centimetresToInches(centimetres);
    return centimetres;
  }

  double toCanonicalWeight(double input) {
    if (isImperial) return UnitConversion.poundsToKilograms(input);
    return input;
  }

  double toCanonicalHeight(double input) {
    if (isImperial) return UnitConversion.inchesToCentimetres(input);
    return input;
  }

  double toImperialHeight(double cm) {
    if (isImperial) return cm;

    return UnitConversion.centimetresToInches(cm);
  }

  double toImperialWeight(double kg) {
    if (isImperial) return kg;

    return UnitConversion.kilogramsToPounds(kg);
  }

  double toMetricHeight(double inches) {
    if (!isImperial) return inches;

    return UnitConversion.inchesToCentimetres(inches);
  }

  double toMetricWeight(double lbs) {
    if (!isImperial) return lbs;

    return UnitConversion.poundsToKilograms(lbs);
  }
}
