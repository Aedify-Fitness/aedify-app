import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/set_log_dao.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/core/db/daos/workout_session_exercise_dao.dart';
import 'package:aedify/features/lift_log/data/drift_workout_history_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late WorkoutSessionDao sessionDao;
  late WorkoutSessionExerciseDao exerciseDao;
  late SetLogDao setLogDao;
  late DriftWorkoutHistoryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sessionDao = WorkoutSessionDao(db);
    exerciseDao = WorkoutSessionExerciseDao(db);
    setLogDao = SetLogDao(db);
    repository = DriftWorkoutHistoryRepository(
      workoutSessionDao: sessionDao,
      workoutSessionExerciseDao: exerciseDao,
      setLogDao: setLogDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('listCompletedSessions', () {
    test('returns empty list when no completed sessions', () async {
      final items = await repository.listCompletedSessions();
      expect(items, isEmpty);
    });

    test('returns completed sessions ordered newest first', () async {
      final uuid = const Uuid();
      final now = DateTime.now();

      await sessionDao.upsertSession(
        WorkoutSessionsCompanion.insert(
          id: uuid.v4(),
          source: 'standalone',
          name: 'Session 1',
          startedAt: now.subtract(const Duration(hours: 2)),
          completedAt: Value(now.subtract(const Duration(hours: 1))),
          durationSeconds: Value(3600),
          status: 'completed',
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
      );

      await sessionDao.upsertSession(
        WorkoutSessionsCompanion.insert(
          id: uuid.v4(),
          source: 'standalone',
          name: 'Session 2',
          startedAt: now.subtract(const Duration(hours: 4)),
          completedAt: Value(now.subtract(const Duration(hours: 3))),
          durationSeconds: Value(1800),
          status: 'completed',
          createdAt: now.subtract(const Duration(hours: 4)),
          updatedAt: now.subtract(const Duration(hours: 3)),
        ),
      );

      final items = await repository.listCompletedSessions();
      expect(items.length, equals(2));
      expect(items[0].name, equals('Session 1'));
      expect(items[1].name, equals('Session 2'));
    });

    test('excludes in-progress sessions', () async {
      final uuid = const Uuid();
      final now = DateTime.now();

      await sessionDao.upsertSession(
        WorkoutSessionsCompanion.insert(
          id: uuid.v4(),
          source: 'standalone',
          name: 'In Progress',
          startedAt: now,
          status: 'in_progress',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final items = await repository.listCompletedSessions();
      expect(items, isEmpty);
    });
  });

  group('getSessionDetail', () {
    test('returns null for missing session', () async {
      final detail = await repository.getSessionDetail('nonexistent');
      expect(detail, isNull);
    });

    test('builds detail from session/exercise/set rows', () async {
      final uuid = const Uuid();
      final sessionId = uuid.v4();
      final exerciseId = uuid.v4();
      final now = DateTime.now();

      await sessionDao.upsertSession(
        WorkoutSessionsCompanion.insert(
          id: sessionId,
          source: 'standalone',
          name: 'Test Workout',
          startedAt: now.subtract(const Duration(hours: 2)),
          completedAt: Value(now.subtract(const Duration(hours: 1))),
          durationSeconds: Value(3600),
          status: 'completed',
          notes: Value('Great session'),
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
      );

      await exerciseDao.upsertSessionExercise(
        WorkoutSessionExercisesCompanion.insert(
          id: exerciseId,
          workoutSessionId: sessionId,
          exerciseId: 1,
          exerciseNameSnapshot: 'Bench Press',
          sortOrder: 0,
        ),
      );

      await setLogDao.upsertSetLog(
        SetLogsCompanion.insert(
          id: uuid.v4(),
          workoutSessionExerciseId: exerciseId,
          exerciseId: 1,
          performedAt: now,
          setIndex: 0,
          setType: Value('working'),
          completed: Value(true),
          skipped: Value(false),
          actualReps: Value(10),
          actualWeightKg: Value(100.0),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final detail = await repository.getSessionDetail(sessionId);
      expect(detail, isNotNull);
      expect(detail!.name, equals('Test Workout'));
      expect(detail.notes, equals('Great session'));
      expect(detail.exercises.length, equals(1));
      expect(detail.exercises[0].exerciseName, equals('Bench Press'));
      expect(detail.exercises[0].sets.length, equals(1));
      expect(detail.exercises[0].sets[0].actualReps, equals(10));
      expect(detail.exercises[0].sets[0].actualWeightKg, equals(100.0));
    });

    test('preserves superset group context in detail', () async {
      final uuid = const Uuid();
      final sessionId = uuid.v4();
      final exerciseId1 = uuid.v4();
      final exerciseId2 = uuid.v4();
      final now = DateTime.now();

      await sessionDao.upsertSession(
        WorkoutSessionsCompanion.insert(
          id: sessionId,
          source: 'standalone',
          name: 'Superset Workout',
          startedAt: now.subtract(const Duration(hours: 2)),
          completedAt: Value(now.subtract(const Duration(hours: 1))),
          durationSeconds: Value(3600),
          status: 'completed',
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
      );

      await exerciseDao.upsertSessionExercise(
        WorkoutSessionExercisesCompanion.insert(
          id: exerciseId1,
          workoutSessionId: sessionId,
          exerciseId: 1,
          exerciseNameSnapshot: 'Bench Press',
          sortOrder: 0,
          supersetGroupId: Value('g1'),
        ),
      );

      await exerciseDao.upsertSessionExercise(
        WorkoutSessionExercisesCompanion.insert(
          id: exerciseId2,
          workoutSessionId: sessionId,
          exerciseId: 2,
          exerciseNameSnapshot: 'Fly',
          sortOrder: 1,
          supersetGroupId: Value('g1'),
        ),
      );

      await setLogDao.upsertSetLog(
        SetLogsCompanion.insert(
          id: uuid.v4(),
          workoutSessionExerciseId: exerciseId1,
          exerciseId: 1,
          performedAt: now,
          setIndex: 0,
          setType: Value('working'),
          completed: Value(true),
          skipped: Value(false),
          actualReps: Value(10),
          actualWeightKg: Value(100.0),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await setLogDao.upsertSetLog(
        SetLogsCompanion.insert(
          id: uuid.v4(),
          workoutSessionExerciseId: exerciseId2,
          exerciseId: 2,
          performedAt: now,
          setIndex: 0,
          setType: Value('working'),
          completed: Value(true),
          skipped: Value(false),
          actualReps: Value(12),
          actualWeightKg: Value(30.0),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final detail = await repository.getSessionDetail(sessionId);
      expect(detail, isNotNull);
      expect(detail!.exercises.length, equals(2));
      expect(detail.exercises[0].supersetGroupId, equals('g1'));
      expect(detail.exercises[1].supersetGroupId, equals('g1'));
      expect(detail.exercises[0].exerciseName, equals('Bench Press'));
      expect(detail.exercises[1].exerciseName, equals('Fly'));
    });
  });
}
