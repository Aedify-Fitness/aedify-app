import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/program_revisions.dart';
part 'program_revision_dao.g.dart';

@DriftAccessor(tables: [ProgramRevisions])
class ProgramRevisionDao extends DatabaseAccessor<AppDatabase>
    with _$ProgramRevisionDaoMixin {
  ProgramRevisionDao(super.db);

  Future<List<ProgramRevision>> getByProgramIdOrdered(String programId) =>
      (select(programRevisions)
            ..where((t) => t.programId.equals(programId))
            ..orderBy([(t) => OrderingTerm(expression: t.revisionNumber)]))
          .get();

  Future<int> getLatestRevisionNumber(String programId) async {
    final rows =
        await (select(programRevisions)
              ..where((t) => t.programId.equals(programId))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.revisionNumber,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    if (rows.isEmpty) return 0;
    return rows.first.revisionNumber;
  }

  Future<void> upsertRevision(ProgramRevisionsCompanion entry) =>
      into(programRevisions).insert(entry);

  Future<void> deleteByProgramId(String programId) async {
    await (delete(
      programRevisions,
    )..where((t) => t.programId.equals(programId))).go();
  }
}
