import 'package:aedify/shared/domain/rest_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RestResolver', () {
    test('returns 60 when all are null', () {
      expect(RestResolver.effectiveRest(), 60);
      expect(
        RestResolver.effectiveRest(
          setRest: null,
          exerciseRest: null,
          workoutRest: null,
        ),
        60,
      );
    });

    test('workout rest overrides default', () {
      expect(RestResolver.effectiveRest(workoutRest: 90), 90);
    });

    test('exercise rest overrides workout', () {
      expect(RestResolver.effectiveRest(workoutRest: 90, exerciseRest: 45), 45);
    });

    test('set rest overrides exercise', () {
      expect(
        RestResolver.effectiveRest(
          workoutRest: 90,
          exerciseRest: 45,
          setRest: 30,
        ),
        30,
      );
    });

    test('exercise rest falls through to workout', () {
      expect(
        RestResolver.effectiveRest(
          workoutRest: 90,
          exerciseRest: null,
          setRest: null,
        ),
        90,
      );
    });

    test('full chain: set wins over exercise over workout over default', () {
      expect(
        RestResolver.effectiveRest(
          setRest: 30,
          exerciseRest: 45,
          workoutRest: 90,
        ),
        30,
      );
      expect(
        RestResolver.effectiveRest(
          setRest: null,
          exerciseRest: 45,
          workoutRest: 90,
        ),
        45,
      );
      expect(
        RestResolver.effectiveRest(
          setRest: null,
          exerciseRest: null,
          workoutRest: 90,
        ),
        90,
      );
      expect(
        RestResolver.effectiveRest(
          setRest: null,
          exerciseRest: null,
          workoutRest: null,
        ),
        60,
      );
    });
  });
}
