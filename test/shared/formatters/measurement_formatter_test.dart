import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/formatters/measurement_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatWeight', () {
    test('shows kg for metric', () {
      final result = MeasurementFormatter.formatWeight(
        weightKg: 70,
        preferredUnit: PreferredUnit.metric,
      );
      expect(result, '70.0');
    });

    test('converts to lb for imperial', () {
      final result = MeasurementFormatter.formatWeight(
        weightKg: 70,
        preferredUnit: PreferredUnit.imperial,
      );
      expect(result, '154.3');
    });

    test('null value formats to empty string', () {
      final result = MeasurementFormatter.formatWeight(
        weightKg: null,
        preferredUnit: PreferredUnit.metric,
      );
      expect(result, '');
    });
  });

  group('formatHeight', () {
    test('shows cm for metric', () {
      final result = MeasurementFormatter.formatHeight(
        heightCm: 175,
        preferredUnit: PreferredUnit.metric,
      );
      expect(result, '175.0');
    });

    test('converts to in for imperial', () {
      final result = MeasurementFormatter.formatHeight(
        heightCm: 175,
        preferredUnit: PreferredUnit.imperial,
      );
      expect(result, '68.9');
    });

    test('null value formats to empty string', () {
      final result = MeasurementFormatter.formatHeight(
        heightCm: null,
        preferredUnit: PreferredUnit.metric,
      );
      expect(result, '');
    });
  });
}
