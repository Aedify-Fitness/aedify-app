import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/exercise_video_dao.dart';
import 'package:aedify/core/db/daos/library_meta_dao.dart';
import 'package:aedify/core/db/enums/library_sync_status.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_exercise.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_manifest.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_video.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_library_importer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseLibraryImporter', () {
    late AppDatabase db;
    late ExerciseDao exerciseDao;
    late ExerciseVideoDao exerciseVideoDao;
    late LibraryMetaDao libraryMetaDao;
    late ExerciseLibraryImporter importer;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      exerciseDao = ExerciseDao(db);
      exerciseVideoDao = ExerciseVideoDao(db);
      libraryMetaDao = LibraryMetaDao(db);
      importer = ExerciseLibraryImporter(
        database: db,
        exerciseDao: exerciseDao,
        exerciseVideoDao: exerciseVideoDao,
        libraryMetaDao: libraryMetaDao,
      );
    });

    tearDown(() {
      db.close();
    });

    ExerciseDataset sampleDataset({int count = 1, int schemaVersion = 1}) {
      final now = DateTime.now();
      return ExerciseDataset(
        schemaVersion: schemaVersion,
        generatedAt: now,
        source: 'musclewiki',
        exerciseCount: count,
        exercises: List.generate(
          count,
          (i) => ExerciseDatasetExercise(
            id: i + 1,
            name: 'Exercise ${i + 1}',
            difficulty: 'intermediate',
            primaryMuscles: ['Chest'],
            muscleGroups: ['Chest', 'Triceps'],
            category: 'compound',
            modality: 'strength',
            equipment: 'barbell',
            force: 'push',
            mechanic: 'compound',
            grips: ['barbell'],
            steps: ['Step 1', 'Step 2'],
            videos: [
              ExerciseDatasetVideo(
                url: Uri.parse('https://example.com/video_${i + 1}.mp4'),
                angle: 'front',
                gender: 'male',
                ogImage: 'https://example.com/thumb_${i + 1}.jpg',
              ),
            ],
          ),
        ),
      );
    }

    ExerciseDatasetManifest sampleManifest({
      int schemaVersion = 1,
      String datasetVersion = '2024-01-01',
    }) {
      return ExerciseDatasetManifest(
        schemaVersion: schemaVersion,
        manifestVersion: 1,
        datasetVersion: datasetVersion,
        generatedAt: DateTime.now(),
        source: 'musclewiki',
        exerciseCount: 1,
        active: ExerciseDatasetActiveFile(
          path: 'datasets/exercises/v1/exercises.json',
          contentType: 'application/json',
          sizeBytes: 50000,
          sha256: 'abc123',
          schemaVersion: schemaVersion,
          minimumSupportedAppSchemaVersion: 1,
        ),
        history: [],
      );
    }

    test('imports exercises and videos', () async {
      final result = await importer.importDataset(
        dataset: sampleDataset(count: 2),
        manifest: sampleManifest(),
        downloadedAt: DateTime.now(),
      );

      expect(result.importedExerciseCount, 2);
      expect(result.importedVideoCount, 2);
      expect(result.libraryVersion, '2024-01-01');

      final allExercises = await exerciseDao.getAllExercises();
      expect(allExercises.length, 2);
      expect(allExercises[0].name, 'Exercise 1');

      final videos = await db.select(db.exerciseVideos).get();
      expect(videos.length, 2);
    });

    test('writes library_meta', () async {
      final downloadedAt = DateTime.now();
      await importer.importDataset(
        dataset: sampleDataset(),
        manifest: sampleManifest(),
        downloadedAt: downloadedAt,
      );

      final meta = await libraryMetaDao.getLibraryMeta();
      expect(meta, isNotNull);
      expect(meta!.source, 'musclewiki');
      expect(meta.schemaVersion, 1);
      expect(meta.exerciseCount, 1);
      expect(meta.syncStatus, LibrarySyncStatus.synced.value);
    });

    test('preserves favorites/substitutions/notes on matching IDs', () async {
      await importer.importDataset(
        dataset: sampleDataset(count: 2),
        manifest: sampleManifest(),
        downloadedAt: DateTime.now(),
      );

      await (db.update(db.exercises)..where((t) => t.id.equals(1))).write(
        const ExercisesCompanion(
          isFavorite: Value(true),
          isSubstitutedOut: Value(true),
          userNotes: Value('My note'),
        ),
      );

      await importer.importDataset(
        dataset: sampleDataset(count: 2),
        manifest: sampleManifest(datasetVersion: '2024-06-01'),
        downloadedAt: DateTime.now(),
      );

      final ex1 = await exerciseDao.getExerciseById(1);
      expect(ex1, isNotNull);
      expect(ex1!.isFavorite, isTrue);
      expect(ex1.isSubstitutedOut, isTrue);
      expect(ex1.userNotes, 'My note');
    });

    test('does not delete custom exercises', () async {
      await importer.importDataset(
        dataset: sampleDataset(count: 2),
        manifest: sampleManifest(),
        downloadedAt: DateTime.now(),
      );

      const customId = 9999;
      final now = DateTime.now();
      await exerciseDao.insertExercisesBulk([
        ExercisesCompanion(
          id: Value(customId),
          isCustom: const Value(true),
          source: const Value('user'),
          name: const Value('Custom Exercise'),
          nameNormalized: const Value('custom exercise'),
          primaryMusclesJson: const Value('["Chest"]'),
          muscleGroupsJson: const Value('["Chest"]'),
          modality: const Value('strength'),
          equipment: const Value('dumbbell'),
          gripsJson: const Value('[]'),
          stepsJson: const Value('["Do it"]'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);

      await importer.importDataset(
        dataset: sampleDataset(count: 1),
        manifest: sampleManifest(datasetVersion: '2024-06-01'),
        downloadedAt: DateTime.now(),
      );

      final custom = await exerciseDao.getExerciseById(customId);
      expect(custom, isNotNull);
      expect(custom!.isCustom, isTrue);

      final all = await exerciseDao.getAllExercises();
      expect(all.length, 2);
    });

    test('returns expected counts and version', () async {
      final result = await importer.importDataset(
        dataset: sampleDataset(count: 3),
        manifest: sampleManifest(datasetVersion: '2024-06-01'),
        downloadedAt: DateTime.now(),
      );

      expect(result.importedExerciseCount, 3);
      expect(result.importedVideoCount, 3);
      expect(result.libraryVersion, '2024-06-01');
    });
  });
}
