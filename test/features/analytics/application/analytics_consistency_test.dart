import 'dart:async';

import 'package:aedify/app/bootstrap/analytics_consistency_providers.dart';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/application/analytics_view_providers.dart';
import 'package:aedify/features/analytics/application/estimated_one_rep_max_providers.dart';
import 'package:aedify/features/analytics/application/personal_record_providers.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:aedify/features/plateau_detection/data/plateau_repository.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_evaluation.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _Fixture fixture;
  setUp(() async {
    fixture = _Fixture();
    await fixture.seedExercise();
  });
  tearDown(() => fixture.dispose());

  test(
    'startup reconciles flags without opening Stats or reading its providers',
    () async {
      await fixture.seedHistory();
      fixture.startJob();
      await fixture.flagIs('open');
      expect(
        fixture.container.exists(
          AnalyticsViewProviders.dataProvider((
            range: AnalyticsRange.allTime,
            exerciseId: null,
          )),
        ),
        isFalse,
      );
      expect(
        fixture.container.exists(PersonalRecordProviders.recordsProvider(null)),
        isFalse,
      );
      final flag =
          (await fixture.db.select(fixture.db.plateauFlags).get()).single;
      expect(flag.basisJson, isNot(contains(_Fixture.sentinel)));
      expect(flag.basisJson, isNot(contains('set-')));
      expect(
        (await fixture.db.select(fixture.db.setLogs).get()).every(
          (row) =>
              row.notes == _Fixture.sentinel &&
              !row.isPr &&
              row.estimated1rmKg == null,
        ),
        isTrue,
      );
    },
  );

  test(
    'startup repairs a flag left stale while the app job was stopped',
    () async {
      await fixture.seedHistory();
      final repository = fixture.container.read(
        PlateauProviders.repositoryProvider,
      );
      await repository.recompute(now: _Fixture.now);
      await fixture.correct('3', weight: 120);
      expect(
        (await fixture.db.select(fixture.db.plateauFlags).get()).single.status,
        'open',
      );
      fixture.startJob();
      await fixture.flagIs('resolved');
      expect(
        fixture.container
            .read(PlateauProviders.evaluationsProvider)
            .requireValue
            .single
            .outcome,
        PlateauOutcome.progressing,
      );
    },
  );

  test(
    'real weight and rep corrections update PRs, e1RM, charts and durable flags',
    () async {
      await fixture.seedHistory();
      fixture.startJob();
      fixture.watchViews();
      await fixture.flagIs('open');
      await fixture.viewIs((data) => data.volumeKgReps == 2000);
      await fixture.correct('3', weight: 120, reps: 6);
      await fixture.viewIs((data) => data.volumeKgReps == 2220);
      await fixture.flagIs('resolved');
      final data = fixture.view!;
      expect(data.strengthTrend.last.value, closeTo(144, 1e-8));
      expect(data.sessionVolume.last.value, 720);
      expect(
        data.weeklyVolume.fold<double>(0, (sum, point) => sum + point.value),
        2220,
      );
      final records = fixture.container
          .read(PersonalRecordProviders.recordsProvider(-1))
          .requireValue;
      expect(
        records.current
            .singleWhere((r) => r.type == PersonalRecordType.maxWeight)
            .value,
        120,
      );
      expect(
        records.current
            .singleWhere((r) => r.type == PersonalRecordType.volume)
            .value,
        720,
      );
      final estimates = fixture.container
          .read(EstimatedOneRepMaxProviders.estimatesProvider(-1))
          .requireValue;
      expect(estimates.estimates.last.estimatedWeightKg, closeTo(144, 1e-8));
      // The raw source preserves canonical kg and the original prescription.
      final row = await (fixture.db.select(
        fixture.db.setLogs,
      )..where((t) => t.id.equals('set-3'))).getSingle();
      expect(row.actualWeightKg, 120);
      expect(row.prescribedRepsExact, 5);
      expect(row.estimated1rmKg, isNull);
      expect(row.isPr, isFalse);
    },
  );

  test(
    'older corrections rebuild the PR timeline instead of appending stale achievements',
    () async {
      await fixture.seedHistory();
      fixture.startJob();
      fixture.watchViews();
      await fixture.viewIs((data) => data.volumeKgReps == 2000);
      await fixture.correct('0', weight: 130);
      await fixture.viewIs((data) => data.volumeKgReps == 2150);
      final records = fixture.view!.records;
      final weights = records.history
          .where((r) => r.type == PersonalRecordType.maxWeight)
          .toList();
      expect(weights, hasLength(1));
      expect(weights.single.setLogId, 'set-0');
      expect(weights.single.isBaseline, isTrue);
      await fixture.correct('0', weight: 90);
      await fixture.viewIs((data) => data.volumeKgReps == 1950);
      expect(
        fixture.view!.records.current
            .singleWhere((r) => r.type == PersonalRecordType.maxWeight)
            .setLogId,
        'set-1',
      );
    },
  );

  test(
    'warmup to working and back invalidates every derived result but keeps saved history',
    () async {
      await fixture.seedHistory();
      await fixture.seedSession(
        'warmup',
        daysAgo: 0,
        type: 'warmup',
        weight: 999,
      );
      fixture.startJob();
      fixture.watchViews();
      await fixture.viewIs((data) => data.volumeKgReps == 2000);
      await fixture.flagIs('open');
      await fixture.writeSet(
        'warmup',
        const SetLogsCompanion(setType: Value('working')),
      );
      await fixture.viewIs((data) => data.volumeKgReps == 6995);
      await fixture.flagIs('resolved');
      expect(
        fixture.view!.records.current
            .singleWhere((r) => r.type == PersonalRecordType.maxWeight)
            .value,
        999,
      );
      await fixture.writeSet(
        'warmup',
        const SetLogsCompanion(setType: Value('warmup')),
      );
      await fixture.viewIs((data) => data.volumeKgReps == 2000);
      await fixture.flagIs('open');
      await _Fixture.until(() async {
        final history = fixture.container
            .read(AnalyticsViewProviders.historyProvider(-1))
            .asData
            ?.value;
        return history?.length == 5 &&
            history!.first.exercises.single.sets.single.setType.dbValue ==
                'warmup';
      });
      expect(
        fixture.view!.records.current
            .singleWhere((r) => r.type == PersonalRecordType.maxWeight)
            .value,
        100,
      );
    },
  );

  test(
    'deleting a completed session restores previous records and resolves its flag',
    () async {
      await fixture.seedHistory();
      await fixture.writeSet(
        '3',
        const SetLogsCompanion(actualWeightKg: Value(120)),
      );
      fixture.startJob();
      fixture.watchViews();
      await fixture.viewIs((data) => data.volumeKgReps == 2100);
      // First resolve a previously persisted flag as if from an earlier app run.
      await fixture.correct('3', weight: 100);
      await fixture.flagIs('open');
      await fixture.container
          .read(AppProviders.workoutSessionDaoProvider)
          .deleteSession('3');
      await fixture.viewIs(
        (data) => data.volumeKgReps == 1500 && data.sessions == 3,
      );
      await fixture.flagIs('resolved');
      await _Fixture.until(
        () async =>
            fixture.container
                .read(AnalyticsViewProviders.recentWorkoutsProvider)
                .asData
                ?.value
                .length ==
            3,
      );
      expect(
        fixture.view!.estimates.estimates.any((e) => e.sessionId == '3'),
        isFalse,
      );
      expect(
        fixture.view!.records.history.any((r) => r.sessionId == '3'),
        isFalse,
      );
      // Orphans cannot keep analytics alive; full cleanup also empties stale basis.
      await fixture.db.transaction(() async {
        await fixture.db.delete(fixture.db.setLogs).go();
        await fixture.db.delete(fixture.db.workoutSessionExercises).go();
        await fixture.db.delete(fixture.db.workoutSessions).go();
      });
      await fixture.viewIs((data) => !data.hasAnyHistory);
      await _Fixture.until(
        () async =>
            (await fixture.db.select(fixture.db.plateauFlags).get())
                .single
                .basisJson ==
            '{}',
      );
    },
  );

  test(
    'completion and cancellation reconcile without a Stats listener',
    () async {
      await fixture.seedHistory(lastStatus: 'in_progress');
      fixture.startJob();
      await fixture.container.read(PlateauProviders.evaluationsProvider.future);
      expect(await fixture.db.select(fixture.db.plateauFlags).get(), isEmpty);
      final dao = fixture.container.read(
        AppProviders.workoutSessionDaoProvider,
      );
      await dao.markCompleted(
        id: '3',
        completedAt: _Fixture.now,
        durationSeconds: 60,
        updatedAt: _Fixture.now,
      );
      await fixture.flagIs('open');
      await dao.markAbandoned(id: '3', updatedAt: _Fixture.now);
      await fixture.flagIs('resolved');
    },
  );

  test(
    'catalogue archive retains custom history and resolves active plateau',
    () async {
      await fixture.seedHistory();
      fixture.startJob();
      fixture.watchViews();
      await fixture.flagIs('open');
      await fixture.db
          .update(fixture.db.exercises)
          .write(ExercisesCompanion(deletedAt: Value(_Fixture.now)));
      await fixture.flagIs('resolved');
      await fixture.viewIs(
        (data) => data.sessions == 4 && data.volumeKgReps == 2000,
      );
      expect(fixture.view!.exercises.single.id, -1);
      expect(fixture.view!.estimates.estimates, hasLength(4));
    },
  );

  test(
    'warmup-only history edits and deletions refresh saved history with empty strength evidence',
    () async {
      await fixture.seedSession('warmup', type: 'warmup');
      fixture.watchViews();
      await fixture.viewIs((data) => !data.hasAnyHistory);
      await _Fixture.until(
        () async =>
            fixture.container
                .read(AnalyticsViewProviders.historyProvider(-1))
                .asData
                ?.value
                .length ==
            1,
      );
      await fixture.correct('warmup', weight: 70, reps: 8);
      await _Fixture.until(
        () async =>
            fixture.container
                .read(AnalyticsViewProviders.historyProvider(-1))
                .asData
                ?.value
                .single
                .exercises
                .single
                .sets
                .single
                .actualWeightKg ==
            70,
      );
      expect(fixture.view!.records.current, isEmpty);
      await fixture.container
          .read(AppProviders.workoutSessionDaoProvider)
          .deleteSession('warmup');
      await _Fixture.until(
        () async =>
            fixture.container
                    .read(AnalyticsViewProviders.historyProvider(-1))
                    .asData
                    ?.value
                    .isEmpty ==
                true &&
            fixture.container
                    .read(AnalyticsViewProviders.recentWorkoutsProvider)
                    .asData
                    ?.value
                    .isEmpty ==
                true,
      );
    },
  );

  test(
    'multi-set corrections publish committed results and rollback does not leak a partial record',
    () async {
      await fixture.seedHistory();
      await fixture.db
          .into(fixture.db.setLogs)
          .insert(
            SetLogsCompanion.insert(
              id: 'second',
              workoutSessionExerciseId: 'member-3',
              exerciseId: -1,
              performedAt: _Fixture.now.subtract(const Duration(days: 1)),
              setIndex: 1,
              completed: const Value(true),
              actualReps: const Value(5),
              actualWeightKg: const Value(100),
              createdAt: _Fixture.now,
              updatedAt: _Fixture.now,
            ),
          );
      fixture.startJob();
      fixture.watchViews();
      await fixture.viewIs((data) => data.volumeKgReps == 2500);
      await fixture.flagIs('open');
      final history = fixture.container.read(
        AppProviders.workoutHistoryRepositoryProvider,
      );
      final detail = (await history.getSessionDetail('3'))!;
      final corrections = [
        for (final item in detail.exercises.single.sets)
          WorkoutHistorySetCorrection(
            expected: item,
            actualWeightKg: 120,
            actualReps: 5,
          ),
      ];
      final before = (await fixture.db.select(fixture.db.setLogs).get())
          .map((r) => r.toJson())
          .toList();
      final flag =
          (await fixture.db.select(fixture.db.plateauFlags).get()).single;
      await fixture.db.customStatement(
        "CREATE TRIGGER fail_second BEFORE UPDATE ON set_logs WHEN NEW.id = 'second' BEGIN SELECT RAISE(ABORT, '${_Fixture.sentinel}'); END",
      );
      await expectLater(
        history.correctSession(sessionId: '3', corrections: corrections),
        throwsA(isA<Exception>()),
      );
      await fixture.db.customStatement('DROP TRIGGER fail_second');
      // Reading sources after the failed transaction establishes its rollback.
      expect(
        (await fixture.db.select(fixture.db.setLogs).get())
            .map((r) => r.toJson())
            .toList(),
        before,
      );
      expect(
        (await fixture.db.select(fixture.db.plateauFlags).get()).single,
        flag,
      );
      await fixture.container.pump();
      expect(fixture.view!.volumeKgReps, 2500);
      expect(fixture.volumes, everyElement(2500));
      await history.correctSession(sessionId: '3', corrections: corrections);
      await fixture.viewIs((data) => data.volumeKgReps == 2700);
      await fixture.flagIs('resolved');
      expect(fixture.volumes, everyElement(isIn([2500, 2700])));
    },
  );

  test(
    'failed flag write stays safe and recovers on the next source commit',
    () async {
      await fixture.seedHistory();
      fixture.startJob();
      await fixture.flagIs('open');
      await fixture.db.customStatement(
        "CREATE TRIGGER fail_flag BEFORE UPDATE ON plateau_flags BEGIN SELECT RAISE(ABORT, '${_Fixture.sentinel}'); END",
      );
      await fixture.correct('3', weight: 120);
      await _Fixture.until(
        () async => fixture.container
            .read(PlateauProviders.evaluationsProvider)
            .hasError,
      );
      final error = fixture.container.read(
        PlateauProviders.evaluationsProvider,
      );
      expect(error.error, PlateauFailure.unavailable);
      expect(error.error.toString(), isNot(contains(_Fixture.sentinel)));
      expect(error.stackTrace.toString(), isNot(contains(_Fixture.sentinel)));
      expect(
        (await fixture.db.select(fixture.db.plateauFlags).get()).single.status,
        'open',
      );
      await fixture.db.customStatement('DROP TRIGGER fail_flag');
      await fixture.correct('3', weight: 125);
      await fixture.flagIs('resolved');
      await _Fixture.until(
        () async =>
            fixture.container
                .read(PlateauProviders.evaluationsProvider)
                .asData
                ?.value
                .single
                .outcome ==
            PlateauOutcome.progressing,
      );
    },
  );

  test(
    'job gates startup, shares screen subscription and cancels on app disposal',
    () async {
      final fake = _ObservedPlateauRepository();
      final container = ProviderContainer(
        overrides: [
          AppBootstrap.controllerProvider.overrideWith(
            _ControlledBootstrap.new,
          ),
          PlateauProviders.repositoryProvider.overrideWithValue(fake),
          // Fail if a gate accidentally tries to open the database.
          AppProviders.appDatabaseProvider.overrideWith(
            (_) => throw StateError('database must remain unopened'),
          ),
        ],
      );
      addTearDown(container.dispose);
      final job = container.listen(
        AnalyticsConsistencyProviders.jobProvider,
        (_, _) {},
      );
      await container.pump();
      expect(fake.listens, 0);
      final bootstrap =
          container.read(AppBootstrap.controllerProvider.notifier)
              as _ControlledBootstrap;
      bootstrap.set(const BootstrapState.success(isOffline: true));
      await container.pump();
      expect(fake.listens, 1);
      final screen = container.listen(
        PlateauProviders.evaluationsProvider,
        (_, _) {},
      );
      await container.pump();
      expect(fake.listens, 1);
      screen.close();
      await container.pump();
      expect(fake.cancels, 0);
      bootstrap.set(const BootstrapState.initializing());
      await container.pump();
      expect(fake.cancels, 1);
      bootstrap.set(
        const BootstrapState.failure(
          BootstrapFailure(code: 'fixture', message: 'fixture'),
        ),
      );
      await container.pump();
      expect(fake.listens, 1);
      bootstrap.set(const BootstrapState.success());
      await container.pump();
      expect(fake.listens, 2);
      job.close();
      await container.pump();
      expect(fake.cancels, 2);
    },
  );
}

