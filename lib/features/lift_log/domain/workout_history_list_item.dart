import 'package:aedify/shared/domain/session_source.dart';

class WorkoutHistoryListItem {
  const WorkoutHistoryListItem({
    required this.sessionId,
    required this.name,
    required this.source,
    required this.completedAt,
    required this.durationSeconds,
    required this.exerciseCount,
    this.programName,
  });

  final String sessionId;
  final String name;
  final SessionSource source;
  final DateTime completedAt;
  final int? durationSeconds;
  final int exerciseCount;
  final String? programName;
}
