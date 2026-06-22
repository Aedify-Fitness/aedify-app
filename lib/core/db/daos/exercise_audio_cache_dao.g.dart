// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_audio_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$ExerciseAudioCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $ExerciseAudioCacheTable get exerciseAudioCache =>
      attachedDatabase.exerciseAudioCache;
  ExerciseAudioCacheDaoManager get managers =>
      ExerciseAudioCacheDaoManager(this);
}

class ExerciseAudioCacheDaoManager {
  final _$ExerciseAudioCacheDaoMixin _db;
  ExerciseAudioCacheDaoManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$ExerciseAudioCacheTableTableManager get exerciseAudioCache =>
      $$ExerciseAudioCacheTableTableManager(
        _db.attachedDatabase,
        _db.exerciseAudioCache,
      );
}
