import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/application/analytics_providers.dart';
import 'package:aedify/features/analytics/application/personal_record_providers.dart';
import 'package:aedify/features/analytics/data/analytics_repository.dart';
import 'package:aedify/features/analytics/data/drift_analytics_repository.dart';
import 'package:aedify/features/analytics/domain/analytics_log_query.dart';
import 'package:aedify/features/analytics/domain/analytics_query_failure.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/features/analytics/domain/personal_record_service.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftAnalyticsRepository repository;
  final performedAt = DateTime.utc(2026, 10, 20, 12);
  const sentinel = 'PRIVATE_ANALYTICS_NOTE_SENTINEL';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftAnalyticsRepository(db);
    for (final id in [1, -1, 2]) {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: Value(id),
              isCustom: Value(id < 0),
              source: id < 0 ? 'custom' : 'musclewiki',
              name: 'Synthetic exercise',
              nameNormalized: 'synthetic exercise',
              primaryMusclesJson: '[]',
              muscleGroupsJson: '[]',
              modality: id == 2 ? 'cardio' : 'strength',
              loggingType: Value(id == 2 ? 'duration' : 'repsWeight'),
              gripsJson: '[]',
              stepsJson: '[]',
              userNotes: const Value(sentinel),
              createdAt: performedAt,
              updatedAt: performedAt,
            ),
          );
    }
  });

  tearDown(() => db.close());

  Future<void> seed(
    String id, {
    int exerciseId = 1,
    int? memberExerciseId,
    String? loggingType = 'repsWeight',
    String status = 'completed',
    String source = 'standalone',
    String setType = 'working',
    bool completed = true,
    bool skipped = false,
    DateTime? time,
    int? reps = 5,
    double? weight = 100,
    int? duration,
    double? distance,
  }) async {
    final at = time ?? performedAt;
    await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: id,
            source: source,
            name: 'Synthetic session',
            startedAt: at,
            completedAt: Value(at.add(const Duration(hours: 1))),
            status: status,
            bodyweightKgAtSession: const Value(75),
            notes: const Value(sentinel),
            createdAt: at,
            updatedAt: at,
          ),
        );
    await db
        .into(db.workoutSessionExercises)
        .insert(
          WorkoutSessionExercisesCompanion.insert(
            id: 'member-$id',
            workoutSessionId: id,
            exerciseId: memberExerciseId ?? exerciseId,
            exerciseNameSnapshot: 'Synthetic exercise',
            sortOrder: 0,
            loggingType: Value(loggingType),
            notes: const Value(sentinel),
          ),
        );
    await db
        .into(db.setLogs)
        .insert(
          SetLogsCompanion.insert(
            id: 'set-$id',
            workoutSessionExerciseId: 'member-$id',
            exerciseId: exerciseId,
            performedAt: at,
            setIndex: 0,
            setType: Value(setType),
            completed: Value(completed),
            skipped: Value(skipped),
            actualReps: Value(reps),
            actualWeightKg: Value(weight),
            actualDurationSeconds: Value(duration),
            actualDistanceMeters: Value(distance),
            actualRpe: const Value(8),
            actualRir: const Value(2),
            prescribedRepsMin: const Value(4),
            prescribedRepsMax: const Value(6),
            prescribedWeightKg: const Value(105),
            isPr: const Value(true),
            estimated1rmKg: const Value(999),
            notes: const Value(sentinel),
            createdAt: at,
            updatedAt: at,
          ),
        );
  }

  group('PR source integration', () {
    test(
      'only eligible source logs create records, including custom exercises',
      () async {
        await seed('valid');
        await seed('custom', exerciseId: -1, weight: 60);
        await seed('warmup', setType: 'warmup', weight: 900);
        await seed('pending', completed: false, weight: 900);
        await seed('skipped', skipped: true, weight: 900);
        for (final status in [
          'in_progress',
          'cancelled',
          'abandoned',
          'deleted',
        ]) {
          await seed(status, status: status, weight: 900);
        }
        await seed(
          'cardio',
          exerciseId: 2,
          loggingType: 'duration',
          reps: null,
          weight: null,
          duration: 200,
        );
        final before = (await db.select(db.setLogs).get())
            .map((row) => row.toJson())
            .toList();
        final summary = const PersonalRecordService().detect(
          await repository.loadCompletedWorkingSets(),
        );
        expect(summary.current, hasLength(6));
        expect(summary.history.map((record) => record.setLogId).toSet(), {
          'set-valid',
          'set-custom',
        });
        expect(summary.history.toString(), isNot(contains(sentinel)));
        expect(
          (await db.select(db.setLogs).get())
              .map((row) => row.toJson())
              .toList(),
          before,
        );
      },
    );

    test(
      'record provider recalculates after real history correction and source deletion',
      () async {
        await seed('old');
        await seed(
          'new',
          time: performedAt.add(const Duration(days: 1)),
          weight: 110,
        );
        final container = ProviderContainer(
          overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);
        final provider = PersonalRecordProviders.recordsProvider(1);
        final keepAlive = container.listen(provider, (_, _) {});
        addTearDown(keepAlive.close);
        Future<PersonalRecordSummary> until(
          bool Function(PersonalRecordSummary) condition,
        ) async {
          final completer = Completer<PersonalRecordSummary>();
          final subscription = container.listen(provider, (_, state) {
            final data = state.asData?.value;
            if (data != null && condition(data) && !completer.isCompleted) {
              completer.complete(data);
            }
          }, fireImmediately: true);
          try {
            return await completer.future.timeout(const Duration(seconds: 5));
          } finally {
            subscription.close();
          }
        }

        PersonalRecord weight(PersonalRecordSummary summary) =>
            summary.current.singleWhere(
              (record) => record.type == PersonalRecordType.maxWeight,
            );
        expect(container.read(provider).isLoading, isTrue);
        expect(
          weight(await until((summary) => summary.current.isNotEmpty)).value,
          110,
        );
        final history = container.read(
          AppProviders.workoutHistoryRepositoryProvider,
        );
        final detail = (await history.getSessionDetail('old'))!;
        await history.correctSession(
          sessionId: 'old',
          corrections: [
            WorkoutHistorySetCorrection(
              expected: detail.exercises.single.sets.single,
              actualReps: 5,
              actualWeightKg: 120,
              actualRpe: 8,
              actualRir: 2,
              notes: sentinel,
            ),
          ],
        );
        final corrected = await until(
          (summary) => weight(summary).value == 120,
        );
        expect(weight(corrected).setLogId, 'set-old');
        expect(
          corrected.history.where(
            (record) => record.type == PersonalRecordType.maxWeight,
          ),
          hasLength(1),
        );
        await db.transaction(() async {
          await (db.delete(
            db.setLogs,
          )..where((row) => row.id.equals('set-old'))).go();
          await (db.delete(
            db.workoutSessionExercises,
          )..where((row) => row.id.equals('member-old'))).go();
          await (db.delete(
            db.workoutSessions,
          )..where((row) => row.id.equals('old'))).go();
        });
        final restored = await until((summary) => weight(summary).value == 110);
        expect(weight(restored).setLogId, 'set-new');
        expect(weight(restored).isBaseline, isTrue);
        await (db.update(db.workoutSessions)
              ..where((row) => row.id.equals('new')))
            .write(const WorkoutSessionsCompanion(status: Value('deleted')));
        expect(
          (await until((summary) => summary.current.isEmpty)).history,
          isEmpty,
        );
      },
    );

    test(
      'record provider includes earlier evidence before any display window',
      () async {
        await seed(
          'old-best',
          time: performedAt.subtract(const Duration(days: 60)),
          weight: 120,
        );
        await seed('recent', weight: 100);
        await seed('custom', exerciseId: -1, weight: 900);
        final container = ProviderContainer(
          overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);
        final provider = PersonalRecordProviders.recordsProvider(1);
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);
        await container.read(
          AnalyticsProviders.completedWorkingSetsProvider(
            const AnalyticsLogQuery(exerciseId: 1),
          ).future,
        );
        final summary = container.read(provider).requireValue;
        final weight = summary.current.singleWhere(
          (record) => record.type == PersonalRecordType.maxWeight,
        );
        expect(weight.setLogId, 'set-old-best');
        expect(weight.value, 120);
        expect(
          summary.current.every((record) => record.exerciseId == 1),
          isTrue,
        );
      },
    );

    test(
      'record provider preserves safe failures and recovers on query retry',
      () async {
        final retrying = _RetryingAnalyticsRepository(repository);
        final container = ProviderContainer(
          overrides: [
            AnalyticsProviders.repositoryProvider.overrideWithValue(retrying),
          ],
        );
        addTearDown(container.dispose);
        final provider = PersonalRecordProviders.recordsProvider(null);
        final source = AnalyticsProviders.completedWorkingSetsProvider(
          const AnalyticsLogQuery(),
        );
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);
        await expectLater(
          container.read(source.future),
          throwsA(AnalyticsQueryFailure.unavailable),
        );
        expect(
          container.read(provider).error,
          AnalyticsQueryFailure.unavailable,
        );
        retrying.shouldFail = false;
        container.invalidate(source);
        await container.read(source.future);
        expect(container.read(provider).requireValue.current, isEmpty);
      },
    );
  });

  test('empty local database returns an immutable empty result', () async {
    final result = await repository.loadCompletedWorkingSets();
    expect(result, isEmpty);
    expect(() => result.clear(), throwsUnsupportedError);
  });

  test(
    'only completed non-skipped working sets in finished sessions qualify',
    () async {
      await seed('valid');
      for (final status in [
        'in_progress',
        'abandoned',
        'cancelled',
        'deleted',
        'unknown',
      ]) {
        await seed(status, status: status);
      }
      await seed('warmup', setType: 'warmup', weight: 1000);
      await seed('unknown-type', setType: 'unknown');
      await seed('pending', completed: false);
      await seed('skipped', skipped: true);
      final logs = await repository.loadCompletedWorkingSets();
      expect(logs.map((log) => log.id), ['set-valid']);
      expect(logs.single.prescribedWeightKg, 105);
      expect(logs.single.actualWeightKg, 100);
      expect(logs.single.actualRpe, 8);
      expect(logs.single.actualRir, 2);
    },
  );

  test(
    'standalone, programme and saved workout sources use identical rules',
    () async {
      for (final source in SessionSource.values) {
        await seed(source.name, source: source.dbValue);
      }
      final logs = await repository.loadCompletedWorkingSets();
      expect(
        logs.map((log) => log.source).toSet(),
        SessionSource.values.toSet(),
      );
    },
  );

  test(
    'custom and canonical IDs remain distinct and exercise filter uses log identity',
    () async {
      await seed('canonical');
      await seed('custom', exerciseId: -1);
      await seed(
        'swapped',
        exerciseId: 1,
        memberExerciseId: 2,
        loggingType: 'duration',
      );
      final logs = await repository.loadCompletedWorkingSets(
        query: const AnalyticsLogQuery(exerciseId: 1),
      );
      expect(logs.map((log) => log.id), ['set-canonical', 'set-swapped']);
      expect(logs.last.loggingType, ExerciseLoggingType.repsWeight);
      final custom = await repository.loadCompletedWorkingSets(
        query: const AnalyticsLogQuery(exerciseId: -1),
      );
      expect(custom.single.exerciseId, -1);
    },
  );

  test(
    'range uses performed time with inclusive start and exclusive end',
    () async {
      await seed(
        'before',
        time: performedAt.subtract(const Duration(seconds: 1)),
      );
      await seed('start');
      await seed('end', time: performedAt.add(const Duration(days: 1)));
      final logs = await repository.loadCompletedWorkingSets(
        query: AnalyticsLogQuery(
          from: performedAt,
          until: performedAt.add(const Duration(days: 1)),
        ),
      );
      expect(logs.map((log) => log.id), ['set-start']);
      expect(
        logs.single.completedAt.toUtc(),
        performedAt.add(const Duration(hours: 1)),
      );
    },
  );

  test('chronology and equal-time ordering are stable across reads', () async {
    await seed('z');
    await seed('a');
    await seed('older', time: performedAt.subtract(const Duration(days: 1)));
    for (var read = 0; read < 2; read++) {
      final logs = await repository.loadCompletedWorkingSets();
      expect(logs.map((log) => log.id), ['set-older', 'set-a', 'set-z']);
    }
  });

  test('reversed and empty ranges fail safely for reads and watches', () async {
    for (final until in [
      performedAt,
      performedAt.subtract(const Duration(days: 1)),
    ]) {
      final query = AnalyticsLogQuery(from: performedAt, until: until);
      await expectLater(
        repository.loadCompletedWorkingSets(query: query),
        throwsA(AnalyticsQueryFailure.invalidRange),
      );
      await expectLater(
        repository.watchCompletedWorkingSets(query: query).first,
        throwsA(AnalyticsQueryFailure.invalidRange),
      );
    }
  });

  test(
    'canonical units and sparse bodyweight/timed actuals are preserved',
    () async {
      await seed('weighted', weight: 45.359237);
      await seed('reps', loggingType: 'repsOnly', weight: null, reps: 12);
      await seed(
        'timed',
        exerciseId: 2,
        loggingType: 'duration',
        weight: null,
        reps: null,
        duration: 120,
        distance: 400,
      );
      final logs = await repository.loadCompletedWorkingSets();
      final weighted = logs.firstWhere((log) => log.id == 'set-weighted');
      expect(weighted.actualWeightKg, 45.359237);
      final reps = logs.firstWhere((log) => log.id == 'set-reps');
      expect(reps.actualWeightKg, isNull);
      expect(reps.loggingType, ExerciseLoggingType.repsOnly);
      final timed = logs.firstWhere((log) => log.id == 'set-timed');
      expect(timed.actualReps, isNull);
      expect(timed.actualDurationSeconds, 120);
      expect(timed.actualDistanceMeters, 400);
      expect(timed.modality, ExerciseModality.cardio);
    },
  );

  test(
    'archived and missing catalogue entries preserve source history',
    () async {
      await seed('archived', exerciseId: -1);
      await seed('missing', exerciseId: 999);
      await (db.update(db.exercises)..where((row) => row.id.equals(-1))).write(
        ExercisesCompanion(deletedAt: Value(performedAt)),
      );
      final logs = await repository.loadCompletedWorkingSets();
      expect(logs.map((log) => log.id), ['set-archived', 'set-missing']);
      expect(logs.last.modality, isNull);
      expect(logs.last.loggingType, ExerciseLoggingType.repsWeight);
    },
  );

  test(
    'unknown metadata is nullable rather than silently treated as strength',
    () async {
      await seed('unknown', loggingType: 'future-mode');
      await (db.update(db.exercises)..where((row) => row.id.equals(1))).write(
        const ExercisesCompanion(modality: Value('future-modality')),
      );
      final log = (await repository.loadCompletedWorkingSets()).single;
      expect(log.modality, isNull);
      expect(log.loggingType, isNull);
    },
  );

  test('orphaned logs and memberships do not contribute', () async {
    await seed('missing-member');
    await seed('missing-session');
    await (db.delete(
      db.workoutSessionExercises,
    )..where((row) => row.id.equals('member-missing-member'))).go();
    await (db.delete(
      db.workoutSessions,
    )..where((row) => row.id.equals('missing-session'))).go();
    expect(await repository.loadCompletedWorkingSets(), isEmpty);
  });

  test(
    'query is read-only and does not expose private notes or derived flags',
    () async {
      await seed('valid');
      final before = (await db.select(db.setLogs).get()).single.toJson();
      final tablesBefore = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
          )
          .get();
      final log = (await repository.loadCompletedWorkingSets()).single;
      expect(log.toString(), isNot(contains(sentinel)));
      expect((await db.select(db.setLogs).get()).single.toJson(), before);
      final tablesAfter = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
          )
          .get();
      expect(
        tablesAfter.map((row) => row.data),
        tablesBefore.map((row) => row.data),
      );
    },
  );

  test(
    'watch refreshes after insert, correction, exclusion and hard deletion',
    () async {
      final iterator = StreamIterator(repository.watchCompletedWorkingSets());
      addTearDown(iterator.cancel);
      Future<List<AnalyticsSetLog>> next() async {
        expect(
          await iterator.moveNext().timeout(const Duration(seconds: 5)),
          isTrue,
        );
        return iterator.current;
      }

      expect(await next(), isEmpty);
      await seed('valid');
      expect((await next()).single.actualWeightKg, 100);
      await (db.update(db.setLogs)..where((row) => row.id.equals('set-valid')))
          .write(const SetLogsCompanion(actualWeightKg: Value(110)));
      expect((await next()).single.actualWeightKg, 110);
      await (db.update(db.setLogs)..where((row) => row.id.equals('set-valid')))
          .write(const SetLogsCompanion(setType: Value('warmup')));
      expect(await next(), isEmpty);
      await (db.update(db.setLogs)..where((row) => row.id.equals('set-valid')))
          .write(const SetLogsCompanion(setType: Value('working')));
      expect(await next(), hasLength(1));
      await (db.delete(
        db.setLogs,
      )..where((row) => row.id.equals('set-valid'))).go();
      expect(await next(), isEmpty);
    },
  );

  test(
    'watch tracks session completion/deletion, membership and catalogue edits',
    () async {
      await seed('active', status: 'in_progress');
      final iterator = StreamIterator(repository.watchCompletedWorkingSets());
      addTearDown(iterator.cancel);
      Future<List<AnalyticsSetLog>> next() async {
        expect(
          await iterator.moveNext().timeout(const Duration(seconds: 5)),
          isTrue,
        );
        return iterator.current;
      }

      expect(await next(), isEmpty);
      await (db.update(db.workoutSessions)
            ..where((row) => row.id.equals('active')))
          .write(const WorkoutSessionsCompanion(status: Value('completed')));
      expect(await next(), hasLength(1));
      await (db.update(
        db.workoutSessionExercises,
      )..where((row) => row.id.equals('member-active'))).write(
        const WorkoutSessionExercisesCompanion(loggingType: Value('repsOnly')),
      );
      expect((await next()).single.loggingType, ExerciseLoggingType.repsOnly);
      await (db.update(db.exercises)..where((row) => row.id.equals(1))).write(
        const ExercisesCompanion(modality: Value('recovery')),
      );
      expect((await next()).single.modality, ExerciseModality.recovery);
      await (db.update(db.workoutSessions)
            ..where((row) => row.id.equals('active')))
          .write(const WorkoutSessionsCompanion(status: Value('deleted')));
      expect(await next(), isEmpty);
    },
  );

  test('rolled-back log corrections leave analytics unchanged', () async {
    await seed('valid');
    await expectLater(
      db.transaction(() async {
        await db
            .update(db.setLogs)
            .write(const SetLogsCompanion(actualWeightKg: Value(999)));
        throw StateError('Synthetic rollback');
      }),
      throwsStateError,
    );
    expect(
      (await repository.loadCompletedWorkingSets()).single.actualWeightKg,
      100,
    );
  });

  test(
    'database failures expose only safe codes for reads and watches',
    () async {
      await db.close();
      db = AppDatabase(
        NativeDatabase.memory(
          setup: (_) {
            throw StateError(sentinel);
          },
        ),
      );
      final failed = DriftAnalyticsRepository(db);
      await expectLater(
        failed.loadCompletedWorkingSets(),
        throwsA(AnalyticsQueryFailure.unavailable),
      );
      await expectLater(
        failed.watchCompletedWorkingSets().first,
        throwsA(AnalyticsQueryFailure.unavailable),
      );
      expect(
        AnalyticsQueryFailure.unavailable.toString(),
        isNot(contains(sentinel)),
      );
    },
  );

  test(
    'Riverpod injects the local repository and exposes loading/empty states',
    () async {
      final container = ProviderContainer(
        overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final provider = AnalyticsProviders.completedWorkingSetsProvider(
        const AnalyticsLogQuery(),
      );
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      expect(container.read(provider).isLoading, isTrue);
      expect(await container.read(provider.future), isEmpty);
      container.invalidate(provider);
      expect(await container.read(provider.future), isEmpty);
      expect(
        container.read(AnalyticsProviders.repositoryProvider),
        isA<DriftAnalyticsRepository>(),
      );
    },
  );
  test(
    'Riverpod exposes a safe failure and retries through invalidation',
    () async {
      final retrying = _RetryingAnalyticsRepository(repository);
      final container = ProviderContainer(
        overrides: [
          AnalyticsProviders.repositoryProvider.overrideWithValue(retrying),
        ],
      );
      addTearDown(container.dispose);
      final provider = AnalyticsProviders.completedWorkingSetsProvider(
        const AnalyticsLogQuery(),
      );
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await expectLater(
        container.read(provider.future),
        throwsA(AnalyticsQueryFailure.unavailable),
      );
      expect(container.read(provider).error, AnalyticsQueryFailure.unavailable);
      retrying.shouldFail = false;
      container.invalidate(provider);
      expect(await container.read(provider.future), isEmpty);
      expect(container.read(provider).hasError, isFalse);
    },
  );
}

class _RetryingAnalyticsRepository implements AnalyticsRepository {
  _RetryingAnalyticsRepository(this.delegate);
  final AnalyticsRepository delegate;
  bool shouldFail = true;

  @override
  Future<List<AnalyticsSetLog>> loadCompletedWorkingSets({
    AnalyticsLogQuery query = const AnalyticsLogQuery(),
  }) => delegate.loadCompletedWorkingSets(query: query);

  @override
  Stream<List<AnalyticsSetLog>> watchCompletedWorkingSets({
    AnalyticsLogQuery query = const AnalyticsLogQuery(),
  }) => shouldFail
      ? Stream.error(AnalyticsQueryFailure.unavailable)
      : delegate.watchCompletedWorkingSets(query: query);
}
