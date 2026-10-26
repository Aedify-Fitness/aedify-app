import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/program_workout_templates.dart';
part 'program_workout_template_dao.g.dart';

@DriftAccessor(tables: [ProgramWorkoutTemplates])
class ProgramWorkoutTemplateDao extends DatabaseAccessor<AppDatabase>
    with _$ProgramWorkoutTemplateDaoMixin {
  ProgramWorkoutTemplateDao(super.db);

  Future<ProgramWorkoutTemplate?> getById(String id) => (select(
    programWorkoutTemplates,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<ProgramWorkoutTemplate>> getByProgramIdOrdered(
    String programId,
  ) =>
      (select(programWorkoutTemplates)
            ..where((t) => t.programId.equals(programId))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<void> upsertTemplate(ProgramWorkoutTemplatesCompanion entry) =>
      into(programWorkoutTemplates).insert(entry);

  Future<void> deleteById(String id) async {
    await (delete(programWorkoutTemplates)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteByProgramId(String programId) async {
    await (delete(
      programWorkoutTemplates,
    )..where((t) => t.programId.equals(programId))).go();
  }
}
