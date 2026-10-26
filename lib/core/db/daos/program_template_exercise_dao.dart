import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/program_template_exercises.dart';
part 'program_template_exercise_dao.g.dart';

@DriftAccessor(tables: [ProgramTemplateExercises])
class ProgramTemplateExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$ProgramTemplateExerciseDaoMixin {
  ProgramTemplateExerciseDao(super.db);

  Future<ProgramTemplateExercise?> getById(String id) => (select(
    programTemplateExercises,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<ProgramTemplateExercise>> getByTemplateIdOrdered(
    String workoutTemplateId,
  ) =>
      (select(programTemplateExercises)
            ..where((t) => t.workoutTemplateId.equals(workoutTemplateId))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<void> upsertExercise(ProgramTemplateExercisesCompanion entry) =>
      into(programTemplateExercises).insert(entry);

  Future<void> deleteById(String id) async {
    await (delete(
      programTemplateExercises,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteByTemplateId(String workoutTemplateId) async {
    await (delete(
      programTemplateExercises,
    )..where((t) => t.workoutTemplateId.equals(workoutTemplateId))).go();
  }
}
