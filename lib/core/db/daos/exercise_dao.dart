import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/exercises.dart';

part 'exercise_dao.g.dart';

@DriftAccessor(tables: [Exercises])
class ExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseDaoMixin {
  ExerciseDao(super.db);

  Future<List<Exercise>> getAllExercises() => select(exercises).get();

  Future<Exercise?> getExerciseById(int id) =>
      (select(exercises)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Exercise>> searchExercises(String query) {
    return (select(exercises)
          ..where((t) => t.name.like('%$query%'))
          ..limit(50))
        .get();
  }

  Future<int> insertExercise(ExercisesCompanion entry) =>
      into(exercises).insert(entry);

  Future<void> insertExercisesBulk(List<ExercisesCompanion> entries) =>
      batch((batch) => batch.insertAllOnConflictUpdate(exercises, entries));

  Future<bool> updateExercise(ExercisesCompanion entry) =>
      update(exercises).replace(entry);
}
