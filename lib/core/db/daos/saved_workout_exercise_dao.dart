import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/saved_workout_exercises.dart';
part 'saved_workout_exercise_dao.g.dart';

@DriftAccessor(tables: [SavedWorkoutExercises])
class SavedWorkoutExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$SavedWorkoutExerciseDaoMixin {
  SavedWorkoutExerciseDao(super.db);

  Future<List<SavedWorkoutExercise>> getBySavedWorkoutIdOrdered(
    String savedWorkoutId,
  ) =>
      (select(savedWorkoutExercises)
            ..where((t) => t.savedWorkoutId.equals(savedWorkoutId))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<void> upsertExercise(SavedWorkoutExercisesCompanion entry) =>
      into(savedWorkoutExercises).insert(entry);

  Future<void> deleteBySavedWorkoutId(String savedWorkoutId) async {
    await (delete(
      savedWorkoutExercises,
    )..where((t) => t.savedWorkoutId.equals(savedWorkoutId))).go();
  }
}
