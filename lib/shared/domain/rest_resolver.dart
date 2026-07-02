class RestResolver {
  RestResolver._();

  static int effectiveRest({
    int? setRest,
    int? exerciseRest,
    int? workoutRest,
  }) {
    return setRest ?? exerciseRest ?? workoutRest ?? 60;
  }
}
