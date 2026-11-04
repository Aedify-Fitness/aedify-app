import 'package:aedify/features/analytics/domain/analytics_set_log.dart';

/// The stable performance chronology shared by local analytics services.
abstract final class AnalyticsSetLogOrder {
  /// Compares performance time, session, membership, set index and set ID.
  static int compare(AnalyticsSetLog left, AnalyticsSetLog right) {
    var order = left.performedAt.compareTo(right.performedAt);
    if (order != 0) return order;
    order = left.sessionId.compareTo(right.sessionId);
    if (order != 0) return order;
    order = left.sessionExerciseId.compareTo(right.sessionExerciseId);
    if (order != 0) return order;
    order = left.setIndex.compareTo(right.setIndex);
    return order != 0 ? order : left.id.compareTo(right.id);
  }
}
