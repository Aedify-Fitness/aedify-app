import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/strength_anchors.dart';

part 'strength_anchor_dao.g.dart';

@DriftAccessor(tables: [StrengthAnchors])
class StrengthAnchorDao extends DatabaseAccessor<AppDatabase>
    with _$StrengthAnchorDaoMixin {
  StrengthAnchorDao(super.db);

  Future<List<StrengthAnchor>> getAllAnchors() {
    return select(strengthAnchors).get();
  }

  Future<void> upsertAnchor(StrengthAnchorsCompanion entry) {
    return into(strengthAnchors).insertOnConflictUpdate(entry);
  }

  Future<void> deleteAnchor(String id) {
    return (delete(strengthAnchors)..where((t) => t.id.equals(id))).go();
  }
}
