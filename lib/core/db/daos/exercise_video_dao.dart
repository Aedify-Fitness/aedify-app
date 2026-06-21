import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/exercise_videos.dart';

part 'exercise_video_dao.g.dart';

@DriftAccessor(tables: [ExerciseVideos])
class ExerciseVideoDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseVideoDaoMixin {
  ExerciseVideoDao(super.db);

  Future<void> insertVideosBulk(List<ExerciseVideosCompanion> entries) {
    return batch(
      (batch) => batch.insertAllOnConflictUpdate(exerciseVideos, entries),
    );
  }

  Future<void> deleteAllForExerciseIds(List<int> exerciseIds) async {
    await (delete(
      exerciseVideos,
    )..where((t) => t.exerciseId.isIn(exerciseIds))).go();
  }

  Future<void> deleteAllVideos() async {
    await delete(exerciseVideos).go();
  }
}