class _Fixture {
  static final now = DateTime.utc(2026, 11, 4, 12);
  static const sentinel = 'PRIVATE_ANALYTICS_CONSISTENCY_SENTINEL';
  final db = AppDatabase(NativeDatabase.memory());
  late final container = ProviderContainer(
    overrides: [
      AppProviders.appDatabaseProvider.overrideWithValue(db),
      AppBootstrap.controllerProvider.overrideWith(_ReadyBootstrap.new),
      PlateauProviders.clockProvider.overrideWithValue(() => now),
    ],
  );
  final subscriptions = <ProviderSubscription<Object?>>[];
  final volumes = <double?>[];
  static final viewProvider = AnalyticsViewProviders.dataProvider((
    range: AnalyticsRange.allTime,
    exerciseId: -1,
  ));
  AnalyticsViewData? get view => container.read(viewProvider).asData?.value;

  void startJob() => subscriptions.add(
    container.listen(AnalyticsConsistencyProviders.jobProvider, (_, _) {}),
  );
  void watchViews() {
    subscriptions.addAll([
      container.listen<AsyncValue<AnalyticsViewData>>(viewProvider, (_, state) {
        if (state.asData case final data?) volumes.add(data.value.volumeKgReps);
      }),
      container.listen(PersonalRecordProviders.recordsProvider(-1), (_, _) {}),
      container.listen(
        EstimatedOneRepMaxProviders.estimatesProvider(-1),
        (_, _) {},
      ),
      container.listen(
        AnalyticsViewProviders.recentWorkoutsProvider,
        (_, _) {},
      ),
      container.listen(AnalyticsViewProviders.historyProvider(-1), (_, _) {}),
    ]);
  }

