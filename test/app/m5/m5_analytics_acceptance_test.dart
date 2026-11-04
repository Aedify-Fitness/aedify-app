import 'dart:convert';
import 'dart:io';

import 'package:aedify/app/bootstrap/analytics_consistency_providers.dart';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/application/analytics_providers.dart';
import 'package:aedify/features/analytics/application/analytics_view_providers.dart';
import 'package:aedify/features/analytics/domain/analytics_log_query.dart';
import 'package:aedify/features/analytics/domain/analytics_query_failure.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/domain/estimated_one_rep_max.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/features/analytics/presentation/analytics_format.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_evaluation.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late _M5Fixture fixture;
  late _BlockedNetwork network;
  late HttpOverrides? originalHttp;
  setUp(() async {
    originalHttp = HttpOverrides.current;
    network = _BlockedNetwork();
    HttpOverrides.global = network;
    fixture = await _M5Fixture.create();
  });
  tearDown(() async {
    try {
      await fixture.dispose();
      expect(
        network.attempts,
        0,
        reason: 'M5 must work without an HTTP client',
      );
    } finally {
      HttpOverrides.global = originalHttp;
    }
  });

  for (final scenario in _M5Case.all) {
    test('M5 fixture: ${scenario.name}', () async {
      await fixture.seed(scenario);
      if (scenario.correctLast) {
        fixture.startJob();
        await fixture.flagIs('open');
        await fixture.correctLast();
      }
      final sourceBefore = await fixture.sourceSnapshot();
      final tablesBefore = await fixture.tableNames();
      final rowCountsBefore = await fixture.rowCounts();
      final data = await fixture.view();
      expect(data.sessions, scenario.weights.length);
      expect(data.workingSets, scenario.weights.length);
      expect(data.volumeKgReps, scenario.volume);
      expect(data.hasAnyHistory, scenario.weights.isNotEmpty);
      if (scenario.weights.isEmpty) {
        expect(data.records.current, isEmpty);
        expect(data.estimates.hasInsufficientData, isTrue);
        expect(data.weeklyVolume, isEmpty);
        expect(data.strengthTrend, isEmpty);
      } else {
        expect(
          data.records.current
              .singleWhere((r) => r.type == PersonalRecordType.maxWeight)
              .value,
          scenario.bestWeight,
        );
        expect(
          data.records.current
              .singleWhere(
                (r) => r.type == PersonalRecordType.estimatedOneRepMax,
              )
              .value,
          closeTo(scenario.topEstimate!, 1e-8),
        );
        expect(
          data.strengthTrend.last.value,
          closeTo(scenario.topEstimate!, 1e-8),
        );
        expect(data.estimates.estimates, hasLength(4));
        expect(
          data.estimates.estimates.every(
            (e) => e.confidence == EstimatedOneRepMaxConfidence.standard,
          ),
          isTrue,
        );
        expect(data.weeklyVolume.map((point) => point.value), scenario.weeks);
        expect(data.currentWeekVolume, scenario.weeks.last);
        expect(data.previousWeekVolume, scenario.weeks[2]);
        expect(data.weekChangePercent, closeTo(scenario.weekChange!, 1e-8));
        expect(data.exercises.single.id, scenario.exerciseId);
        final evidence = await fixture.container
            .read(AnalyticsProviders.repositoryProvider)
            .loadCompletedWorkingSets(
              query: AnalyticsLogQuery(exerciseId: scenario.exerciseId),
            );
        expect(evidence.map((log) => log.source.dbValue).toSet(), {
          'program',
          'saved_workout',
          'standalone',
        });
        final history = await fixture.container
            .read(AppProviders.workoutHistoryRepositoryProvider)
            .listExerciseHistory(scenario.exerciseId);
        final sets = history
            .expand((session) => session.exercises)
            .expand((exercise) => exercise.sets)
            .toList();
        expect(sets, hasLength(scenario.warmups ? 16 : 4));
        expect(
          sets.where((set) => set.setType.dbValue == 'warmup'),
          hasLength(scenario.warmups ? 12 : 0),
        );
        // Conversion changes only presentation, never canonical evidence.
        final weight = data.records.current
            .singleWhere((r) => r.type == PersonalRecordType.maxWeight)
            .value
            .toDouble();
        expect(
          AnalyticsFormat.weight(weight, PreferredUnit.imperial),
          endsWith('lbs'),
        );
        expect(
          AnalyticsFormat.weight(weight, PreferredUnit.metric),
          endsWith('kg'),
        );
      }
      final evaluations = await fixture.container
          .read(PlateauProviders.repositoryProvider)
          .recompute(now: fixture.clock);
      if (scenario.outcome == null) {
        expect(evaluations, isEmpty);
      } else {
        expect(evaluations.single.outcome, scenario.outcome);
        expect(evaluations.single.qualifyingSessions, 4);
        if (scenario.outcome == PlateauOutcome.plateau) {
          expect(evaluations.single.reasons, containsAll(PlateauReason.values));
          final flag =
              (await fixture.db.select(fixture.db.plateauFlags).get()).single;
          expect(flag.status, 'open');
          final basis = jsonDecode(flag.basisJson) as Map<String, dynamic>;
          expect(basis['sessions_considered'], 4);
          expect(basis['recent_sessions'], hasLength(3));
          expect(flag.basisJson, isNot(contains(_M5Fixture.privateNote)));
          expect(flag.basisJson, isNot(contains('set-')));
          expect(flag.basisJson, isNot(contains('member-')));
        }
      }
      // A second evaluation is deterministic and read-only for source rows.
      final flagsBefore =
          (await fixture.db.select(fixture.db.plateauFlags).get())
              .map((row) => row.toJson())
              .toList();
      await fixture.view();
      await fixture.container
          .read(PlateauProviders.repositoryProvider)
          .recompute(now: fixture.clock);
      expect(await fixture.sourceSnapshot(), sourceBefore);
      expect(await fixture.tableNames(), tablesBefore);
      expect(await fixture.rowCounts(), rowCountsBefore);
      expect(
        (await fixture.db.select(fixture.db.plateauFlags).get())
            .map((row) => row.toJson())
            .toList(),
        flagsBefore,
      );
    });
  }

  test('M5 gate: recent programme deload suppresses a stalled lift', () async {
    await fixture.seed(_M5Case.plateau);
    await fixture.db
        .update(fixture.db.programWeeks)
        .write(const ProgramWeeksCompanion(weekType: Value('deload')));
    final result = await fixture.container
        .read(PlateauProviders.repositoryProvider)
        .recompute(now: fixture.clock);
    expect(result.single.outcome, PlateauOutcome.deload);
    expect(await fixture.db.select(fixture.db.plateauFlags).get(), isEmpty);
    expect((await fixture.view()).volumeKgReps, 2000);
  });

  test(
    'M5 gate: light sessions in an unknown programme week fail closed',
    () async {
      await fixture.seed(_M5Case.plateau);
      await (fixture.db.update(fixture.db.setLogs)
            ..where((row) => row.id.equals('set-3')))
          .write(const SetLogsCompanion(actualWeightKg: Value(40)));
      await fixture.db.delete(fixture.db.programWeeks).go();
      final result = await fixture.container
          .read(PlateauProviders.repositoryProvider)
          .recompute(now: fixture.clock);
      expect(result.single.outcome, PlateauOutcome.unknownContext);
      expect(await fixture.db.select(fixture.db.plateauFlags).get(), isEmpty);
    },
  );

  test(
    'M5 gate: warmup-only and unfinished workouts cannot manufacture a signal',
    () async {
      await fixture.seed(_M5Case.plateau);
      await fixture.db
          .update(fixture.db.setLogs)
          .write(const SetLogsCompanion(setType: Value('warmup')));
      expect((await fixture.view()).records.current, isEmpty);
      await (fixture.db.update(fixture.db.setLogs)
            ..where((row) => row.id.equals('set-0')))
          .write(const SetLogsCompanion(setType: Value('working')));
      for (final status in [
        'in_progress',
        'abandoned',
        'cancelled',
        'deleted',
      ]) {
        await (fixture.db.update(fixture.db.workoutSessions)
              ..where((row) => row.id.equals('session-0')))
            .write(WorkoutSessionsCompanion(status: Value(status)));
        expect((await fixture.view()).records.current, isEmpty);
        expect(
          await fixture.container
              .read(PlateauProviders.repositoryProvider)
              .recompute(now: fixture.clock),
          isEmpty,
        );
      }
      expect((await fixture.db.select(fixture.db.setLogs).get()), hasLength(4));
      expect(await fixture.db.select(fixture.db.plateauFlags).get(), isEmpty);
    },
  );

  test(
    'M5 gate: unsupported and high-rep evidence never creates reliable strength anchors',
    () async {
      await fixture.seed(_M5Case.plateau);
      await fixture.db
          .update(fixture.db.setLogs)
          .write(const SetLogsCompanion(actualReps: Value(20)));
      var data = await fixture.view();
      expect(data.estimates.estimates, hasLength(4));
      expect(data.estimates.anchorCandidates, isEmpty);
      expect(data.strengthTrend, isEmpty);
      expect(
        data.records.current.where(
          (r) => r.type == PersonalRecordType.estimatedOneRepMax,
        ),
        isEmpty,
      );
      expect(
        (await fixture.container
                .read(PlateauProviders.repositoryProvider)
                .recompute(now: fixture.clock))
            .single
            .outcome,
        PlateauOutcome.insufficientHistory,
      );
      await fixture.db
          .update(fixture.db.exercises)
          .write(const ExercisesCompanion(modality: Value('cardio')));
      data = await fixture.view();
      expect(data.estimates.hasInsufficientData, isTrue);
      expect(data.records.current, isEmpty);
    },
  );

  test(
    'M5 gate: deletion removes a corrected record and resolves stale flag evidence',
    () async {
      await fixture.seed(_M5Case.plateau);
      final repository = fixture.container.read(
        PlateauProviders.repositoryProvider,
      );
      await repository.recompute(now: fixture.clock);
      await fixture.correctLast();
      expect(
        (await fixture.view()).records.current
            .singleWhere((r) => r.type == PersonalRecordType.maxWeight)
            .value,
        120,
      );
      await fixture.container
          .read(AppProviders.workoutSessionDaoProvider)
          .deleteSession('session-3');
      final data = await fixture.view();
      expect(data.sessions, 3);
      expect(data.volumeKgReps, 1500);
      expect(
        data.records.current
            .singleWhere((r) => r.type == PersonalRecordType.maxWeight)
            .value,
        100,
      );
      expect(
        data.records.history.any((r) => r.sessionId == 'session-3'),
        isFalse,
      );
      expect(
        (await repository.recompute(now: fixture.clock)).single.outcome,
        PlateauOutcome.insufficientHistory,
      );
      expect(
        (await fixture.db.select(fixture.db.plateauFlags).get()).single.status,
        'resolved',
      );
    },
  );

  test(
    'M5 gate: disk reopen preserves dismissal and app job respects cooldown expiry',
    () async {
      await fixture.seed(_M5Case.plateau);
      final repository = fixture.container.read(
        PlateauProviders.repositoryProvider,
      );
      await repository.recompute(now: fixture.clock);
      await repository.dismiss(1, now: fixture.clock);
      final before = await fixture.sourceSnapshot();
      await fixture.reopen();
      fixture.startJob();
      await fixture.flagIs('dismissed');
      expect(await fixture.sourceSnapshot(), before);
      // All four exposures remain within 28 days after moving the clock: use a
      // dismissal from 14 days ago instead of moving today's evidence window.
      final expiry = fixture.clock;
      await fixture.db
          .update(fixture.db.plateauFlags)
          .write(
            PlateauFlagsCompanion(
              dismissedAt: Value(
                expiry
                    .subtract(const Duration(days: 14))
                    .add(const Duration(seconds: 1)),
              ),
            ),
          );
      await fixture.flagIs('dismissed');
      fixture.clock = expiry.add(const Duration(seconds: 1));
      await fixture.container
          .read(PlateauProviders.repositoryProvider)
          .recompute(now: fixture.clock);
      await fixture.flagIs('open');
    },
  );

  test(
    'M5 gate: invalid queries and failed flag writes expose safe recoverable errors',
    () async {
      await fixture.seed(_M5Case.plateau);
      final analytics = fixture.container.read(
        AnalyticsProviders.repositoryProvider,
      );
      await expectLater(
        analytics.loadCompletedWorkingSets(
          query: AnalyticsLogQuery(
            from: fixture.clock,
            until: fixture.clock.subtract(const Duration(days: 1)),
          ),
        ),
        throwsA(AnalyticsQueryFailure.invalidRange),
      );
      await fixture.db.customStatement(
        "CREATE TRIGGER acceptance_failure BEFORE INSERT ON plateau_flags BEGIN SELECT RAISE(ABORT, '${_M5Fixture.privateNote}'); END",
      );
      final repository = fixture.container.read(
        PlateauProviders.repositoryProvider,
      );
      await expectLater(
        repository.recompute(now: fixture.clock),
        throwsA(PlateauFailure.unavailable),
      );
      expect(await fixture.db.select(fixture.db.plateauFlags).get(), isEmpty);
      await fixture.db.customStatement('DROP TRIGGER acceptance_failure');
      expect(
        (await repository.recompute(now: fixture.clock)).single.outcome,
        PlateauOutcome.plateau,
      );
    },
  );
}

