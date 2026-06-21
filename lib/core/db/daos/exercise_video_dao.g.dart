// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_video_dao.dart';

// ignore_for_file: type=lint
mixin _$ExerciseVideoDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $ExerciseVideosTable get exerciseVideos => attachedDatabase.exerciseVideos;
  ExerciseVideoDaoManager get managers => ExerciseVideoDaoManager(this);
}

class ExerciseVideoDaoManager {
  final _$ExerciseVideoDaoMixin _db;
  ExerciseVideoDaoManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$ExerciseVideosTableTableManager get exerciseVideos =>
      $$ExerciseVideosTableTableManager(
        _db.attachedDatabase,
        _db.exerciseVideos,
      );
}
