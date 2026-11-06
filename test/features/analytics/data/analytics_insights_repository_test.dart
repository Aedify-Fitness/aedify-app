import 'dart:convert';
import 'dart:async';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/data/analytics_insights_repository.dart';
import 'package:aedify/features/analytics/domain/analytics_insights.dart';
import 'package:aedify/features/analytics/domain/analytics_query_failure.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AnalyticsInsightsRepository repository;
  final now = DateTime(2026, 11, 6, 12);
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = AnalyticsInsightsRepository(db);
  });
  tearDown(() => db.close());
  test(
    'UTC clock instants use the local calendar day for programme due dates',
    () async {
      final instant = DateTime.utc(2026, 11, 6, 1);
      final local = instant.toLocal();
      final today = DateTime(local.year, local.month, local.day);
      final tomorrow = DateTime(local.year, local.month, local.day + 1);
      await _InsightsFixture.programme(db, 'p');
      await _InsightsFixture.workout(
        db,
        'today',
        date: today.toIso8601String().substring(0, 10),
      );
      await _InsightsFixture.workout(
        db,
        'future',
        date: tomorrow.toIso8601String().substring(0, 10),
      );
      expect((await repository.load(now: instant)).adherence.single.due, 1);
    },
  );
  test('measurement mutations emit distinct invalidation revisions', () async {
    final changes = StreamIterator(repository.watchChanges());
    addTearDown(changes.cancel);
    expect(await changes.moveNext(), isTrue);
    final before = changes.current;
    await repository.saveMeasurement(now, {
      BodyMetric.neckCm: 38,
      BodyMetric.bodyFatPercent: 20,
    }, now: now);
    expect(
      await changes.moveNext().timeout(const Duration(seconds: 2)),
      isTrue,
    );
    expect(changes.current, greaterThan(before));
    final view = await repository.load(now: now);
    expect(view.series(BodyMetric.bodyFatPercent).single.value, 20);
    expect(view.series(BodyMetric.neckCm).single.value, 38);
  });
  test(
    'measurement writes stay canonical and reads preserve order and selected range',
    () async {
      await repository.saveMeasurement(now.subtract(const Duration(days: 2)), {
        BodyMetric.bodyweightKg: 75,
        BodyMetric.waistCm: 81,
      }, now: now);
      await repository.saveMeasurement(now, {
        BodyMetric.bodyweightKg: 74,
      }, now: now);
      final all = await repository.load(now: now);
      expect(all.series(BodyMetric.bodyweightKg).map((p) => p.value), [75, 74]);
      expect(all.series(BodyMetric.waistCm).single.value, 81);
      final filtered = await repository.load(
        now: now,
        from: now.subtract(const Duration(days: 1)),
      );
      expect(filtered.measurements, hasLength(1));
      expect(await db.select(db.localFileRecords).get(), isEmpty);
    },
  );
  test(
    'empty, non-positive, non-finite and future measurements cannot persist',
    () async {
      for (final values in [
        <BodyMetric, double>{},
        {BodyMetric.bodyweightKg: -1.0},
        {BodyMetric.waistCm: 0.0},
        {BodyMetric.bodyweightKg: double.nan},
        {BodyMetric.bodyweightKg: double.infinity},
        {BodyMetric.bodyFatPercent: 101.0},
      ]) {
        await expectLater(
          repository.saveMeasurement(now, values, now: now),
          throwsA(AnalyticsQueryFailure.invalidMeasurement),
        );
      }
      await expectLater(
        repository.saveMeasurement(now.add(const Duration(days: 1)), {
          BodyMetric.bodyweightKg: 75,
        }, now: now),
        throwsA(AnalyticsQueryFailure.invalidMeasurement),
      );
      expect(await db.select(db.bodyMeasurements).get(), isEmpty);
    },
  );
  test(
    'SQL failure is safe and leaves no partially written measurement',
    () async {
      await db.customStatement(
        "CREATE TRIGGER reject_measurement BEFORE INSERT ON body_measurements BEGIN SELECT RAISE(ABORT, 'PRIVATE_SQL_SENTINEL'); END",
      );
      await expectLater(
        repository.saveMeasurement(now, {
          BodyMetric.bodyweightKg: 75,
        }, now: now),
        throwsA(AnalyticsQueryFailure.unavailable),
      );
      expect(await db.select(db.bodyMeasurements).get(), isEmpty);
    },
  );
  test(
    'adherence counts due occurrences once, independent of duplicate completions, skipped and future workouts',
    () async {
      await _InsightsFixture.programme(db, 'p');
      await _InsightsFixture.workout(db, 'done', date: '2026-11-02');
      await _InsightsFixture.workout(
        db,
        'skipped',
        date: '2026-11-03',
        status: 'skipped',
      );
      await _InsightsFixture.workout(db, 'pending', date: '2026-11-06');
      await _InsightsFixture.workout(db, 'future', date: '2026-11-09');
      await _InsightsFixture.workout(db, 'floating');
      await _InsightsFixture.session(db, 's1', 'done');
      await _InsightsFixture.session(db, 's2', 'done');
      await _InsightsFixture.session(
        db,
        'other',
        'pending',
        programme: 'other',
      );
      await _InsightsFixture.session(
        db,
        'active',
        'pending',
        status: 'in_progress',
      );
      final view = (await repository.load(now: now)).adherence.single;
      expect(view.due, 3);
      expect(view.completed, 1);
      expect(view.unscheduled, 1);
      expect(view.percent, closeTo(100 / 3, 0.00001));
      await db.customStatement(
        "UPDATE workout_sessions SET status = 'deleted'",
      );
      expect((await repository.load(now: now)).adherence.single.completed, 0);
    },
  );
  test(
    'week-local scheduling, range boundaries, drafts and deleted programmes fail closed',
    () async {
      await _InsightsFixture.programme(db, 'p');
      await _InsightsFixture.programme(db, 'draft', status: 'draft');
      await _InsightsFixture.programme(db, 'deleted', deleted: true);
      await db.customStatement(
        "INSERT INTO program_weeks(id, program_id, week_number, starts_on_local) VALUES('w','p',1,'2026-11-02')",
      );
      await _InsightsFixture.workout(db, 'derived', week: 'w', day: 2);
      await _InsightsFixture.workout(db, 'past', date: '2026-10-01');
      await _InsightsFixture.workout(db, 'bad', date: '2026-02-30');
      final result = (await repository.load(
        now: now,
        from: DateTime(2026, 11, 4),
      )).adherence;
      expect(result, hasLength(1));
      expect(result.single.due, 1);
      expect(result.single.unscheduled, 1);
      expect(
        (await repository.load(
          now: DateTime(2026, 1, 1),
        )).adherence.single.percent,
        isNull,
      );
    },
  );
  test(
    'CSV is explicit numeric evidence and excludes private notes and all media tables',
    () async {
      await repository.saveMeasurement(now, {
        BodyMetric.bodyweightKg: 75,
        BodyMetric.waistCm: 80,
      }, now: now);
      await db.customStatement(
        "UPDATE body_measurements SET notes = 'PRIVATE_NOTE_SENTINEL'",
      );
      final before = (await db.select(db.bodyMeasurements).get()).length;
      final csv = utf8.decode(await repository.export(now: now));
      expect(csv, contains('body_measurement'));
      expect(csv, contains('bodyweightKg'));
      expect(csv, contains('"75.0","kg"'));
      expect(csv, isNot(contains('PRIVATE_NOTE_SENTINEL')));
      expect(csv, isNot(contains('notes')));
      expect(csv, isNot(contains('media')));
      expect((await db.select(db.bodyMeasurements).get()).length, before);
      expect(await db.select(db.localFileRecords).get(), isEmpty);
    },
  );
}

