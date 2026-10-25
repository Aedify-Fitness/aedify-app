import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/set_log_dao.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/core/db/daos/workout_session_exercise_dao.dart';
import 'package:aedify/features/lift_log/data/drift_workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftWorkoutHistoryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftWorkoutHistoryRepository(
      workoutSessionDao: WorkoutSessionDao(db),
      workoutSessionExerciseDao: WorkoutSessionExerciseDao(db),
      setLogDao: SetLogDao(db),
    );
  });

  tearDown(() => db.close());

  test(
    'correction updates only actual results and clears stale derived values',
    () async {
      await _HistoryFixture.seed(db);
      final before = (await repository.getSessionDetail('session'))!;
      final expected = before.exercises.single.sets.first;
      await repository.correctSession(
        sessionId: 'session',
        corrections: [
          WorkoutHistorySetCorrection(
            expected: expected,
            actualReps: 9,
            actualWeightKg: 105,
            actualDurationSeconds: 60,
            actualDistanceMeters: 250,
            actualRpe: 8.5,
            actualRir: 2,
            notes: 'Corrected locally',
          ),
        ],
      );
      final after = (await repository.getSessionDetail('session'))!;
      final set = after.exercises.single.sets.first;
      expect(set.id, expected.id);
      expect(set.actualReps, 9);
      expect(set.actualWeightKg, 105);
      expect(set.actualDurationSeconds, 60);
      expect(set.actualDistanceMeters, 250);
      expect(set.actualRpe, 8.5);
      expect(set.actualRir, 2);
      expect(set.notes, 'Corrected locally');
      expect(set.prescribedRepsExact, 8);
      expect(set.prescribedDurationSeconds, 45);
      expect(set.prescribedDistanceMeters, 200);
      expect(set.prescribedRir, 3);
      expect(set.completed, isTrue);
      expect(after.exercises.single.exerciseName, 'Original exercise snapshot');
      expect(after.exercises.single.supersetGroupId, 'original-group');
      expect(after.startedAt, before.startedAt);
      expect(after.completedAt, before.completedAt);
      final raw = await (db.select(
        db.setLogs,
      )..where((t) => t.id.equals(expected.id))).getSingle();
      expect(raw.isPr, isFalse);
      expect(raw.estimated1rmKg, isNull);
      expect(raw.performedAt, _HistoryFixture.at);
      expect(raw.createdAt, _HistoryFixture.at);

      await repository.correctSession(
        sessionId: 'session',
        corrections: [
          WorkoutHistorySetCorrection(
            expected: set,
            actualReps: 9,
            actualWeightKg: 105,
          ),
        ],
      );
      final cleared = (await repository.getSessionDetail(
        'session',
      ))!.exercises.single.sets.first;
      expect(cleared.actualWeightKg, 105);
      expect(cleared.actualDurationSeconds, isNull);
      expect(cleared.notes, isNull);
      expect(cleared.prescribedRepsExact, 8);
    },
  );

  test(
    'invalid, duplicate and non-finite input leaves results untouched',
    () async {
      await _HistoryFixture.seed(db);
      final expected = (await repository.getSessionDetail(
        'session',
      ))!.exercises.single.sets.first;
      final invalid = [
        WorkoutHistorySetCorrection(expected: expected, actualReps: 0),
        WorkoutHistorySetCorrection(
          expected: expected,
          actualDurationSeconds: -1,
        ),
        WorkoutHistorySetCorrection(
          expected: expected,
          actualWeightKg: double.nan,
        ),
        WorkoutHistorySetCorrection(
          expected: expected,
          actualDistanceMeters: double.infinity,
        ),
        WorkoutHistorySetCorrection(expected: expected, actualRpe: 10.5),
        WorkoutHistorySetCorrection(expected: expected, actualRir: 6),
      ];
      for (final correction in invalid) {
        await expectLater(
          repository.correctSession(
            sessionId: 'session',
            corrections: [correction],
          ),
          throwsA(WorkoutHistoryCorrectionFailure.invalid),
        );
      }
      final correction = WorkoutHistorySetCorrection(
        expected: expected,
        actualReps: 5,
      );
      await expectLater(
        repository.correctSession(
          sessionId: 'session',
          corrections: [correction, correction],
        ),
        throwsA(WorkoutHistoryCorrectionFailure.invalid),
      );
      expect(
        (await repository.getSessionDetail(
          'session',
        ))!.exercises.single.sets.first.actualReps,
        8,
      );
    },
  );

  test(
    'rejects active sessions, foreign set ids and stale correction snapshots',
    () async {
      await _HistoryFixture.seed(db);
      await _HistoryFixture.seed(db, id: 'active', status: 'in_progress');
      await _HistoryFixture.seed(db, id: 'other');
      final expected = (await repository.getSessionDetail(
        'session',
      ))!.exercises.single.sets.first;
      final correction = WorkoutHistorySetCorrection(
        expected: expected,
        actualReps: 6,
        actualWeightKg: 100,
      );
      for (final id in ['active', 'missing', 'other']) {
        await expectLater(
          repository.correctSession(sessionId: id, corrections: [correction]),
          throwsA(WorkoutHistoryCorrectionFailure.missing),
        );
      }
      expect(await repository.getSessionDetail('active'), isNull);
      await repository.correctSession(
        sessionId: 'session',
        corrections: [correction],
      );
      await expectLater(
        repository.correctSession(
          sessionId: 'session',
          corrections: [correction],
        ),
        throwsA(WorkoutHistoryCorrectionFailure.conflict),
      );
    },
  );

  test(
    'partial exercise corrections permit only completed logged sets using persisted status',
    () async {
      for (final skipped in [false, true]) {
        final id = skipped ? 'skipped-exercise' : 'partial-exercise';
        await _HistoryFixture.seed(db, id: id, sets: 2);
        await (db.update(
          db.setLogs,
        )..where((table) => table.id.equals('$id-set-1'))).write(
          SetLogsCompanion(
            completed: const Value(false),
            skipped: Value(skipped),
          ),
        );
        final detail = (await repository.getSessionDetail(id))!;
        expect(detail.exercises.single.canCorrectLogs, isTrue);
        final logged = detail.exercises.single.sets.first;
        await repository.correctSession(
          sessionId: id,
          corrections: [
            WorkoutHistorySetCorrection(
              expected: logged,
              actualReps: 10,
              actualWeightKg: 100,
            ),
          ],
        );
        final corrected = (await repository.getSessionDetail(
          id,
        ))!.exercises.single.sets.first;
        expect(corrected.actualReps, 10);
        final unfinished = detail.exercises.single.sets[1];
        final correction = WorkoutHistorySetCorrection(
          expected: unfinished,
          actualReps: 10,
          actualWeightKg: 100,
        );
        expect(correction.isValid, isFalse);
        await expectLater(
          repository.correctSession(sessionId: id, corrections: [correction]),
          throwsA(WorkoutHistoryCorrectionFailure.invalid),
        );
      }
    },
  );

  test(
    'database failure on the second update rolls back the entire correction',
    () async {
      await _HistoryFixture.seed(db, sets: 2);
      final before = (await repository.getSessionDetail('session'))!;
      await db.customStatement('''
      CREATE TRIGGER reject_second_correction BEFORE UPDATE ON set_logs
      WHEN NEW.id = 'session-set-1'
      BEGIN SELECT RAISE(ABORT, 'injected correction failure'); END
    ''');
      await expectLater(
        repository.correctSession(
          sessionId: 'session',
          corrections: [
            for (final item in before.exercises.single.sets)
              WorkoutHistorySetCorrection(
                expected: item,
                actualReps: 3,
                actualWeightKg: 100,
              ),
          ],
        ),
        throwsA(anything),
      );
      final after = (await repository.getSessionDetail('session'))!;
      expect(after.exercises.single.sets.map((s) => s.actualReps), [8, 8]);
      expect(
        after.exercises.single.sets.map((s) => s.updatedAt),
        before.exercises.single.sets.map((s) => s.updatedAt),
      );
    },
  );

  test(
    'corrections enforce the persisted logging mode and legacy required results',
    () async {
      await _HistoryFixture.seed(db);
      final strength = (await repository.getSessionDetail(
        'session',
      ))!.exercises.single.sets.single;
      expect(strength.loggingType, ExerciseLoggingType.repsWeight);
      for (final correction in [
        WorkoutHistorySetCorrection(expected: strength, actualReps: 8),
        WorkoutHistorySetCorrection(expected: strength, actualWeightKg: 100),
        WorkoutHistorySetCorrection(
          expected: strength,
          actualDurationSeconds: 60,
        ),
      ]) {
        await expectLater(
          repository.correctSession(
            sessionId: 'session',
            corrections: [correction],
          ),
          throwsA(WorkoutHistoryCorrectionFailure.invalid),
        );
      }
      final forgedMode = WorkoutHistorySetItem(
        id: strength.id,
        setIndex: strength.setIndex,
        setType: strength.setType,
        completed: true,
        skipped: false,
        actualReps: strength.actualReps,
        actualWeightKg: strength.actualWeightKg,
        updatedAt: strength.updatedAt,
        exerciseId: strength.exerciseId,
        loggingType: ExerciseLoggingType.repsOnly,
      );
      await expectLater(
        repository.correctSession(
          sessionId: 'session',
          corrections: [
            WorkoutHistorySetCorrection(expected: forgedMode, actualReps: 9),
          ],
        ),
        throwsA(WorkoutHistoryCorrectionFailure.invalid),
      );
      await _HistoryFixture.seed(db, id: 'timed', loggingType: 'duration');
      await (db.update(
        db.setLogs,
      )..where((t) => t.id.equals('timed-set-0'))).write(
        const SetLogsCompanion(
          actualReps: Value(null),
          actualWeightKg: Value(null),
          actualDurationSeconds: Value(60),
          prescribedDurationSeconds: Value(null),
        ),
      );
      final timed = (await repository.getSessionDetail(
        'timed',
      ))!.exercises.single.sets.single;
      await expectLater(
        repository.correctSession(
          sessionId: 'timed',
          corrections: [
            WorkoutHistorySetCorrection(
              expected: timed,
              actualDistanceMeters: 250,
            ),
          ],
        ),
        throwsA(WorkoutHistoryCorrectionFailure.invalid),
      );
      await repository.correctSession(
        sessionId: 'timed',
        corrections: [
          WorkoutHistorySetCorrection(
            expected: timed,
            actualDurationSeconds: 65,
          ),
        ],
      );

      await _HistoryFixture.seed(db, id: 'legacy-distance', loggingType: null);
      await (db.update(
        db.setLogs,
      )..where((t) => t.id.equals('legacy-distance-set-0'))).write(
        const SetLogsCompanion(
          prescribedDurationSeconds: Value(null),
          actualReps: Value(null),
          actualWeightKg: Value(null),
          actualDistanceMeters: Value(200),
        ),
      );
      final legacy = (await repository.getSessionDetail(
        'legacy-distance',
      ))!.exercises.single.sets.single;
      expect(legacy.loggingType, isNull);
      await repository.correctSession(
        sessionId: 'legacy-distance',
        corrections: [
          WorkoutHistorySetCorrection(
            expected: legacy,
            actualDistanceMeters: 275,
          ),
        ],
      );
      expect(
        (await repository.getSessionDetail(
          'legacy-distance',
        ))!.exercises.single.sets.single.actualDistanceMeters,
        275,
      );
    },
  );

  test(
    'pre-swap sets remain with their exercise and use their original legacy logging rules',
    () async {
      await _HistoryFixture.seed(db);
      await (db.update(
        db.setLogs,
      )..where((t) => t.id.equals('session-set-0'))).write(
        const SetLogsCompanion(
          prescribedDurationSeconds: Value(null),
          prescribedDistanceMeters: Value(null),
        ),
      );
      await (db.update(
        db.workoutSessionExercises,
      )..where((t) => t.id.equals('session-exercise'))).write(
        const WorkoutSessionExercisesCompanion(
          exerciseId: Value(12),
          exerciseNameSnapshot: Value('Replacement timed exercise'),
          loggingType: Value('duration'),
        ),
      );
      await db
          .into(db.setLogs)
          .insert(
            SetLogsCompanion.insert(
              id: 'replacement-set',
              workoutSessionExerciseId: 'session-exercise',
              exerciseId: 12,
              performedAt: _HistoryFixture.at,
              setIndex: 1,
              prescribedDurationSeconds: const Value(60),
              actualDurationSeconds: const Value(60),
              completed: const Value(true),
              createdAt: _HistoryFixture.at,
              updatedAt: _HistoryFixture.at,
            ),
          );
      final originalHistory = await repository.listExerciseHistory(7);
      final replacementHistory = await repository.listExerciseHistory(12);
      expect(originalHistory.single.exercises.single.exerciseId, 7);
      expect(
        originalHistory.single.exercises.single.exerciseName,
        WorkoutHistoryStrings.exerciseReference(7),
      );
      expect(originalHistory.single.exercises.single.sets.single.exerciseId, 7);
      expect(
        replacementHistory.single.exercises.single.exerciseName,
        'Replacement timed exercise',
      );
      expect(
        replacementHistory.single.exercises.single.sets.single.id,
        'replacement-set',
      );
      final originalSet = originalHistory.single.exercises.single.sets.single;
      expect(originalSet.loggingType, isNull);
      await expectLater(
        repository.correctSession(
          sessionId: 'session',
          corrections: [
            WorkoutHistorySetCorrection(
              expected: originalSet,
              actualDurationSeconds: 70,
            ),
          ],
        ),
        throwsA(WorkoutHistoryCorrectionFailure.invalid),
      );
      await repository.correctSession(
        sessionId: 'session',
        corrections: [
          WorkoutHistorySetCorrection(
            expected: originalSet,
            actualReps: 9,
            actualWeightKg: 100,
          ),
        ],
      );
      expect(
        (await repository.listExerciseHistory(
          7,
        )).single.exercises.single.sets.single.actualReps,
        9,
      );
      expect(
        (await repository.listExerciseHistory(
          12,
        )).single.exercises.single.sets.single.actualDurationSeconds,
        60,
      );
      final detail = (await repository.getSessionDetail('session'))!;
      expect(detail.exercises.map((item) => item.exerciseId), [7, 12]);
    },
  );

  test(
    'exercise history retains partial exercise logs and excludes pending skipped and empty sets',
    () async {
      await _HistoryFixture.seed(db, id: 'finished', sets: 3);
      await (db.update(db.setLogs)..where((t) => t.id.equals('finished-set-1')))
          .write(const SetLogsCompanion(skipped: Value(true)));
      await (db.update(
        db.setLogs,
      )..where((t) => t.id.equals('finished-set-2'))).write(
        const SetLogsCompanion(
          actualReps: Value(null),
          actualWeightKg: Value(null),
        ),
      );
      await _HistoryFixture.seed(db, id: 'unfinished', sets: 2);
      await (db.update(db.setLogs)
            ..where((t) => t.id.equals('unfinished-set-1')))
          .write(const SetLogsCompanion(completed: Value(false)));
      await _HistoryFixture.seed(db, id: 'empty');
      await (db.update(
        db.setLogs,
      )..where((t) => t.id.equals('empty-set-0'))).write(
        const SetLogsCompanion(
          actualReps: Value(null),
          actualWeightKg: Value(null),
        ),
      );
      final history = await repository.listExerciseHistory(7);
      expect(
        history.map((item) => item.sessionId),
        unorderedEquals(['finished', 'unfinished']),
      );
      expect(
        history
            .singleWhere((item) => item.sessionId == 'unfinished')
            .exercises
            .single
            .sets
            .map((set) => set.id),
        ['unfinished-set-0'],
      );
      expect(
        history
            .singleWhere((item) => item.sessionId == 'finished')
            .exercises
            .single
            .sets
            .map((set) => set.id),
        ['finished-set-0'],
      );
      // Full session history still records the original outcome of every set.
      expect(
        (await repository.getSessionDetail(
          'unfinished',
        ))!.exercises.single.sets,
        hasLength(2),
      );
      expect(
        (await repository.getSessionDetail('finished'))!.exercises.single.sets,
        hasLength(3),
      );
    },
  );

  test(
    'exercise history filters statuses and exercise ids and orders newest first',
    () async {
      await _HistoryFixture.seed(db, id: 'old');
      await _HistoryFixture.seed(
        db,
        id: 'new',
        at: _HistoryFixture.at.add(const Duration(days: 1)),
      );
      await _HistoryFixture.seed(db, id: 'active', status: 'in_progress');
      await _HistoryFixture.seed(db, id: 'abandoned', status: 'abandoned');
      await _HistoryFixture.seed(db, id: 'deleted', status: 'deleted');
      await _HistoryFixture.seed(db, id: 'different', exerciseId: 12);
      final history = await repository.listExerciseHistory(7);
      expect(history.map((s) => s.sessionId), ['new', 'old']);
      expect(
        history.first.exercises.single.exerciseName,
        'Original exercise snapshot',
      );
      expect(history.first.exercises.single.sets.first.actualReps, 8);
      expect((await repository.listExerciseHistory(999)), isEmpty);
      expect((await repository.listCompletedSessions()).first.exerciseCount, 1);
    },
  );
}

