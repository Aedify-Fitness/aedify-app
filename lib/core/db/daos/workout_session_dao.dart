import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/workout_sessions.dart';
part 'workout_session_dao.g.dart';

@DriftAccessor(tables: [WorkoutSessions])
class WorkoutSessionDao extends DatabaseAccessor<AppDatabase>
    with _$WorkoutSessionDaoMixin {
  WorkoutSessionDao(super.db);

  Future<WorkoutSession?> getById(String id) => (select(
    workoutSessions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<WorkoutSession?> getActiveSession() => (select(
    workoutSessions,
  )..where((t) => t.status.equals('in_progress'))).getSingleOrNull();

  Future<List<WorkoutSession>> getCompletedSessions() =>
      (select(workoutSessions)
            ..where((t) => t.status.equals('completed'))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.completedAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  Future<int> countInProgressSessions() async {
    final rows = await (select(
      workoutSessions,
    )..where((t) => t.status.equals('in_progress'))).get();
    return rows.length;
  }

  Future<void> upsertSession(WorkoutSessionsCompanion entry) =>
      into(workoutSessions).insert(entry, mode: InsertMode.insertOrReplace);

  Future<void> markCompleted({
    required String id,
    required DateTime completedAt,
    required int durationSeconds,
    required DateTime updatedAt,
  }) async {
    await (update(workoutSessions)..where((t) => t.id.equals(id))).write(
      WorkoutSessionsCompanion(
        status: const Value('completed'),
        completedAt: Value(completedAt),
        durationSeconds: Value(durationSeconds),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> markAbandoned({
    required String id,
    required DateTime updatedAt,
  }) async {
    await (update(workoutSessions)..where((t) => t.id.equals(id))).write(
      WorkoutSessionsCompanion(
        status: const Value('abandoned'),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> deleteSession(String id) async {
    await (delete(workoutSessions)..where((t) => t.id.equals(id))).go();
  }
}
