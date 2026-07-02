import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/exercise_video_dao.dart';
import 'package:aedify/core/db/daos/library_meta_dao.dart';
import 'package:aedify/core/db/enums/library_sync_status.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_exercise.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_manifest.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_library_import_failure.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_library_import_result.dart';
import 'package:aedify/shared/constants/db_constants.dart';
import 'package:uuid/uuid.dart';

class ExerciseLibraryImporter {
  static final _logger = AppLogger(name: 'ExerciseLibraryImporter');

  ExerciseLibraryImporter({
    required AppDatabase database,
    required ExerciseDao exerciseDao,
    required ExerciseVideoDao exerciseVideoDao,
    required LibraryMetaDao libraryMetaDao,
  }) : _database = database,
       _exerciseDao = exerciseDao,
       _exerciseVideoDao = exerciseVideoDao,
       _libraryMetaDao = libraryMetaDao;

  final AppDatabase _database;
  final ExerciseDao _exerciseDao;
  final ExerciseVideoDao _exerciseVideoDao;
  final LibraryMetaDao _libraryMetaDao;

  Future<ExerciseLibraryImportResult> importDataset({
    required ExerciseDataset dataset,
    required ExerciseDatasetManifest manifest,
    required DateTime downloadedAt,
  }) async {
    _logger.info(
      'importDataset — start',
      metadata: {'exerciseCount': dataset.exercises.length},
    );
    try {
      return await _database.inTransaction(() async {
        final preservedState = await _preserveUserState(dataset);

        await _exerciseVideoDao.deleteAllForExerciseIds(
          dataset.exercises.map((e) => e.id).toList(),
        );
        await _exerciseDao.deleteSourceExercises();
        _logger.info(
          'importDataset — old source exercises deleted',
          metadata: {'deleteCount': dataset.exercises.length},
        );

        final now = DateTime.now();
        final exerciseCompanions = dataset.exercises
            .map(
              (e) => _toExerciseCompanion(
                e,
                datasetVersion: manifest.datasetVersion,
                sourceSchemaVersion: dataset.schemaVersion,
                now: now,
              ),
            )
            .toList();

        final videoCompanions = <ExerciseVideosCompanion>[];
        for (final exercise in dataset.exercises) {
          videoCompanions.addAll(_toVideoCompanions(exercise, now: now));
        }

        await _exerciseDao.insertExercisesBulk(exerciseCompanions);
        _logger.info(
          'importDataset — exercises inserted',
          metadata: {'insertCount': exerciseCompanions.length},
        );
        if (videoCompanions.isNotEmpty) {
          await _exerciseVideoDao.insertVideosBulk(videoCompanions);
        }
        _logger.info('importDataset — restoring user state');
        await _restoreUserState(preservedState);

        final metaCompanion = _toLibraryMetaCompanion(
          dataset: dataset,
          manifest: manifest,
          downloadedAt: downloadedAt,
          now: now,
        );
        await _libraryMetaDao.upsertLibraryMeta(metaCompanion);

        _logger.info(
          'importDataset — complete',
          metadata: {'importedExerciseCount': dataset.exercises.length},
        );
        return ExerciseLibraryImportResult(
          importedExerciseCount: dataset.exercises.length,
          importedVideoCount: videoCompanions.length,
          libraryVersion: manifest.datasetVersion,
        );
      });
    } on ExerciseLibraryImportFailure {
      rethrow;
    } catch (e) {
      _logger.error('importDataset — transaction failed', error: e);
      throw ExerciseLibraryImportFailure(
        code: ExerciseLibraryImportFailureCode.transactionFailed,
        message: e.toString(),
      );
    }
  }

  Future<
    Map<int, ({bool isFavorite, bool isSubstitutedOut, String? userNotes})>
  >
  _preserveUserState(ExerciseDataset dataset) async {
    final exerciseIds = dataset.exercises.map((e) => e.id).toList();
    try {
      return await _exerciseDao.getUserStateByExerciseIds(exerciseIds);
    } catch (e) {
      throw ExerciseLibraryImportFailure(
        code: ExerciseLibraryImportFailureCode.preserveFlagsFailed,
        message: e.toString(),
      );
    }
  }

  Future<void> _restoreUserState(
    Map<int, ({bool isFavorite, bool isSubstitutedOut, String? userNotes})>
    state,
  ) async {
    if (state.isEmpty) return;
    try {
      await _exerciseDao.restoreUserState(state);
    } catch (e) {
      throw ExerciseLibraryImportFailure(
        code: ExerciseLibraryImportFailureCode.preserveFlagsFailed,
        message: e.toString(),
      );
    }
  }

  ExercisesCompanion _toExerciseCompanion(
    ExerciseDatasetExercise exercise, {
    required String datasetVersion,
    required int sourceSchemaVersion,
    required DateTime now,
  }) {
    return ExercisesCompanion(
      id: Value(exercise.id),
      isCustom: const Value(false),
      customExerciseUuid: const Value(null),
      source: const Value('musclewiki'),
      sourceDatasetVersion: Value(datasetVersion),
      sourceSchemaVersion: Value(sourceSchemaVersion),
      name: Value(exercise.name),
      nameNormalized: Value(_normalizeName(exercise.name)),
      difficulty: Value(exercise.difficulty.dbValue),
      primaryMusclesJson: Value(json.encode(exercise.primaryMuscles)),
      muscleGroupsJson: Value(
        json.encode(exercise.muscleGroups.map((e) => e.label).toList()),
      ),
      category: Value(exercise.category),
      modality: Value(exercise.modality.dbValue),
      equipment: Value(exercise.equipment?.dbValue),
      force: Value(exercise.force?.dbValue),
      mechanic: Value(exercise.mechanic?.dbValue),
      gripsJson: Value(json.encode(exercise.grips)),
      stepsJson: Value(json.encode(exercise.steps)),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  List<ExerciseVideosCompanion> _toVideoCompanions(
    ExerciseDatasetExercise exercise, {
    required DateTime now,
  }) {
    final uuid = const Uuid();
    return exercise.videos.asMap().entries.map((entry) {
      final index = entry.key;
      final video = entry.value;
      return ExerciseVideosCompanion(
        id: Value(uuid.v4()),
        exerciseId: Value(exercise.id),
        url: Value(video.url.toString()),
        angle: Value(video.angle.dbValue),
        gender: Value(video.gender.dbValue),
        ogImageUrl: Value(video.ogImage),
        sortOrder: Value(index),
        createdAt: Value(now),
      );
    }).toList();
  }

  LibraryMetaCompanion _toLibraryMetaCompanion({
    required ExerciseDataset dataset,
    required ExerciseDatasetManifest manifest,
    required DateTime downloadedAt,
    required DateTime now,
  }) {
    return LibraryMetaCompanion(
      id: const Value(DbConstants.exerciseLibraryMetaId),
      source: Value(dataset.source),
      schemaVersion: Value(dataset.schemaVersion),
      libraryVersion: Value(manifest.datasetVersion),
      generatedAt: Value(dataset.generatedAt),
      downloadedAt: Value(downloadedAt),
      exerciseCount: Value(dataset.exerciseCount),
      manifestLastUpdatedAt: Value(manifest.generatedAt),
      manifestFilePath: Value(manifest.active.path),
      minAppSchemaVersion: Value(
        manifest.active.minimumSupportedAppSchemaVersion,
      ),
      syncStatus: Value(LibrarySyncStatus.synced.value),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  String _normalizeName(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