  Future<void> seedExercise() => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: const Value(-1),
          source: 'custom',
          isCustom: const Value(true),
          name: 'Fixture press',
          nameNormalized: 'fixture press',
          primaryMusclesJson: '[]',
          muscleGroupsJson: '[]',
          modality: 'strength',
          loggingType: const Value('repsWeight'),
          gripsJson: '[]',
          stepsJson: '[]',
          userNotes: const Value(sentinel),
          createdAt: now,
          updatedAt: now,
        ),
      )
      .then((_) {});

  Future<void> seedHistory({String lastStatus = 'completed'}) async {
    for (var i = 0; i < 4; i++) {
      await seedSession(
        '$i',
        daysAgo: 4 - i,
        status: i == 3 ? lastStatus : 'completed',
      );
    }
  }

  Future<void> seedSession(
    String id, {
    int daysAgo = 1,
    String status = 'completed',
    String type = 'working',
    double weight = 100,
  }) => db.transaction(() async {
    final at = now.subtract(Duration(days: daysAgo));
    await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: id,
            source: 'standalone',
            name: 'Fixture workout',
            startedAt: at,
            completedAt: Value(at),
            status: status,
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
            exerciseId: -1,
            exerciseNameSnapshot: 'Fixture press',
            sortOrder: 0,
            loggingType: const Value('repsWeight'),
          ),
        );
    await db
        .into(db.setLogs)
        .insert(
          SetLogsCompanion.insert(
            id: 'set-$id',
            workoutSessionExerciseId: 'member-$id',
            exerciseId: -1,
            performedAt: at,
            setIndex: 0,
            setType: Value(type),
            completed: const Value(true),
            actualWeightKg: Value(weight),
            actualReps: const Value(5),
            prescribedRepsExact: const Value(5),
            notes: const Value(sentinel),
            createdAt: at,
            updatedAt: at,
          ),
        );
  });

  Future<void> correct(
    String id, {
    required double weight,
    int reps = 5,
  }) async {
    final history = container.read(
      AppProviders.workoutHistoryRepositoryProvider,
    );
    final detail = (await history.getSessionDetail(id))!;
    await history.correctSession(
      sessionId: id,
      corrections: [
        WorkoutHistorySetCorrection(
          expected: detail.exercises.single.sets.single,
          actualWeightKg: weight,
          actualReps: reps,
          notes: sentinel,
        ),
      ],
    );
  }

  Future<void> writeSet(String id, SetLogsCompanion change) => (db.update(
    db.setLogs,
  )..where((t) => t.id.equals('set-$id'))).write(change).then((_) {});
  Future<void> flagIs(String status) => until(
    () async =>
        (await db.select(db.plateauFlags).get()).singleOrNull?.status == status,
  );
  Future<void> viewIs(bool Function(AnalyticsViewData) predicate) =>
      until(() async => view != null && predicate(view!));
  static Future<void> until(Future<bool> Function() condition) async {
    for (var i = 0; i < 500; i++) {
      if (await condition()) return;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('Expected local reconciliation did not complete');
  }

  Future<void> dispose() async {
    for (final subscription in subscriptions) {
      subscription.close();
    }
    container.dispose();
    // Let cancelled stream subscriptions release their active transaction.
    await Future<void>.delayed(Duration.zero);
    await db.close();
  }
}

class _ReadyBootstrap extends BootstrapController {
  @override
  BootstrapState build() => const BootstrapState.success(isOffline: true);
}

class _ControlledBootstrap extends BootstrapController {
  @override
  BootstrapState build() => const BootstrapState.initializing();
  void set(BootstrapState value) => state = value;
}

class _ObservedPlateauRepository implements PlateauRepository {
  int listens = 0;
  int cancels = 0;
  @override
  Stream<List<PlateauEvaluation>> watchEvaluations({
    required DateTime Function() now,
  }) {
    late StreamController<List<PlateauEvaluation>> stream;
    stream = StreamController(
      onListen: () {
        listens++;
        stream.add([]);
      },
      onCancel: () {
        cancels++;
      },
    );
    return stream.stream;
  }

  @override
  Future<List<PlateauEvaluation>> recompute({required DateTime now}) =>
      throw UnimplementedError();
  @override
  Future<void> dismiss(int exerciseId, {required DateTime now}) =>
      throw UnimplementedError();
}
