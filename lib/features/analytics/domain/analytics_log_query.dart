/// Filters by the logged performance time, with an inclusive start and exclusive end.
class AnalyticsLogQuery {
  const AnalyticsLogQuery({this.exerciseId, this.from, this.until});

  final int? exerciseId;
  final DateTime? from;
  final DateTime? until;

  bool get isValid => from == null || until == null || from!.isBefore(until!);

  @override
  bool operator ==(Object other) =>
      other is AnalyticsLogQuery &&
      other.exerciseId == exerciseId &&
      other.from == from &&
      other.until == until;

  @override
  int get hashCode => Object.hash(exerciseId, from, until);
}