class _M5Case {
  const _M5Case(
    this.name,
    this.weights,
    this.volume,
    this.bestWeight,
    this.topEstimate,
    this.weeks,
    this.weekChange,
    this.outcome, {
    this.exerciseId = 1,
    this.reps = 5,
    this.warmups = false,
    this.correctLast = false,
  });
  final String name;
  final List<double> weights;
  final double? volume;
  final double? bestWeight;
  final double? topEstimate;
  final List<double> weeks;
  final double? weekChange;
  final PlateauOutcome? outcome;
  final int exerciseId;
  final int reps;
  final bool warmups;
  final bool correctLast;
  static const plateau = _M5Case(
    'plateau',
    [100, 100, 100, 100],
    2000,
    100,
    116.66666666666667,
    [500, 500, 500, 500],
    0,
    PlateauOutcome.plateau,
  );
  static const all = [
    _M5Case('no-history', [], null, null, null, [], null, null),
    _M5Case(
      'progression',
      [80, 85, 90, 95],
      1750,
      95,
      110.83333333333333,
      [400, 425, 450, 475],
      5.555555555555555,
      PlateauOutcome.progressing,
    ),
    plateau,
    _M5Case(
      'warmup-heavy',
      [100, 100, 100, 100],
      2000,
      100,
      116.66666666666667,
      [500, 500, 500, 500],
      0,
      PlateauOutcome.plateau,
      warmups: true,
    ),
    _M5Case(
      'corrected-log',
      [100, 100, 100, 100],
      2220,
      120,
      144,
      [500, 500, 500, 720],
      44,
      PlateauOutcome.progressing,
      correctLast: true,
    ),
    _M5Case(
      'custom-exercise',
      [30, 30, 32.5, 35],
      1020,
      35,
      44.333333333333336,
      [240, 240, 260, 280],
      7.6923076923076925,
      PlateauOutcome.progressing,
      exerciseId: -9,
      reps: 8,
    ),
  ];
}

