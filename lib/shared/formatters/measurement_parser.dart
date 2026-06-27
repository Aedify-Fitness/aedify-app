import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/unit_conversion.dart';

class MeasurementParser {
  const MeasurementParser._();

  static double? parseWeightToCanonicalKg({
    required String rawValue,
    required PreferredUnit preferredUnit,
  }) {
    final parsed = double.tryParse(rawValue);
    if (parsed == null) return null;
    if (preferredUnit.isImperial) {
      return UnitConversion.formatSafe(
        UnitConversion.poundsToKilograms(parsed),
      );
    }
    return parsed;
  }

  static double? parseHeightToCanonicalCm({
    required String rawValue,
    required PreferredUnit preferredUnit,
  }) {
    final parsed = double.tryParse(rawValue);
    if (parsed == null) return null;
    if (preferredUnit.isImperial) {
      return UnitConversion.formatSafe(
        UnitConversion.inchesToCentimetres(parsed),
      );
    }
    return parsed;
  }
}
