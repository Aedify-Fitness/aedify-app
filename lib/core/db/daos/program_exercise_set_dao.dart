import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/program_exercise_sets.dart';
part 'program_exercise_set_dao.g.dart';

@DriftAccessor(tables: [ProgramExerciseSets])
class ProgramExerciseSetDao extends DatabaseAccessor<AppDatabase>
    with _$ProgramExerciseSetDaoMixin {
  ProgramExerciseSetDao(super.db);

  Future<List<ProgramExerciseSet>> getByProgramExerciseIdOrdered(
    String programExerciseId,
  ) =>
      (select(programExerciseSets)
            ..where((t) => t.programExerciseId.equals(programExerciseId))
            ..orderBy([(t) => OrderingTerm(expression: t.setIndex)]))
          .get();

  Future<void> upsertSet(ProgramExerciseSetsCompanion entry) =>
      into(programExerciseSets).insert(entry);

  Future<void> deleteByProgramExerciseId(String programExerciseId) async {
    await (delete(
      programExerciseSets,
    )..where((t) => t.programExerciseId.equals(programExerciseId))).go();
  }
}
