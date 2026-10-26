import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/saved_workout_exercise_sets.dart';
part 'saved_workout_exercise_set_dao.g.dart';

@DriftAccessor(tables: [SavedWorkoutExerciseSets])
class SavedWorkoutExerciseSetDao extends DatabaseAccessor<AppDatabase>
    with _$SavedWorkoutExerciseSetDaoMixin {
  SavedWorkoutExerciseSetDao(super.db);

  Future<List<SavedWorkoutExerciseSet>> getBySavedWorkoutExerciseIdOrdered(
    String savedWorkoutExerciseId,
  ) =>
      (select(savedWorkoutExerciseSets)
            ..where(
              (t) => t.savedWorkoutExerciseId.equals(savedWorkoutExerciseId),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.setIndex)]))
          .get();

  Future<void> upsertSet(SavedWorkoutExerciseSetsCompanion entry) =>
      into(savedWorkoutExerciseSets).insert(entry);

  Future<void> deleteBySavedWorkoutExerciseId(
    String savedWorkoutExerciseId,
  ) async {
    await (delete(savedWorkoutExerciseSets)..where(
          (t) => t.savedWorkoutExerciseId.equals(savedWorkoutExerciseId),
        ))
        .go();
  }
}
