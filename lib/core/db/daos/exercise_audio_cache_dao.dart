import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/exercise_audio_cache.dart';

part 'exercise_audio_cache_dao.g.dart';

@DriftAccessor(tables: [ExerciseAudioCache])
class ExerciseAudioCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseAudioCacheDaoMixin {
  ExerciseAudioCacheDao(super.db);

  Future<ExerciseAudioCacheData?> getByExerciseAndStep({
    required int exerciseId,
    required int stepIndex,
    required String textHash,
  }) {
    return (select(exerciseAudioCache)..where(
          (t) =>
              t.exerciseId.equals(exerciseId) &
              t.stepIndex.equals(stepIndex) &
              t.textHash.equals(textHash),
        ))
        .getSingleOrNull();
  }

  Future<void> upsertCacheEntry(ExerciseAudioCacheCompanion entry) {
    return into(exerciseAudioCache).insertOnConflictUpdate(entry);
  }

  Future<void> deleteByExerciseId(int exerciseId) async {
    await (delete(
      exerciseAudioCache,
    )..where((t) => t.exerciseId.equals(exerciseId))).go();
  }

  Future<void> deleteByRelativePath(String relativePath) async {
    await (delete(
      exerciseAudioCache,
    )..where((t) => t.localRelativePath.equals(relativePath))).go();
  }

  Future<void> updateLastAccessed({
    required String id,
    required DateTime lastAccessedAt,
  }) async {
    await (update(exerciseAudioCache)..where((t) => t.id.equals(id))).write(
      ExerciseAudioCacheCompanion(lastAccessedAt: Value(lastAccessedAt)),
    );
  }

  Stream<List<ExerciseAudioCacheData>> watchByExerciseId(int exerciseId) {
    return (select(
      exerciseAudioCache,
    )..where((t) => t.exerciseId.equals(exerciseId))).watch();
  }
}
