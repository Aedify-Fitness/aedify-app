import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/local_file_records.dart';

part 'local_file_record_dao.g.dart';

@DriftAccessor(tables: [LocalFileRecords])
class LocalFileRecordDao extends DatabaseAccessor<AppDatabase>
    with _$LocalFileRecordDaoMixin {
  LocalFileRecordDao(super.db);

  Future<int> insertFileRecord(LocalFileRecordsCompanion entry) =>
      into(localFileRecords).insert(entry);

  Future<void> upsertFileRecord(LocalFileRecordsCompanion entry) =>
      into(localFileRecords).insertOnConflictUpdate(entry);

  Future<LocalFileRecord?> getByRelativePath(String relativePath) {
    return (select(localFileRecords)
          ..where((t) => t.localRelativePath.equals(relativePath)))
        .getSingleOrNull();
  }

  Future<List<LocalFileRecord>> getByOwner(
    String ownerType, {
    String? ownerId,
  }) {
    return (select(localFileRecords)..where((t) {
          final condition = t.ownerType.equals(ownerType);
          if (ownerId != null) {
            return condition & t.ownerId.equals(ownerId);
          }
          return condition;
        }))
        .get();
  }

  Future<int> deleteByRelativePath(String relativePath) {
    return (delete(
      localFileRecords,
    )..where((t) => t.localRelativePath.equals(relativePath))).go();
  }

  Future<int> deleteByOwner(String ownerType, {String? ownerId}) {
    return (delete(localFileRecords)..where((t) {
          final condition = t.ownerType.equals(ownerType);
          if (ownerId != null) {
            return condition & t.ownerId.equals(ownerId);
          }
          return condition;
        }))
        .go();
  }

  Future<void> markVerified(String relativePath) async {
    final now = DateTime.now();
    await (update(
      localFileRecords,
    )..where((t) => t.localRelativePath.equals(relativePath))).write(
      const LocalFileRecordsCompanion(
        lastVerifiedAt: Value.absent(),
      ).copyWith(lastVerifiedAt: Value(now)),
    );
  }
}
