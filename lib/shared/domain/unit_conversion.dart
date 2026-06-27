class UnitConversion {
  const UnitConversion._();

  static double kilogramsToPounds(double kilograms) {
    return kilograms / 0.45359237;
  }

  static double poundsToKilograms(double pounds) {
    return pounds * 0.45359237;
  }

  static double centimetresToInches(double centimetres) {
    return centimetres / 2.54;
  }

  static double inchesToCentimetres(double inches) {
    return inches * 2.54;
  }

  static double formatSafe(double value, {int fractionDigits = 1}) {
    return double.parse(value.toStringAsFixed(fractionDigits));
  }
}
