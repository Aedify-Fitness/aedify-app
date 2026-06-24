import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/body_measurements.dart';

part 'body_measurement_dao.g.dart';

@DriftAccessor(tables: [BodyMeasurements])
class BodyMeasurementDao extends DatabaseAccessor<AppDatabase>
    with _$BodyMeasurementDaoMixin {
  BodyMeasurementDao(super.db);

  Future<List<BodyMeasurement>> getMeasurements() {
    return select(bodyMeasurements).get();
  }

  Future<void> upsertMeasurement(BodyMeasurementsCompanion entry) {
    return into(bodyMeasurements).insertOnConflictUpdate(entry);
  }

  Future<void> deleteMeasurement(String id) {
    return (delete(bodyMeasurements)..where((t) => t.id.equals(id))).go();
  }
}
