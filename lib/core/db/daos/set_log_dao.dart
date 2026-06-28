import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/set_logs.dart';
part 'set_log_dao.g.dart';

@DriftAccessor(tables: [SetLogs])
class SetLogDao extends DatabaseAccessor<AppDatabase> with _$SetLogDaoMixin {
  SetLogDao(super.db);

  Future<List<SetLog>> getBySessionExerciseIdOrdered(
    String workoutSessionExerciseId,
  ) =>
      (select(setLogs)
            ..where(
              (t) =>
                  t.workoutSessionExerciseId.equals(workoutSessionExerciseId),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.setIndex)]))
          .get();

  Future<List<SetLog>> getByExerciseIdHistory(int exerciseId) =>
      (select(setLogs)
            ..where((t) => t.exerciseId.equals(exerciseId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.performedAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  Future<void> upsertSetLog(SetLogsCompanion entry) =>
      into(setLogs).insert(entry);

  Future<void> deleteBySessionExerciseId(
    String workoutSessionExerciseId,
  ) async {
    await (delete(setLogs)..where(
          (t) => t.workoutSessionExerciseId.equals(workoutSessionExerciseId),
        ))
        .go();
  }
}
