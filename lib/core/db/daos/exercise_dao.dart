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

  Future<List<Exercise>> searchExercisesByName(String query) {
    return (select(exercises)
          ..where((t) => t.name.like('%$query%'))
          ..limit(50))
        .get();
  }

  Future<List<Exercise>> getSourceExercises() {
    return (select(exercises)..where((t) => t.isCustom.equals(false))).get();
  }

  Future<List<Exercise>> getCustomExercises() {
    return (select(exercises)..where((t) => t.isCustom.equals(true))).get();
  }

  Future<
    Map<int, ({bool isFavorite, bool isSubstitutedOut, String? userNotes})>
  >
  getUserStateByExerciseIds(List<int> ids) async {
    final rows = await (select(exercises)..where((t) => t.id.isIn(ids))).get();
    final map =
        <int, ({bool isFavorite, bool isSubstitutedOut, String? userNotes})>{};
    for (final row in rows) {
      map[row.id] = (
        isFavorite: row.isFavorite,
        isSubstitutedOut: row.isSubstitutedOut,
        userNotes: row.userNotes,
      );
    }
    return map;
  }

  Future<void> deleteSourceExercises() async {
    await (delete(exercises)..where((t) => t.isCustom.equals(false))).go();
  }

  Future<void> insertExercisesBulk(List<ExercisesCompanion> entries) =>
      batch((batch) => batch.insertAllOnConflictUpdate(exercises, entries));

  Future<void> restoreUserState(
    Map<int, ({bool isFavorite, bool isSubstitutedOut, String? userNotes})>
    state,
  ) async {
    final now = DateTime.now();
    for (final entry in state.entries) {
      await (update(exercises)..where((t) => t.id.equals(entry.key))).write(
        const ExercisesCompanion(
          isFavorite: Value(true),
          isSubstitutedOut: Value(true),
          userNotes: Value(null),
        ).copyWith(
          isFavorite: Value(entry.value.isFavorite),
          isSubstitutedOut: Value(entry.value.isSubstitutedOut),
          userNotes: Value(entry.value.userNotes),
          updatedAt: Value(now),
        ),
      );
    }
  }
}
