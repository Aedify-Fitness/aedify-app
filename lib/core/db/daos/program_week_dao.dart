import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/program_weeks.dart';
part 'program_week_dao.g.dart';

@DriftAccessor(tables: [ProgramWeeks])
class ProgramWeekDao extends DatabaseAccessor<AppDatabase>
    with _$ProgramWeekDaoMixin {
  ProgramWeekDao(super.db);

  Future<List<ProgramWeek>> getByProgramIdOrdered(String programId) =>
      (select(programWeeks)
            ..where((t) => t.programId.equals(programId))
            ..orderBy([(t) => OrderingTerm(expression: t.weekNumber)]))
          .get();

  Future<void> upsertWeek(ProgramWeeksCompanion entry) =>
      into(programWeeks).insert(entry);

  Future<void> deleteByProgramId(String programId) async {
    await (delete(
      programWeeks,
    )..where((t) => t.programId.equals(programId))).go();
  }
}
