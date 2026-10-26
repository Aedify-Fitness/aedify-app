import 'package:aedify/shared/domain/set_effort.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RPE derives bounded whole-number RIR and rejects invalid effort', () {
    expect(SetEffort.rirFromRpe(10), 0);
    expect(SetEffort.rirFromRpe(8), 2);
    expect(SetEffort.rirFromRpe(8.5), 2);
    expect(SetEffort.rirFromRpe(1), 5);
    for (final value in [null, 0.0, 11.0, double.nan, double.infinity]) {
      expect(SetEffort.rirFromRpe(value), isNull);
    }
  });

  test(
    'RIR-only prescriptions initialize editable RPE without overriding RPE targets',
    () {
      for (var rir = 0; rir <= 5; rir++) {
        expect(SetEffort.initialRpe(rir: rir), 10 - rir);
      }
      expect(SetEffort.initialRpe(rir: 2, rpeMin: 7), isNull);
      expect(SetEffort.initialRpe(rir: 2, rpeMax: 9), isNull);
      expect(SetEffort.rpeFromRir(null), isNull);
      expect(SetEffort.rpeFromRir(-1), isNull);
      expect(SetEffort.rpeFromRir(6), isNull);
    },
  );
}