class _M5Fixture {
  _M5Fixture(this.directory)
    : file = File(p.join(directory.path, 'acceptance.sqlite')) {
    _open();
  }
  static const privateNote = 'M5_PRIVATE_NOTE_SENTINEL';
  static final now = DateTime(2026, 11, 4, 12);
  static const daysAgo = [18, 11, 4, 1];
  final Directory directory;
  final File file;
  late AppDatabase db;
  late ProviderContainer container;
  DateTime clock = now;
  int exerciseId = 1;
  final subscriptions = <ProviderSubscription<Object?>>[];
  static Future<_M5Fixture> create() async => _M5Fixture(
    await Directory.systemTemp.createTemp('aedify_m5_acceptance_'),
  );
  void _open() {
    db = AppDatabase(NativeDatabase(file));
    container = ProviderContainer(
      overrides: [
        AppProviders.appDatabaseProvider.overrideWithValue(db),
        PlateauProviders.clockProvider.overrideWithValue(() => clock),
        AppBootstrap.controllerProvider.overrideWith(_ReadyBootstrap.new),
      ],
    );
  }

  Future<void> seed(_M5Case scenario) async {
    exerciseId = scenario.exerciseId;
    await db.transaction(() async {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: Value(exerciseId),
              source: exerciseId < 0 ? 'custom' : 'musclewiki',
              isCustom: Value(exerciseId < 0),
              name: 'Fixture press',
              nameNormalized: 'fixture press',
              primaryMusclesJson: '[]',
              muscleGroupsJson: '[]',
              modality: 'strength',
              loggingType: const Value('repsWeight'),
              gripsJson: '[]',
              stepsJson: '[]',
              userNotes: const Value(privateNote),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.programs)
          .insert(
            ProgramsCompanion.insert(
              id: 'program',
              name: 'Fixture programme',
              source: 'ai_generated',
              creationMethod: 'ai',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.programWeeks)
          .insert(
            ProgramWeeksCompanion.insert(
              id: 'week',
              programId: 'program',
              weekNumber: 1,
              weekType: const Value('normal'),
            ),
          );
      await db
          .into(db.programWorkouts)
          .insert(
            ProgramWorkoutsCompanion.insert(
              id: 'workout',
              programId: 'program',
              programWeekId: const Value('week'),
              occurrenceRef: 'day',
              name: 'Fixture day',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.savedWorkouts)
          .insert(
            SavedWorkoutsCompanion.insert(
              id: 'saved',
              name: 'Fixture imported workout',
              source: 'manual',
              creationMethod: 'import',
              imported: const Value(true),
              importOrigin: const Value('external_text'),
              importReviewStatus: const Value('reviewed'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (var i = 0; i < scenario.weights.length; i++) {
        final at = now.subtract(Duration(days: daysAgo[i]));
        final source = ['program', 'saved_workout', 'standalone', 'program'][i];
        await db
            .into(db.workoutSessions)
            .insert(
              WorkoutSessionsCompanion.insert(
                id: 'session-$i',
                source: source,
                programId: Value(source == 'program' ? 'program' : null),
                programWorkoutId: Value(source == 'program' ? 'workout' : null),
                savedWorkoutId: Value(
                  source == 'saved_workout' ? 'saved' : null,
                ),
                name: 'Fixture workout',
                status: 'completed',
                startedAt: at,
                completedAt: Value(at),
                notes: const Value(privateNote),
                bodyweightKgAtSession: const Value(73.219),
                createdAt: at,
                updatedAt: at,
              ),
            );
        await db
            .into(db.workoutSessionExercises)
            .insert(
              WorkoutSessionExercisesCompanion.insert(
                id: 'member-$i',
                workoutSessionId: 'session-$i',
                exerciseId: exerciseId,
                exerciseNameSnapshot: 'Fixture press',
                sortOrder: 0,
                loggingType: const Value('repsWeight'),
                notes: const Value(privateNote),
              ),
            );
        for (var warmup = 0; warmup < (scenario.warmups ? 3 : 0); warmup++) {
          await _set(
            i,
            at,
            'warmup-$i-$warmup',
            warmup,
            'warmup',
            [500.0, 750.0, 1000.0][warmup],
            20,
          );
        }
        await _set(
          i,
          at,
          'set-$i',
          scenario.warmups ? 3 : 0,
          'working',
          scenario.weights[i],
          scenario.reps,
        );
      }
    });
  }

  Future<void> _set(
    int index,
    DateTime at,
    String id,
    int order,
    String type,
    double weight,
    int reps,
  ) => db
      .into(db.setLogs)
      .insert(
        SetLogsCompanion.insert(
          id: id,
          workoutSessionExerciseId: 'member-$index',
          exerciseId: exerciseId,
          performedAt: at,
          setIndex: order,
          setType: Value(type),
          completed: const Value(true),
          actualWeightKg: Value(weight),
          actualReps: Value(reps),
          prescribedRepsExact: Value(reps + 1),
          actualRpe: const Value(9),
          notes: const Value(privateNote),
          createdAt: at,
          updatedAt: at,
        ),
      )
      .then((_) {});
  Future<AnalyticsViewData> view() async {
    final logs = await container
        .read(AnalyticsProviders.repositoryProvider)
        .loadCompletedWorkingSets(
          query: AnalyticsLogQuery(exerciseId: exerciseId),
        );
    // Read the same public provider as the screens; keep it alive until source
    // stream delivery rather than replacing it with a precomputed test result.
    final provider = AnalyticsViewProviders.dataProvider((
      range: AnalyticsRange.fourWeeks,
      exerciseId: exerciseId,
    ));
    final subscription = container.listen(provider, (_, _) {});
    subscriptions.add(subscription);
    await container.read(
      AnalyticsProviders.completedWorkingSetsProvider(
        AnalyticsLogQuery(exerciseId: exerciseId),
      ).future,
    );
    final query = AnalyticsLogQuery(exerciseId: exerciseId);
    final expected = logs
        .map(
          (log) =>
              '${log.id}:${log.actualWeightKg}:${log.actualReps}:${log.modality?.name}',
        )
        .join('|');
    await until(() async {
      final current = container
          .read(AnalyticsProviders.completedWorkingSetsProvider(query))
          .asData
          ?.value;
      return current != null &&
          current
                  .map(
                    (log) =>
                        '${log.id}:${log.actualWeightKg}:${log.actualReps}:${log.modality?.name}',
                  )
                  .join('|') ==
              expected &&
          container.read(provider).asData != null;
    });
    return container.read(provider).requireValue;
  }

  void startJob() => subscriptions.add(
    container.listen(AnalyticsConsistencyProviders.jobProvider, (_, _) {}),
  );
  Future<void> correctLast() async {
    final history = container.read(
      AppProviders.workoutHistoryRepositoryProvider,
    );
    final detail = (await history.getSessionDetail('session-3'))!;
    await history.correctSession(
      sessionId: 'session-3',
      corrections: [
        WorkoutHistorySetCorrection(
          expected: detail.exercises.single.sets.singleWhere(
            (s) => s.id == 'set-3',
          ),
          actualWeightKg: 120,
          actualReps: 6,
          actualRpe: 9,
          notes: privateNote,
        ),
      ],
    );
  }

  Future<void> flagIs(String status) => until(
    () async =>
        (await db.select(db.plateauFlags).get()).singleOrNull?.status == status,
  );
  Future<String> sourceSnapshot() async {
    final values = <String, Object?>{};
    for (final table in [
      'workout_sessions',
      'workout_session_exercises',
      'set_logs',
      'exercises',
      'programs',
      'program_weeks',
      'program_workouts',
      'saved_workouts',
    ]) {
      values[table] =
          (await db.customSelect('SELECT * FROM $table ORDER BY id').get())
              .map((row) => row.data)
              .toList();
    }
    return jsonEncode(values);
  }

  Future<List<String>> tableNames() async =>
      (await db
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
              )
              .get())
          .map((row) => row.read<String>('name'))
          .toList();

  Future<Map<String, int>> rowCounts() async {
    final counts = <String, int>{};
    for (final table in await tableNames()) {
      if (table == 'plateau_flags') continue;
      final row = await db
          .customSelect('SELECT COUNT(*) AS count FROM "$table"')
          .getSingle();
      counts[table] = row.read<int>('count');
    }
    return counts;
  }

  Future<void> reopen() async {
    for (final subscription in subscriptions) {
      subscription.close();
    }
    subscriptions.clear();
    container.dispose();
    await Future<void>.delayed(Duration.zero);
    await db.close();
    _open();
  }

  Future<void> dispose() async {
    for (final subscription in subscriptions) {
      subscription.close();
    }
    container.dispose();
    await Future<void>.delayed(Duration.zero);
    await db.close();
    await directory.delete(recursive: true);
  }

  static Future<void> until(Future<bool> Function() predicate) async {
    for (var i = 0; i < 1000; i++) {
      if (await predicate()) return;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('M5 fixture did not reach the expected committed state');
  }
}

class _ReadyBootstrap extends BootstrapController {
  @override
  BootstrapState build() => const BootstrapState.success(isOffline: true);
}

class _BlockedNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('HTTP is blocked for M5 acceptance');
  }
}
