import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_video_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('ExerciseVideoDao', () {
    late AppDatabase db;
    late ExerciseVideoDao dao;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = ExerciseVideoDao(db);
    });

    tearDown(() {
      db.close();
    });

    List<ExerciseVideosCompanion> sampleVideos(
      int exerciseId, {
      int count = 2,
    }) {
      final uuid = const Uuid();
      return List.generate(
        count,
        (i) => ExerciseVideosCompanion(
          id: Value(uuid.v4()),
          exerciseId: Value(exerciseId),
          url: Value('https://example.com/video_${exerciseId}_$i.mp4'),
          angle: Value('front'),
          gender: Value('male'),
          sortOrder: Value(i),
          createdAt: Value(DateTime.now()),
        ),
      );
    }

    test('insert bulk videos', () async {
      final videos = sampleVideos(1, count: 3);
      await dao.insertVideosBulk(videos);

      final allVideos = await db.select(db.exerciseVideos).get();
      expect(allVideos.length, 3);
    });

    test('delete all videos', () async {
      await dao.insertVideosBulk(sampleVideos(1, count: 2));
      await dao.insertVideosBulk(sampleVideos(2, count: 1));

      var count = await db.select(db.exerciseVideos).get();
      expect(count.length, 3);

      await dao.deleteAllVideos();
      count = await db.select(db.exerciseVideos).get();
      expect(count, isEmpty);
    });

    test('delete by exercise ids', () async {
      await dao.insertVideosBulk(sampleVideos(1, count: 2));
      await dao.insertVideosBulk(sampleVideos(2, count: 1));
      await dao.insertVideosBulk(sampleVideos(3, count: 3));

      await dao.deleteAllForExerciseIds([1, 3]);

      final remaining = await db.select(db.exerciseVideos).get();
      expect(remaining.length, 1);
      expect(remaining.first.exerciseId, 2);
    });
  });
}
