import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/saved_workouts.dart';
part 'saved_workout_dao.g.dart';

@DriftAccessor(tables: [SavedWorkouts])
class SavedWorkoutDao extends DatabaseAccessor<AppDatabase>
    with _$SavedWorkoutDaoMixin {
  SavedWorkoutDao(super.db);

  Future<SavedWorkout?> getById(String id) =>
      (select(savedWorkouts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<SavedWorkout>> getAll() => select(savedWorkouts).get();

  Future<List<SavedWorkout>> getByStatus(String status) =>
      (select(savedWorkouts)..where((t) => t.status.equals(status))).get();

  Future<void> upsertSavedWorkout(SavedWorkoutsCompanion entry) =>
      into(savedWorkouts).insert(entry, mode: InsertMode.insertOrReplace);

  Future<void> archiveSavedWorkout({
    required String id,
    required DateTime archivedAt,
    required DateTime updatedAt,
  }) async {
    await (update(savedWorkouts)..where((t) => t.id.equals(id))).write(
      SavedWorkoutsCompanion(
        status: const Value('archived'),
        archivedAt: Value(archivedAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> deleteById(String id) async {
    await (delete(savedWorkouts)..where((t) => t.id.equals(id))).go();
  }

  Future<int> countSessionsReferencingSavedWorkout(
    String savedWorkoutId,
  ) async {
    final db = this.db;
    final rows =
        await (db.workoutSessions.select()
              ..where((t) => t.savedWorkoutId.equals(savedWorkoutId)))
            .get();
    return rows.length;
  }
}
