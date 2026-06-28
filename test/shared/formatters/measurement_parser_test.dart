import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/formatters/measurement_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseWeightToCanonicalKg', () {
    test('returns metric value unchanged', () {
      final result = MeasurementParser.parseWeightToCanonicalKg(
        rawValue: '70',
        preferredUnit: PreferredUnit.metric,
      );
      expect(result, 70);
    });

    test('converts pounds to kilograms', () {
      final result = MeasurementParser.parseWeightToCanonicalKg(
        rawValue: '154',
        preferredUnit: PreferredUnit.imperial,
      );
      expect(result, closeTo(69.9, 0.1));
    });

    test('invalid input returns null', () {
      final result = MeasurementParser.parseWeightToCanonicalKg(
        rawValue: 'abc',
        preferredUnit: PreferredUnit.metric,
      );
      expect(result, isNull);
    });
  });

  group('parseHeightToCanonicalCm', () {
    test('returns metric value unchanged', () {
      final result = MeasurementParser.parseHeightToCanonicalCm(
        rawValue: '175',
        preferredUnit: PreferredUnit.metric,
      );
      expect(result, 175);
    });

    test('converts inches to centimetres', () {
      final result = MeasurementParser.parseHeightToCanonicalCm(
        rawValue: '69',
        preferredUnit: PreferredUnit.imperial,
      );
      expect(result, closeTo(175.3, 0.1));
    });

    test('invalid input returns null', () {
      final result = MeasurementParser.parseHeightToCanonicalCm(
        rawValue: 'abc',
        preferredUnit: PreferredUnit.metric,
      );
      expect(result, isNull);
    });
  });
}
