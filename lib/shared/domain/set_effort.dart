/// Converts the single effort input while respecting the stored RIR range.
abstract final class SetEffort {
  static double? rpeFromRir(int? rir) =>
      rir != null && rir >= 0 && rir <= 5 ? 10.0 - rir : null;

  /// RIR is stored as a whole number from zero to five in v1.
  static int? rirFromRpe(double? rpe) =>
      rpe != null && rpe.isFinite && rpe >= 1 && rpe <= 10
      ? (10 - rpe).round().clamp(0, 5)
      : null;

  /// An RIR-only prescription supplies the initial, editable RPE value.
  static double? initialRpe({int? rir, double? rpeMin, double? rpeMax}) =>
      rpeMin == null && rpeMax == null ? rpeFromRir(rir) : null;
}
