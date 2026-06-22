import 'dart:convert';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/exercise_video_dao.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftExerciseRepository', () {
    late AppDatabase db;
    late ExerciseDao exerciseDao;
    late DriftExerciseRepository repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      exerciseDao = ExerciseDao(db);
      repository = DriftExerciseRepository(database: db);

      final now = DateTime.now();
      await exerciseDao.insertExercisesBulk([
        ExercisesCompanion(
          id: const Value(1),
          name: const Value('Bench Press'),
          nameNormalized: const Value('bench press'),
          source: const Value('musclewiki'),
          primaryMusclesJson: Value(
            json.encode(['Pectoralis Major', 'Triceps']),
          ),
          muscleGroupsJson: Value(json.encode(['Chest', 'Triceps'])),
          modality: const Value('strength'),
          equipment: const Value('barbell'),
          difficulty: const Value('intermediate'),
          force: const Value('push'),
          mechanic: const Value('compound'),
          gripsJson: Value(json.encode(['barbell'])),
          stepsJson: Value(json.encode(['Step 1', 'Step 2'])),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        ExercisesCompanion(
          id: const Value(2),
          name: const Value('Squat'),
          nameNormalized: const Value('squat'),
          source: const Value('musclewiki'),
          primaryMusclesJson: Value(json.encode(['Quadriceps', 'Glutes'])),
          muscleGroupsJson: Value(json.encode(['Quadriceps', 'Glutes'])),
          modality: const Value('strength'),
          equipment: const Value('barbell'),
          difficulty: const Value('beginner'),
          force: const Value('push'),
          mechanic: const Value('compound'),
          gripsJson: Value(json.encode(['barbell'])),
          stepsJson: Value(json.encode(['Step 1', 'Step 2', 'Step 3'])),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        ExercisesCompanion(
          id: const Value(3),
          name: const Value('Bicep Curl'),
          nameNormalized: const Value('bicep curl'),
          source: const Value('musclewiki'),
          primaryMusclesJson: Value(json.encode(['Biceps'])),
          muscleGroupsJson: Value(json.encode(['Biceps'])),
          modality: const Value('hypertrophy'),
          equipment: const Value('dumbbell'),
          difficulty: const Value('beginner'),
          force: const Value('pull'),
          mechanic: const Value('isolation'),
          gripsJson: Value(json.encode(['dumbbell'])),
          stepsJson: Value(json.encode(['Step 1'])),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        ExercisesCompanion(
          id: const Value(4),
          name: const Value('Push Up'),
          nameNormalized: const Value('push up'),
          source: const Value('musclewiki'),
          primaryMusclesJson: Value(json.encode(['Pectoralis Major'])),
          muscleGroupsJson: Value(json.encode(['Chest', 'Triceps'])),
          modality: const Value('strength'),
          equipment: const Value('bodyweight'),
          difficulty: const Value('beginner'),
          force: const Value('push'),
          mechanic: const Value('compound'),
          gripsJson: Value(json.encode(['none'])),
          stepsJson: Value(json.encode(['Step 1', 'Step 2', 'Step 3'])),
          isFavorite: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);
    });

    tearDown(() {
      db.close();
    });

    test('searches by name', () async {
      final results = await repository.searchExercises(
        const ExerciseFilterState(searchQuery: 'bench'),
      );
      expect(results.length, 1);
      expect(results.first.name, 'Bench Press');
    });

    test('filters by muscle group', () async {
      final results = await repository.searchExercises(
        const ExerciseFilterState(muscleGroup: 'Chest'),
      );
      expect(results.length, 2);
      expect(
        results.map((e) => e.name),
        containsAll(['Bench Press', 'Push Up']),
      );
    });

    test('filters by equipment', () async {
      final results = await repository.searchExercises(
        const ExerciseFilterState(equipment: 'barbell'),
      );
      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(['Bench Press', 'Squat']));
    });

    test('filters by difficulty', () async {
      final results = await repository.searchExercises(
        const ExerciseFilterState(difficulty: 'beginner'),
      );
      expect(results.length, 3);
    });

    test('filters by modality', () async {
      final results = await repository.searchExercises(
        const ExerciseFilterState(modality: 'hypertrophy'),
      );
      expect(results.length, 1);
      expect(results.first.name, 'Bicep Curl');
    });

    test('filters favorites only', () async {
      final results = await repository.searchExercises(
        const ExerciseFilterState(favoritesOnly: true),
      );
      expect(results.length, 1);
      expect(results.first.name, 'Push Up');
    });

    test('combined filters produce expected results', () async {
      final results = await repository.searchExercises(
        const ExerciseFilterState(searchQuery: 'bench', equipment: 'barbell'),
      );
      expect(results.length, 1);
      expect(results.first.name, 'Bench Press');
    });

    test('maps exercise detail including videos and steps', () async {
      final videoDao = ExerciseVideoDao(db);
      await videoDao.insertVideosBulk([
        ExerciseVideosCompanion(
          id: const Value('v1'),
          exerciseId: const Value(1),
          url: const Value('https://example.com/bench.mp4'),
          angle: const Value('front'),
          gender: const Value('male'),
          sortOrder: const Value(0),
          createdAt: Value(DateTime.now()),
        ),
      ]);

      final detail = await repository.getExerciseDetail(1);
      expect(detail, isNotNull);
      expect(detail!.name, 'Bench Press');
      expect(detail.primaryMuscles, contains('Pectoralis Major'));
      expect(detail.videos.length, 1);
      expect(detail.videos.first.angle, 'front');
      expect(detail.steps.length, 2);
    });

    test('returns null for missing exercise', () async {
      final detail = await repository.getExerciseDetail(999);
      expect(detail, isNull);
    });

    test('setFavorite and setSubstitutedOut', () async {
      await repository.setFavorite(exerciseId: 1, isFavorite: true);
      await repository.setSubstitutedOut(exerciseId: 1, isSubstitutedOut: true);

      final detail = await repository.getExerciseDetail(1);
      expect(detail!.isFavorite, isTrue);
      expect(detail.isSubstitutedOut, isTrue);
    });
  });
}
