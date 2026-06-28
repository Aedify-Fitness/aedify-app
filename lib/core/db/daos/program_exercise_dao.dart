import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/program_exercises.dart';
part 'program_exercise_dao.g.dart';

@DriftAccessor(tables: [ProgramExercises])
class ProgramExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$ProgramExerciseDaoMixin {
  ProgramExerciseDao(super.db);

  Future<List<ProgramExercise>> getByProgramWorkoutIdOrdered(
    String programWorkoutId,
  ) =>
      (select(programExercises)
            ..where((t) => t.programWorkoutId.equals(programWorkoutId))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<void> upsertExercise(ProgramExercisesCompanion entry) =>
      into(programExercises).insert(entry);

  Future<void> deleteByProgramWorkoutId(String programWorkoutId) async {
    await (delete(
      programExercises,
    )..where((t) => t.programWorkoutId.equals(programWorkoutId))).go();
  }
}
