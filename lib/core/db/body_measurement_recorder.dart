import 'package:aedify/core/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Records explicit profile bodyweight changes in the caller's transaction.
abstract final class BodyMeasurementRecorder {
  static Future<void> record(
    AppDatabase db,
    double? kilograms,
    DateTime now,
  ) async {
    if (kilograms == null || !kilograms.isFinite || kilograms <= 0) return;
    await db
        .into(db.bodyMeasurements)
        .insert(
          BodyMeasurementsCompanion.insert(
            id: const Uuid().v4(),
            measuredAt: now,
            bodyweightKg: Value(kilograms),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await (db.update(db.userProfile)..where((p) => p.id.equals('default')))
        .write(UserProfileCompanion(bodyweightLoggedAt: Value(now)));
  }
}
