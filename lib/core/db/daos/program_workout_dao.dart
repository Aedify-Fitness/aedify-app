import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/program_workouts.dart';
part 'program_workout_dao.g.dart';

@DriftAccessor(tables: [ProgramWorkouts])
class ProgramWorkoutDao extends DatabaseAccessor<AppDatabase>
    with _$ProgramWorkoutDaoMixin {
  ProgramWorkoutDao(super.db);

  Future<ProgramWorkout?> getById(String id) => (select(
    programWorkouts,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<ProgramWorkout>> getByProgramId(String programId) => (select(
    programWorkouts,
  )..where((t) => t.programId.equals(programId))).get();

  Future<List<ProgramWorkout>> getByProgramWeekId(String programWeekId) =>
      (select(
        programWorkouts,
      )..where((t) => t.programWeekId.equals(programWeekId))).get();

  Future<ProgramWorkout?> getByOccurrenceRef({
    required String programId,
    required String occurrenceRef,
  }) =>
      (select(programWorkouts)..where(
            (t) =>
                t.programId.equals(programId) &
                t.occurrenceRef.equals(occurrenceRef),
          ))
          .getSingleOrNull();

  Future<void> upsertWorkout(ProgramWorkoutsCompanion entry) =>
      into(programWorkouts).insert(entry);

  Future<void> deleteByProgramId(String programId) async {
    await (delete(
      programWorkouts,
    )..where((t) => t.programId.equals(programId))).go();
  }
}
