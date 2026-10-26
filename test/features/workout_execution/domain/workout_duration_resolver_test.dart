import 'package:aedify/features/workout_execution/domain/workout_duration_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutDurationResolver', () {
    test('uses the running session start time', () {
      final startedAt = DateTime(2026, 8, 6, 10);

      final elapsed = WorkoutDurationResolver.elapsedSeconds(
        startedAt: startedAt,
        now: startedAt.add(const Duration(minutes: 45, seconds: 20)),
      );

      expect(elapsed, 2720);
    });

    test('prefers the frozen accumulated duration', () {
      final startedAt = DateTime(2026, 8, 6, 10);

      final elapsed = WorkoutDurationResolver.elapsedSeconds(
        startedAt: startedAt,
        accumulatedSeconds: 615,
        now: startedAt.add(const Duration(hours: 2)),
      );

      expect(elapsed, 615);
    });

    test('never returns a negative duration', () {
      final now = DateTime(2026, 8, 6, 10);

      final elapsed = WorkoutDurationResolver.elapsedSeconds(
        startedAt: now.add(const Duration(minutes: 1)),
        now: now,
      );

      expect(elapsed, 0);
    });
  });
}
