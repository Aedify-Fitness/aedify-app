import 'dart:convert';
import 'dart:io';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class ExerciseStepAudioController
    extends Notifier<Map<String, ExerciseStepAudioState>> {
  @override
  Map<String, ExerciseStepAudioState> build() => {};

  String _key(int exerciseId, int stepIndex) => '$exerciseId:$stepIndex';

  String _computeTextHash(String text) {
    final bytes = utf8.encode(text);
    return sha256.convert(bytes).toString();
  }

  String _cacheId(int exerciseId, int stepIndex, String textHash) =>
      '$exerciseId:$stepIndex:$textHash';

  Future<void> playStep({
    required int exerciseId,
    required int stepIndex,
    required String text,
  }) async {
    final key = _key(exerciseId, stepIndex);

    state = {
      ...state,
      key: const ExerciseStepAudioState(
        phase: ExerciseStepAudioPhase.checkingCache,
      ),
    };

    try {
      final ttsService = ref.read(AppProviders.exerciseTtsServiceProvider);
      final dao = ref.read(AppProviders.exerciseAudioCacheDaoProvider);
      final fileStore = ref.read(AppProviders.localFileStoreProvider);

      final available = await ttsService.isAvailable();
      if (!available) {
        state = {
          ...state,
          key: const ExerciseStepAudioState(
            phase: ExerciseStepAudioPhase.unavailable,
            errorCode: 'tts_unavailable',
            errorMessage: AppErrorStrings.ttsUnavailableMessage,
          ),
        };
        return;
      }

      final textHash = _computeTextHash(text);
      final cacheEntry = await dao.getByExerciseAndStep(
        exerciseId: exerciseId,
        stepIndex: stepIndex,
        textHash: textHash,
      );

      if (cacheEntry != null) {
        await dao.updateLastAccessed(
          id: cacheEntry.id,
          lastAccessedAt: DateTime.now(),
        );
      } else {
        state = {
          ...state,
          key: const ExerciseStepAudioState(
            phase: ExerciseStepAudioPhase.generating,
          ),
        };

        final cacheDir = await fileStore.exerciseAudioCacheDir(
          exerciseId.toString(),
        );
        final relativeDir = await fileStore.toRelativePath(cacheDir.path);
        final fileName = '$stepIndex-$textHash.wav';
        final relativePath = p.join(relativeDir, fileName);

        final synthesizedPath = await ttsService.synthesizeToFile(
          text: text,
          relativeOutputPath: relativePath,
        );

        if (synthesizedPath != null) {
          final absolutePath = await fileStore.toAbsolutePath(synthesizedPath);
          final file = File(absolutePath);

          int? fileSize;
          try {
            fileSize = await file.length();
          } catch (_) {}

          await dao.upsertCacheEntry(
            ExerciseAudioCacheCompanion.insert(
              id: _cacheId(exerciseId, stepIndex, textHash),
              exerciseId: exerciseId,
              stepIndex: stepIndex,
              textHash: textHash,
              localRelativePath: synthesizedPath,
              fileSizeBytes: fileSize != null
                  ? Value(fileSize)
                  : const Value.absent(),
              generatedAt: DateTime.now(),
            ),
          );
        }
      }

      state = {
        ...state,
        key: ExerciseStepAudioState(
          phase: ExerciseStepAudioPhase.speaking,
          activeStepIndex: stepIndex,
        ),
      };

      await ttsService.speak(text);
    } catch (e) {
      state = {
        ...state,
        key: const ExerciseStepAudioState(
          phase: ExerciseStepAudioPhase.failed,
          errorCode: 'audio_playback_failed',
          errorMessage: AppErrorStrings.audioPlaybackFailedMessage,
        ),
      };
    }
  }

  Future<void> stop(int exerciseId, int stepIndex) async {
    final key = _key(exerciseId, stepIndex);
    final ttsService = ref.read(AppProviders.exerciseTtsServiceProvider);
    await ttsService.stop();
    state = {...state, key: const ExerciseStepAudioState.idle()};
  }
}
