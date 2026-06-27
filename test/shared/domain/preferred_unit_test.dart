import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromDb', () {
    test('resolves metric', () {
      expect(PreferredUnit.fromDb('metric'), PreferredUnit.metric);
    });

    test('resolves imperial', () {
      expect(PreferredUnit.fromDb('imperial'), PreferredUnit.imperial);
    });
  });

  group('toDisplayWeight', () {
    test('metric returns kilograms unchanged', () {
      expect(PreferredUnit.metric.toDisplayWeight(70), 70);
    });

    test('imperial converts kilograms to pounds', () {
      final result = PreferredUnit.imperial.toDisplayWeight(70);
      expect(result, closeTo(154.3, 0.1));
    });
  });

  group('toDisplayHeight', () {
    test('metric returns centimetres unchanged', () {
      expect(PreferredUnit.metric.toDisplayHeight(175), 175);
    });

    test('imperial converts centimetres to inches', () {
      final result = PreferredUnit.imperial.toDisplayHeight(175);
      expect(result, closeTo(68.9, 0.1));
    });
  });

  group('toCanonicalWeight', () {
    test('metric returns input unchanged', () {
      expect(PreferredUnit.metric.toCanonicalWeight(70), 70);
    });

    test('imperial converts pounds to kilograms', () {
      final result = PreferredUnit.imperial.toCanonicalWeight(154);
      expect(result, closeTo(69.9, 0.1));
    });
  });

  group('toCanonicalHeight', () {
    test('metric returns input unchanged', () {
      expect(PreferredUnit.metric.toCanonicalHeight(175), 175);
    });

    test('imperial converts inches to centimetres', () {
      final result = PreferredUnit.imperial.toCanonicalHeight(69);
      expect(result, closeTo(175.3, 0.1));
    });
  });
}
