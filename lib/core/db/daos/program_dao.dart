import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/programs.dart';
part 'program_dao.g.dart';

@DriftAccessor(tables: [Programs])
class ProgramDao extends DatabaseAccessor<AppDatabase> with _$ProgramDaoMixin {
  ProgramDao(super.db);

  Future<Program?> getById(String id) =>
      (select(programs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Program>> getAll() => select(programs).get();

  Future<List<Program>> getByStatus(String status) =>
      (select(programs)..where((t) => t.status.equals(status))).get();

  Future<Program?> getActiveProgram() =>
      (select(programs)..where((t) => t.active.equals(true))).getSingleOrNull();

  Future<void> upsertProgram(ProgramsCompanion entry) =>
      into(programs).insert(entry, mode: InsertMode.insertOrReplace);

  Future<void> clearActiveProgram({required DateTime updatedAt}) async {
    await (update(programs)..where((t) => t.active.equals(true))).write(
      ProgramsCompanion(
        active: const Value(false),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> setProgramActive({
    required String id,
    required bool active,
    required DateTime updatedAt,
  }) async {
    await (update(programs)..where((t) => t.id.equals(id))).write(
      ProgramsCompanion(active: Value(active), updatedAt: Value(updatedAt)),
    );
  }

  Future<void> archiveProgram({
    required String id,
    required DateTime archivedAt,
    required DateTime updatedAt,
  }) async {
    await (update(programs)..where((t) => t.id.equals(id))).write(
      ProgramsCompanion(
        status: const Value('archived'),
        archivedAt: Value(archivedAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> softDeleteProgram({
    required String id,
    required DateTime deletedAt,
    required DateTime updatedAt,
  }) async {
    await (update(programs)..where((t) => t.id.equals(id))).write(
      ProgramsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<int> countSessionsReferencingProgram(String programId) async {
    final db = this.db;
    final rows =
        await (db.workoutSessions.select()
              ..where((t) => t.programId.equals(programId)))
            .get();
    return rows.length;
  }
}
