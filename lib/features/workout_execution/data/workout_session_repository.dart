import 'package:aedify/features/workout_execution/domain/workout_session_aggregate.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';

abstract class WorkoutSessionRepository {
  Future<WorkoutSessionAggregate?> getActiveSession();

  Future<WorkoutSessionAggregate?> getSession(String id);

  Future<String> startSession(WorkoutSessionDraft draft);

  Future<void> saveSessionProgress(WorkoutSessionDraft draft);

  Future<void> completeSession({
    required String id,
    required DateTime completedAt,
    required int durationSeconds,
  });

  Future<void> abandonSession(String id);

  Future<void> deleteInProgressSession(String id);
}