abstract final class _InsightsFixture {
  static Future<void> programme(
    AppDatabase db,
    String id, {
    String status = 'active',
    bool deleted = false,
  }) => db.customStatement(
    "INSERT INTO programs(id,name,source,creation_method,status,active,created_at,updated_at,deleted_at) VALUES(?,?, 'manual','manual',?,1,1,1,?)",
    [id, id, status, deleted ? 1 : null],
  );
  static Future<void> workout(
    AppDatabase db,
    String id, {
    String? date,
    String status = 'planned',
    String? week,
    int? day,
  }) => db.customStatement(
    "INSERT INTO program_workouts(id,program_id,program_week_id,occurrence_ref,name,scheduled_date_local,scheduled_day_index,status,created_at,updated_at) VALUES(?,'p',?,?,?, ?,?,?,1,1)",
    [id, week, id, id, date, day, status],
  );
  static Future<void> session(
    AppDatabase db,
    String id,
    String workout, {
    String programme = 'p',
    String status = 'completed',
  }) => db.customStatement(
    "INSERT INTO workout_sessions(id,source,program_id,program_workout_id,name,started_at,completed_at,status,created_at,updated_at) VALUES(?,'program',?,?,'PRIVATE_SESSION_SENTINEL',1,1,?,1,1)",
    [id, programme, workout, status],
  );
}
