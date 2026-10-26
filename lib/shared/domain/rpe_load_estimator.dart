/// A suggestion-only RPE-adjusted Epley heuristic. This does not define the
/// application's analytics e1RM, PR or progression calculations.
abstract final class RpeLoadEstimator {
  static const minimumRpe = 6.0;
  static const maximumReps = 10;
  static const incrementKg = 2.5;

  static bool validTarget(int reps, double rpe) =>
      reps >= 1 &&
      reps <= maximumReps &&
      rpe.isFinite &&
      rpe >= minimumRpe &&
      rpe <= 10;

  static double? strengthEstimate(double weightKg, int reps, double rpe) {
    if (!weightKg.isFinite || weightKg <= 0 || !validTarget(reps, rpe)) {
      return null;
    }
    final value = weightKg * _factor(reps, rpe);
    return value.isFinite ? value : null;
  }

  static double? rawLoad(double strengthKg, int reps, double rpe) {
    if (!strengthKg.isFinite || strengthKg <= 0 || !validTarget(reps, rpe)) {
      return null;
    }
    final raw = strengthKg / _factor(reps, rpe);
    if (!raw.isFinite || raw <= 0) return null;
    return raw;
  }

  static double? load(double strengthKg, int reps, double rpe) {
    final raw = rawLoad(strengthKg, reps, rpe);
    if (raw == null) return null;
    // Do not round up past the model's estimate. Small loads remain usable.
    return raw < incrementKg
        ? (raw * 10).floorToDouble() / 10
        : (raw / incrementKg).floorToDouble() * incrementKg;
  }

  static double _factor(int reps, double rpe) =>
      reps == 1 && rpe == 10 ? 1 : 1 + (reps + 10 - rpe) / 30;
}
