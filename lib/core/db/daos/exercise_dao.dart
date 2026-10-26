import 'dart:convert';
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

  Future<Map<int, String>> getModalityByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(exercises)..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r.modality};
  }

  Future<List<Exercise>> searchExercises({
    String? query,
    String? muscleGroup,
    String? equipment,
    String? difficulty,
    String? modality,
    bool favoritesOnly = false,
    bool excludeSubstituted = false,
  }) async {
    var q = select(exercises);

    if (query != null && query.isNotEmpty) {
      q.where((t) => t.name.like('%$query%'));
    }

    if (difficulty != null) {
      q.where((t) => t.difficulty.equals(difficulty));
    }

    if (equipment != null) {
      q.where((t) => t.equipment.equals(equipment));
    }

    if (modality != null) {
      q.where((t) => t.modality.equals(modality));
    }

    if (favoritesOnly) {
      q.where((t) => t.isFavorite.equals(true));
    }

    if (excludeSubstituted) {
      q.where((t) => t.isSubstitutedOut.equals(false));
    }

    final results = await q.get();

    if (muscleGroup != null) {
      final filtered = results.where((e) {
        final groups = _decodeJsonList(e.muscleGroupsJson);
        return groups.any((g) => g.toLowerCase() == muscleGroup.toLowerCase());
      }).toList();
      return filtered;
    }

    return results;
  }

  Future<List<Exercise>> getSourceExercises() {
    return (select(exercises)..where((t) => t.isCustom.equals(false))).get();
  }

  Future<List<Exercise>> getCustomExercises() {
    return (select(exercises)..where((t) => t.isCustom.equals(true))).get();
  }

  Future<Exercise?> getCustomExerciseByUuid(String customExerciseUuid) {
    return (select(exercises)
          ..where((t) => t.customExerciseUuid.equals(customExerciseUuid)))
        .getSingleOrNull();
  }

  Future<int> getLowestExerciseId() async {
    final rows =
        await (select(exercises)..orderBy([
              (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
            ]))
            .get();
    if (rows.isEmpty) return 0;
    return rows.first.id;
  }

  Future<void> insertCustomExercise(ExercisesCompanion entry) async {
    await into(exercises).insert(entry);
  }

  Future<void> updateCustomExercise(ExercisesCompanion entry) async {
    final id = entry.id.value;
    await (update(exercises)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> deleteCustomExerciseById(int id) async {
    await (delete(exercises)..where((t) => t.id.equals(id))).go();
  }

  Future<void> setFavorite({
    required int exerciseId,
    required bool isFavorite,
  }) async {
    await (update(exercises)..where((t) => t.id.equals(exerciseId))).write(
      ExercisesCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setSubstitutedOut({
    required int exerciseId,
    required bool isSubstitutedOut,
  }) async {
    await (update(exercises)..where((t) => t.id.equals(exerciseId))).write(
      ExercisesCompanion(
        isSubstitutedOut: Value(isSubstitutedOut),
        updatedAt: Value(DateTime.now()),
      ),
    );
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

  Future<List<Exercise>> getExercisesForCandidateEngine({
    bool includeCustomExercises = true,
  }) {
    var q = select(exercises)..where((t) => t.deletedAt.isNull());
    if (!includeCustomExercises) {
      q.where((t) => t.isCustom.equals(false));
    }
    return q.get();
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

  List<String> _decodeJsonList(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