class _HistoryFixture {
  _HistoryFixture._();

  static final at = DateTime(2026, 10, 24, 8);

  static Future<void> seed(
    AppDatabase db, {
    String id = 'session',
    String status = 'completed',
    int exerciseId = 7,
    int sets = 1,
    DateTime? at,
    String? loggingType = 'repsWeight',
  }) async {
    final date = at ?? _HistoryFixture.at;
    await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: id,
            source: 'standalone',
            name: 'Snapshot workout',
            startedAt: date,
            completedAt: Value(
              status == 'completed' ? date.add(const Duration(hours: 1)) : null,
            ),
            status: status,
            createdAt: date,
            updatedAt: date,
          ),
        );
    await db
        .into(db.workoutSessionExercises)
        .insert(
          WorkoutSessionExercisesCompanion.insert(
            id: '$id-exercise',
            workoutSessionId: id,
            exerciseId: exerciseId,
            exerciseNameSnapshot: 'Original exercise snapshot',
            loggingType: Value(loggingType),
            sortOrder: 0,
            supersetGroupId: const Value('original-group'),
          ),
        );
    for (var index = 0; index < sets; index++) {
      await db
          .into(db.setLogs)
          .insert(
            SetLogsCompanion.insert(
              id: '$id-set-$index',
              workoutSessionExerciseId: '$id-exercise',
              exerciseId: exerciseId,
              performedAt: date,
              setIndex: index,
              prescribedRepsExact: const Value(8),
              prescribedDurationSeconds: const Value(45),
              prescribedDistanceMeters: const Value(200),
              prescribedRir: const Value(3),
              actualReps: const Value(8),
              actualWeightKg: const Value(100),
              completed: const Value(true),
              isPr: const Value(true),
              estimated1rmKg: const Value(126),
              createdAt: date,
              updatedAt: date,
            ),
          );
    }
  }
}
