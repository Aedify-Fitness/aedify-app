import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/domain/analytics_insights.dart';
import 'package:aedify/features/analytics/domain/analytics_query_failure.dart';
import 'package:aedify/features/analytics/domain/analytics_csv.dart';
import 'package:aedify/features/analytics/domain/analytics_log_query.dart';
import 'package:aedify/features/analytics/data/drift_analytics_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:aedify/shared/domain/session_source.dart';

/// Reads local measurement history and scheduled programme completion evidence.
class AnalyticsInsightsRepository {
  AnalyticsInsightsRepository(this.db);
  final AppDatabase db;

  Future<Uint8List> export({required DateTime now, DateTime? from}) =>
      db.transaction(() async {
        final logs = await DriftAnalyticsRepository(db)
            .loadCompletedWorkingSets(
              query: AnalyticsLogQuery(
                from: from,
                until: now.add(const Duration(microseconds: 1)),
              ),
            );
        final insights = await load(now: now, from: from);
        return AnalyticsCsv.encode(logs, insights);
      });

  Stream<int> watchChanges() {
    var revision = 0;
    return db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            db.bodyMeasurements,
            db.programs,
            db.programWeeks,
            db.programWorkouts,
            db.workoutSessions,
          },
        )
        .watch()
        .map((_) => ++revision);
  }

  Future<AnalyticsInsights> load({
    required DateTime now,
    DateTime? from,
  }) async {
    try {
      return await db.transaction(() async {
        final rows =
            await (db.select(db.bodyMeasurements)
                  ..where((m) => m.measuredAt.isSmallerOrEqualValue(now))
                  ..orderBy([
                    (m) => OrderingTerm.asc(m.measuredAt),
                    (m) => OrderingTerm.asc(m.id),
                  ]))
                .get();
        final measurements = <BodyMeasurementEntry>[];
        for (final row in rows) {
          if (from != null && row.measuredAt.isBefore(from)) continue;
          final raw = <BodyMetric, double?>{
            BodyMetric.bodyweightKg: row.bodyweightKg,
            BodyMetric.bodyFatPercent: row.bodyFatPercent,
            BodyMetric.neckCm: row.neckCm,
            BodyMetric.waistCm: row.waistCm,
            BodyMetric.chestCm: row.chestCm,
            BodyMetric.hipsCm: row.hipsCm,
            BodyMetric.leftArmCm: row.leftArmCm,
            BodyMetric.rightArmCm: row.rightArmCm,
            BodyMetric.leftThighCm: row.leftThighCm,
            BodyMetric.rightThighCm: row.rightThighCm,
          };
          measurements.add(
            BodyMeasurementEntry(
              id: row.id,
              measuredAt: row.measuredAt,
              values: {
                for (final e in raw.entries)
                  if (e.value != null &&
                      e.value!.isFinite &&
                      e.value! > 0 &&
                      (!e.key.isPercent || e.value! <= 100))
                    e.key: e.value!,
              },
            ),
          );
        }
        final programmes =
            await (db.select(db.programs)
                  ..where(
                    (p) =>
                        p.deletedAt.isNull() & p.status.equals('draft').not(),
                  )
                  ..orderBy([
                    (p) => OrderingTerm.asc(p.name),
                    (p) => OrderingTerm.asc(p.id),
                  ]))
                .get();
        final weeks = {
          for (final week in await db.select(db.programWeeks).get())
            week.id: week,
        };
        final workouts = await db.select(db.programWorkouts).get();
        final sessions =
            await (db.select(db.workoutSessions)..where(
                  (s) =>
                      s.status.equals('completed') &
                      s.source.equals(SessionSource.program.dbValue) &
                      s.completedAt.isNotNull() &
                      s.completedAt.isSmallerOrEqualValue(now),
                ))
                .get();
        final localNow = now.toLocal();
        final today = DateTime(localNow.year, localNow.month, localNow.day);
        final localFrom = from?.toLocal();
        final workoutsByProgramme = <String, List<ProgramWorkout>>{};
        for (final workout in workouts) {
          workoutsByProgramme
              .putIfAbsent(workout.programId, () => [])
              .add(workout);
        }
        final completedByProgramme = <String, Set<String>>{};
        for (final session in sessions) {
          final programmeId = session.programId;
          final workoutId = session.programWorkoutId;
          if (programmeId != null && workoutId != null) {
            completedByProgramme
                .putIfAbsent(programmeId, () => {})
                .add(workoutId);
          }
        }
        final adherence = <ProgrammeAdherence>[];
        for (final programme in programmes) {
          var due = 0, completed = 0, unscheduled = 0;
          for (final workout
              in workoutsByProgramme[programme.id] ?? <ProgramWorkout>[]) {
            final week = weeks[workout.programWeekId];
            // Cross-programme or malformed week links cannot supply a date.
            final validWeek = week?.programId == programme.id ? week : null;
            var scheduled = _date(workout.scheduledDateLocal);
            final day = workout.scheduledDayIndex;
            if (workout.scheduledDateLocal == null &&
                scheduled == null &&
                day != null &&
                day >= 0 &&
                day < 7) {
              var start = _date(validWeek?.startsOnLocal);
              if (start == null &&
                  validWeek != null &&
                  validWeek.weekNumber > 0) {
                final programStart = _date(programme.startDateLocal);
                if (programStart != null) {
                  start = DateTime(
                    programStart.year,
                    programStart.month,
                    programStart.day + (validWeek.weekNumber - 1) * 7,
                  );
                }
              }
              if (start != null) {
                scheduled = DateTime(start.year, start.month, start.day + day);
              }
            }
            if (scheduled == null) {
              unscheduled++;
              continue;
            }
            if (scheduled.isAfter(today) ||
                (localFrom != null &&
                    scheduled.isBefore(
                      DateTime(localFrom.year, localFrom.month, localFrom.day),
                    ))) {
              continue;
            }
            due++;
            if (completedByProgramme[programme.id]?.contains(workout.id) ??
                false) {
              completed++;
            }
          }
          adherence.add(
            ProgrammeAdherence(
              name: programme.name,
              due: due,
              completed: completed,
              unscheduled: unscheduled,
            ),
          );
        }
        return AnalyticsInsights(
          measurements: measurements,
          adherence: adherence,
        );
      });
    } catch (_) {
      throw AnalyticsQueryFailure.unavailable;
    }
  }

  Future<void> saveMeasurement(
    DateTime measuredAt,
    Map<BodyMetric, double> values, {
    required DateTime now,
  }) async {
    if (values.isEmpty ||
        measuredAt.isAfter(now) ||
        values.entries.any(
          (e) =>
              !e.value.isFinite ||
              e.value <= 0 ||
              (e.key.isPercent && e.value > 100),
        )) {
      throw AnalyticsQueryFailure.invalidMeasurement;
    }
    try {
      await db
          .into(db.bodyMeasurements)
          .insert(
            BodyMeasurementsCompanion.insert(
              id: const Uuid().v4(),
              measuredAt: measuredAt,
              bodyweightKg: Value(values[BodyMetric.bodyweightKg]),
              bodyFatPercent: Value(values[BodyMetric.bodyFatPercent]),
              neckCm: Value(values[BodyMetric.neckCm]),
              waistCm: Value(values[BodyMetric.waistCm]),
              chestCm: Value(values[BodyMetric.chestCm]),
              hipsCm: Value(values[BodyMetric.hipsCm]),
              leftArmCm: Value(values[BodyMetric.leftArmCm]),
              rightArmCm: Value(values[BodyMetric.rightArmCm]),
              leftThighCm: Value(values[BodyMetric.leftThighCm]),
              rightThighCm: Value(values[BodyMetric.rightThighCm]),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } catch (_) {
      throw AnalyticsQueryFailure.unavailable;
    }
  }

  static DateTime? _date(String? text) {
    if (text == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return null;
    }
    final value = DateTime.tryParse(text);
    if (value == null || value.toIso8601String().substring(0, 10) != text) {
      return null;
    }
    return value;
  }
}
