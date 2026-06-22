import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_audio_cache_dao.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseAudioCacheDao', () {
    late AppDatabase db;
    late ExerciseAudioCacheDao dao;
    late ExerciseDao exerciseDao;

    Future<void> seedExercise(int id) async {
      await exerciseDao.insertExercisesBulk([
        ExercisesCompanion(
          id: Value(id),
          name: Value('Test Exercise $id'),
          nameNormalized: Value('test exercise $id'),
          source: const Value('musclewiki'),
          primaryMusclesJson: const Value('["Test"]'),
          muscleGroupsJson: const Value('["Test"]'),
          modality: const Value('strength'),
          equipment: const Value('barbell'),
          gripsJson: const Value('["none"]'),
          stepsJson: const Value('["Step 1"]'),
          isCustom: const Value(false),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      ]);
    }

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      dao = ExerciseAudioCacheDao(db);
      exerciseDao = ExerciseDao(db);

      await seedExercise(1);
      await seedExercise(2);
    });

    tearDown(() {
      db.close();
    });

    String cacheId(int exerciseId, int stepIndex, String textHash) =>
        '$exerciseId:$stepIndex:$textHash';

    ExerciseAudioCacheCompanion makeEntry({
      required int exerciseId,
      required int stepIndex,
      required String textHash,
      String relativePath = 'audio-cache/exercise_steps/1/0-hash.wav',
    }) {
      return ExerciseAudioCacheCompanion(
        id: Value(cacheId(exerciseId, stepIndex, textHash)),
        exerciseId: Value(exerciseId),
        stepIndex: Value(stepIndex),
        textHash: Value(textHash),
        localRelativePath: Value(relativePath),
        generatedAt: Value(DateTime.now()),
      );
    }

    test('upserts cache entry', () async {
      await dao.upsertCacheEntry(
        makeEntry(exerciseId: 1, stepIndex: 0, textHash: 'abc'),
      );

      final all = await db.select(db.exerciseAudioCache).get();
      expect(all.length, 1);
      expect(all.first.exerciseId, 1);
      expect(all.first.stepIndex, 0);
      expect(all.first.textHash, 'abc');
    });

    test('reads cache by exercise and step', () async {
      await dao.upsertCacheEntry(
        makeEntry(exerciseId: 1, stepIndex: 0, textHash: 'abc'),
      );
      await dao.upsertCacheEntry(
        makeEntry(exerciseId: 1, stepIndex: 1, textHash: 'def'),
      );

      final result = await dao.getByExerciseAndStep(
        exerciseId: 1,
        stepIndex: 0,
        textHash: 'abc',
      );

      expect(result, isNotNull);
      expect(result!.stepIndex, 0);
      expect(result.textHash, 'abc');

      final notFound = await dao.getByExerciseAndStep(
        exerciseId: 1,
        stepIndex: 0,
        textHash: 'wrong',
      );
      expect(notFound, isNull);
    });

    test('updates last accessed timestamp', () async {
      await dao.upsertCacheEntry(
        makeEntry(exerciseId: 1, stepIndex: 0, textHash: 'abc'),
      );

      final later = DateTime.now().add(const Duration(hours: 1));
      await dao.updateLastAccessed(
        id: cacheId(1, 0, 'abc'),
        lastAccessedAt: later,
      );

      final entry = await dao.getByExerciseAndStep(
        exerciseId: 1,
        stepIndex: 0,
        textHash: 'abc',
      );
      expect(entry!.lastAccessedAt, isNotNull);
    });

    test('deletes by exercise id', () async {
      await dao.upsertCacheEntry(
        makeEntry(exerciseId: 1, stepIndex: 0, textHash: 'abc'),
      );
      await dao.upsertCacheEntry(
        makeEntry(exerciseId: 2, stepIndex: 0, textHash: 'def'),
      );

      await dao.deleteByExerciseId(1);

      final remaining = await db.select(db.exerciseAudioCache).get();
      expect(remaining.length, 1);
      expect(remaining.first.exerciseId, 2);
    });

    test('deletes by relative path', () async {
      await dao.upsertCacheEntry(
        makeEntry(
          exerciseId: 1,
          stepIndex: 0,
          textHash: 'abc',
          relativePath: 'audio-cache/exercise_steps/1/step0.wav',
        ),
      );
      await dao.upsertCacheEntry(
        makeEntry(
          exerciseId: 1,
          stepIndex: 1,
          textHash: 'def',
          relativePath: 'audio-cache/exercise_steps/1/step1.wav',
        ),
      );

      await dao.deleteByRelativePath('audio-cache/exercise_steps/1/step0.wav');

      final remaining = await db.select(db.exerciseAudioCache).get();
      expect(remaining.length, 1);
      expect(remaining.first.stepIndex, 1);
    });
  });
}
