import 'package:aedify/shared/domain/preferred_unit.dart';

class MeasurementFormatter {
  const MeasurementFormatter._();

  static String formatWeight({
    required double? weightKg,
    required PreferredUnit preferredUnit,
    int fractionDigits = 1,
  }) {
    if (weightKg == null) return '';
    final display = preferredUnit.toDisplayWeight(weightKg);
    return display.toStringAsFixed(fractionDigits);
  }

  static String formatHeight({
    required double? heightCm,
    required PreferredUnit preferredUnit,
    int fractionDigits = 1,
  }) {
    if (heightCm == null) return '';
    final display = preferredUnit.toDisplayHeight(heightCm);
    return display.toStringAsFixed(fractionDigits);
  }
}
