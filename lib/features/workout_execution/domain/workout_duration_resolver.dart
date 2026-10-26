/// Resolves the authoritative elapsed duration for a workout session.
abstract final class WorkoutDurationResolver {
  static int elapsedSeconds({
    required DateTime startedAt,
    int? accumulatedSeconds,
    DateTime? now,
  }) {
    if (accumulatedSeconds != null) {
      return accumulatedSeconds < 0 ? 0 : accumulatedSeconds;
    }

    final elapsed = (now ?? DateTime.now()).difference(startedAt).inSeconds;
    return elapsed < 0 ? 0 : elapsed;
  }
}
