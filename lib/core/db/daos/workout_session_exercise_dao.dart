import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/workout_session_exercises.dart';
part 'workout_session_exercise_dao.g.dart';

@DriftAccessor(tables: [WorkoutSessionExercises])
class WorkoutSessionExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$WorkoutSessionExerciseDaoMixin {
  WorkoutSessionExerciseDao(super.db);

  Future<List<WorkoutSessionExercise>> getBySessionIdOrdered(
    String workoutSessionId,
  ) =>
      (select(workoutSessionExercises)
            ..where((t) => t.workoutSessionId.equals(workoutSessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<void> upsertSessionExercise(WorkoutSessionExercisesCompanion entry) =>
      into(workoutSessionExercises).insert(entry);

  Future<void> deleteBySessionId(String workoutSessionId) async {
    await (delete(
      workoutSessionExercises,
    )..where((t) => t.workoutSessionId.equals(workoutSessionId))).go();
  }
}
