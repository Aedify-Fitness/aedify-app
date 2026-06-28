import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/program_template_exercise_sets.dart';
part 'program_template_exercise_set_dao.g.dart';

@DriftAccessor(tables: [ProgramTemplateExerciseSets])
class ProgramTemplateExerciseSetDao extends DatabaseAccessor<AppDatabase>
    with _$ProgramTemplateExerciseSetDaoMixin {
  ProgramTemplateExerciseSetDao(super.db);

  Future<List<ProgramTemplateExerciseSet>> getByTemplateExerciseIdOrdered(
    String templateExerciseId,
  ) =>
      (select(programTemplateExerciseSets)
            ..where((t) => t.templateExerciseId.equals(templateExerciseId))
            ..orderBy([(t) => OrderingTerm(expression: t.setIndex)]))
          .get();

  Future<void> upsertSet(ProgramTemplateExerciseSetsCompanion entry) =>
      into(programTemplateExerciseSets).insert(entry);

  Future<void> deleteByTemplateExerciseId(String templateExerciseId) async {
    await (delete(
      programTemplateExerciseSets,
    )..where((t) => t.templateExerciseId.equals(templateExerciseId))).go();
  }
}
