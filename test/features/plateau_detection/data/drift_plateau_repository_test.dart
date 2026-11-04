import 'dart:convert';
import 'dart:io';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/data/drift_analytics_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:aedify/features/plateau_detection/data/drift_plateau_repository.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_evaluation.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 10, 26, 12);
  const sentinel = 'PRIVATE_PLATEAU_SOURCE_SENTINEL';
  DriftPlateauRepository repository() =>
      DriftPlateauRepository(db, DriftAnalyticsRepository(db));
  Future<void> exercise(int id) => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: Value(id),
          source: id < 0 ? 'custom' : 'musclewiki',
          isCustom: Value(id < 0),
          name: 'Synthetic exercise',
          nameNormalized: 'synthetic exercise',
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
  Future<void> seed(
    String id, {
    int exerciseId = 1,
    int daysAgo = 1,
    String status = 'completed',
    String source = 'standalone',
    String type = 'working',
    bool completed = true,
    bool skipped = false,
    double weight = 100,
    int reps = 5,
    String? programId,
    String? workoutId,
  }) => db.transaction(() async {
    final at = now.subtract(Duration(days: daysAgo));
    await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: id,
            source: source,
            name: 'Synthetic session',
            startedAt: at,
            completedAt: Value(at),
            status: status,
            notes: const Value(sentinel),
            programId: Value(programId),
            programWorkoutId: Value(workoutId),
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
            exerciseId: exerciseId,
            exerciseNameSnapshot: 'Synthetic exercise',
            sortOrder: 0,
            loggingType: const Value('repsWeight'),
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
            setType: Value(type),
            completed: Value(completed),
            skipped: Value(skipped),
            actualWeightKg: Value(weight),
            actualReps: Value(reps),
            prescribedRepsExact: const Value(6),
            actualRpe: const Value(9),
            notes: const Value(sentinel),
            createdAt: at,
            updatedAt: at,
          ),
        );
  });
  Future<void> history({int exerciseId = 1, String prefix = 'session'}) async {
    for (var i = 0; i < 4; i++) {
      await seed('$prefix-$i', exerciseId: exerciseId, daysAgo: 4 - i);
    }
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await exercise(1);
  });
  tearDown(() => db.close());

  test(
    'unknown session sources cannot imply known non-deload context',
    () async {
      for (var i = 0; i < 4; i++) {
        await seed('unknown-$i', daysAgo: i + 1, source: 'future-source');
      }
      expect(
        (await repository().recompute(now: now)).single.outcome,
        PlateauOutcome.unknownContext,
      );
      expect(await db.select(db.plateauFlags).get(), isEmpty);
    },
  );

  test(
    'flat history persists one sanitized local flag without changing source logs',
    () async {
      await history();
      final before = (await db.select(db.setLogs).get())
          .map((row) => row.toJson())
          .toList();
      final results = await repository().recompute(now: now);
      expect(results.single.outcome, PlateauOutcome.plateau);
      final flag = (await db.select(db.plateauFlags).get()).single;
      expect(flag.status, 'open');
      expect(flag.plateauType, 'e1rm_stall');
      expect(flag.exerciseId, 1);
      expect(flag.basisJson, isNot(contains(sentinel)));
      expect(flag.basisJson, isNot(contains('session-')));
      final basis = jsonDecode(flag.basisJson) as Map<String, dynamic>;
      expect(basis['sessions_considered'], 4);
      expect(basis['slope_kg_per_session'], 0);
      expect(basis['reason_codes'], [
        'nonIncreasingE1rm',
        'missedTargets',
        'highEffort',
      ]);
      expect((basis['recent_sessions'] as List), hasLength(3));
      await repository().recompute(now: now.add(const Duration(minutes: 1)));
      expect((await db.select(db.plateauFlags).get()).single, flag);
      expect(
        (await db.select(db.setLogs).get()).map((row) => row.toJson()).toList(),
        before,
      );
    },
  );

  test(
    'warmup/incomplete/skipped and inactive sessions cannot supply minimum history',
    () async {
      await seed('valid');
      await seed('warmup', type: 'warmup');
      await seed('pending', completed: false);
      await seed('skipped', skipped: true);
      for (final status in [
        'in_progress',
        'abandoned',
        'cancelled',
        'deleted',
      ]) {
        await seed(status, status: status);
      }
      final result = (await repository().recompute(now: now)).single;
      expect(result.outcome, PlateauOutcome.insufficientHistory);
      expect(result.qualifyingSessions, 1);
      expect(await db.select(db.plateauFlags).get(), isEmpty);
    },
  );

  test('canonical and custom exercises have distinct flags', () async {
    await exercise(-1);
    await history();
    await history(exerciseId: -1, prefix: 'custom');
    expect(await repository().recompute(now: now), hasLength(2));
    final flags = await db.select(db.plateauFlags).get();
    expect(flags.map((flag) => flag.exerciseId).toSet(), {1, -1});
  });

  test('programme week deload and broken ownership fail closed', () async {
    await db
        .into(db.programWeeks)
        .insert(
          ProgramWeeksCompanion.insert(
            id: 'week',
            programId: 'program',
            weekNumber: 1,
            weekType: const Value('deload'),
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
            name: 'Synthetic day',
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (var i = 0; i < 4; i++) {
      await seed(
        'program-$i',
        daysAgo: 4 - i,
        source: 'program',
        programId: 'program',
        workoutId: 'workout',
      );
    }
    expect(
      (await repository().recompute(now: now)).single.outcome,
      PlateauOutcome.deload,
    );
    expect(await db.select(db.plateauFlags).get(), isEmpty);
    await db
        .update(db.programWeeks)
        .write(const ProgramWeeksCompanion(weekType: Value('normal')));
    expect(
      (await repository().recompute(now: now)).single.outcome,
      PlateauOutcome.plateau,
    );
    await db
        .update(db.programWorkouts)
        .write(
          const ProgramWorkoutsCompanion(programId: Value('different-program')),
        );
    expect(
      (await repository().recompute(now: now)).single.outcome,
      PlateauOutcome.unknownContext,
    );
    expect((await db.select(db.plateauFlags).get()).single.status, 'resolved');
  });

  test(
    'real history correction resolves a flag and deletion clears stale basis',
    () async {
      await history();
      await repository().recompute(now: now);
      final container = ProviderContainer(
        overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final historyRepository = container.read(
        AppProviders.workoutHistoryRepositoryProvider,
      );
      final detail = (await historyRepository.getSessionDetail('session-3'))!;
      await historyRepository.correctSession(
        sessionId: 'session-3',
        corrections: [
          WorkoutHistorySetCorrection(
            expected: detail.exercises.single.sets.single,
            actualReps: 5,
            actualWeightKg: 120,
          ),
        ],
      );
      expect(
        (await repository().recompute(now: now)).single.outcome,
        PlateauOutcome.progressing,
      );
      expect(
        (await db.select(db.plateauFlags).get()).single.status,
        'resolved',
      );
      await db.delete(db.workoutSessions).go();
      expect(await repository().recompute(now: now), isEmpty);
      final flag = (await db.select(db.plateauFlags).get()).single;
      expect(flag.status, 'resolved');
      expect(flag.basisJson, '{}');
    },
  );

  test('archived and substituted exercises resolve existing flags', () async {
    await history();
    await repository().recompute(now: now);
    await db
        .update(db.exercises)
        .write(const ExercisesCompanion(isSubstitutedOut: Value(true)));
    expect(
      (await repository().recompute(now: now)).single.outcome,
      PlateauOutcome.inactive,
    );
    expect((await db.select(db.plateauFlags).get()).single.status, 'resolved');
  });

  test('dismissal is idempotent and lasts exactly 14 days', () async {
    await history();
    await repository().recompute(now: now);
    await repository().dismiss(1, now: now);
    await repository().dismiss(1, now: now.add(const Duration(days: 1)));
    expect(
      (await db.select(db.plateauFlags).get()).single.dismissedAt!.toUtc(),
      now,
    );
    expect(
      (await repository().recompute(
        now: now.add(const Duration(days: 13, hours: 23)),
      )).single.outcome,
      PlateauOutcome.dismissed,
    );
    expect(
      (await repository().recompute(
        now: now.add(const Duration(days: 14)),
      )).single.outcome,
      PlateauOutcome.plateau,
    );
    expect((await db.select(db.plateauFlags).get()).single.status, 'open');
    await expectLater(
      repository().dismiss(999, now: now),
      throwsA(PlateauFailure.missing),
    );
    await repository().recompute(now: now.add(const Duration(days: 40)));
    await expectLater(
      repository().dismiss(1, now: now),
      throwsA(PlateauFailure.missing),
    );
  });

  test(
    'multi-exercise recompute rolls back all writes and sanitizes SQL failures',
    () async {
      await exercise(2);
      await history();
      await history(exerciseId: 2, prefix: 'second');
      await db.customStatement(
        "CREATE TRIGGER fail_plateau BEFORE INSERT ON plateau_flags WHEN NEW.exercise_id = 2 BEGIN SELECT RAISE(ABORT, '$sentinel'); END",
      );
      await expectLater(
        repository().recompute(now: now),
        throwsA(PlateauFailure.unavailable),
      );
      expect(await db.select(db.plateauFlags).get(), isEmpty);
      await expectLater(
        repository().watchEvaluations(now: () => now).first,
        throwsA(PlateauFailure.unavailable),
      );
      await db.customStatement('DROP TRIGGER fail_plateau');
      expect(await repository().recompute(now: now), hasLength(2));
    },
  );

  test(
    'dismissal controller preserves a flag on failure and permits retry',
    () async {
      await history();
      await repository().recompute(now: now);
      final container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          PlateauProviders.clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      final provider = PlateauProviders.dismissalProvider(1);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await db.customStatement(
        "CREATE TRIGGER fail_dismiss BEFORE UPDATE ON plateau_flags BEGIN SELECT RAISE(ABORT, '$sentinel'); END",
      );
      expect(await container.read(provider.notifier).dismiss(), isFalse);
      expect(container.read(provider).error, PlateauFailure.unavailable);
      expect((await db.select(db.plateauFlags).get()).single.status, 'open');
      await db.customStatement('DROP TRIGGER fail_dismiss');
      expect(await container.read(provider.notifier).dismiss(), isTrue);
      expect(
        (await db.select(db.plateauFlags).get()).single.status,
        'dismissed',
      );
    },
  );

  test(
    'live provider detects source changes and dismissal without self-trigger loops',
    () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          PlateauProviders.clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      final provider = PlateauProviders.evaluationsProvider;
      final events = <List<PlateauEvaluation>>[];
      final subscription = container.listen(provider, (_, state) {
        if (state.asData case final data?) events.add(data.value);
      });
      addTearDown(subscription.close);
      Future<void> until(bool Function() condition) async {
        for (var attempt = 0; attempt < 1000 && !condition(); attempt++) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
        expect(condition(), isTrue);
      }

      expect(await container.read(provider.future), isEmpty);
      await history();
      await until(
        () =>
            events.isNotEmpty &&
            events.last.isNotEmpty &&
            events.last.single.outcome == PlateauOutcome.plateau,
      );
      await repository().dismiss(1, now: now);
      await until(() => events.last.single.outcome == PlateauOutcome.dismissed);
      await db.delete(db.workoutSessions).go();
      await until(() => events.last.isEmpty);
      expect(
        (await db.select(db.plateauFlags).get()).single.status,
        'resolved',
      );
      expect(events.length, lessThan(30));
    },
  );

  test(
    'v18 migration preserves source logs and dismissal survives reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp('plateau_v19_');
      addTearDown(() => directory.delete(recursive: true));
      final file = File(p.join(directory.path, 'fixture.sqlite'));
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      await exercise(1);
      await history();
      final before = (await db.select(db.setLogs).get())
          .map((row) => row.toJson())
          .toList();
      for (final table in [
        'progress_media_items',
        'progress_media_sessions',
        'progress_measurement_snapshots',
        'progress_media_reminder_settings',
      ]) {
        await db.customStatement('DROP TABLE $table');
      }
      await db.customStatement('DROP TABLE plateau_flags');
      await db.customStatement('PRAGMA user_version = 18');
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      expect(await db.select(db.plateauFlags).get(), isEmpty);
      expect(
        (await db.select(db.setLogs).get()).map((row) => row.toJson()).toList(),
        before,
      );
      expect(
        (await db.select(db.schemaMigrationsLog).get()).any(
          (row) => row.fromVersion == 18 && row.toVersion == 20,
        ),
        isTrue,
      );
      await repository().recompute(now: now);
      await repository().dismiss(1, now: now);
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      expect(
        (await repository().recompute(
          now: now.add(const Duration(days: 1)),
        )).single.outcome,
        PlateauOutcome.dismissed,
      );
      expect(
        (await db.select(db.plateauFlags).get()).single.dismissedAt!.toUtc(),
        now,
      );
    },
  );
}
