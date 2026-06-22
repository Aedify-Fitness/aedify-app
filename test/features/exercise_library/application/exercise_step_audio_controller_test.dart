import 'dart:convert';
import 'dart:io';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_audio_cache_dao.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/core/tts/exercise_tts_service.dart';
import 'package:aedify/features/exercise_library/application/exercise_step_audio_controller.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExerciseTtsService implements ExerciseTtsService {
  bool _available = true;
  bool shouldFailSynthesis = false;
  String? lastSpokenText;

  void setAvailable(bool value) => _available = value;

  @override
  Future<bool> isAvailable() async => _available;

  @override
  Future<void> speak(String text) async {
    lastSpokenText = text;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<String?> synthesizeToFile({
    required String text,
    required String relativeOutputPath,
  }) async {
    if (shouldFailSynthesis) return null;
    return relativeOutputPath;
  }
}

void main() {
  group('ExerciseStepAudioController', () {
    late ProviderContainer container;
    late ExerciseStepAudioController controller;
    late FakeExerciseTtsService ttsService;
    late ExerciseAudioCacheDao dao;
    late AppDatabase db;
    late Directory tempDir;
    late LocalFileStore fileStore;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = ExerciseAudioCacheDao(db);
      ttsService = FakeExerciseTtsService();
      tempDir = Directory.systemTemp.createTempSync('audio_ctrl_test_');
      fileStore = LocalFileStore(basePath: tempDir.path);

      container = ProviderContainer(
        overrides: [
          AppProviders.exerciseAudioCacheDaoProvider.overrideWithValue(dao),
          AppProviders.exerciseTtsServiceProvider.overrideWithValue(ttsService),
          AppProviders.localFileStoreProvider.overrideWithValue(fileStore),
        ],
      );
      controller = container.read(
        AppProviders.exerciseStepAudioControllerProvider.notifier,
      );
    });

    tearDown(() {
      container.dispose();
      db.close();
      tempDir.deleteSync(recursive: true);
    });

    String key(int exerciseId, int stepIndex) => '$exerciseId:$stepIndex';

    test('initial state is empty', () {
      expect(
        container.read(AppProviders.exerciseStepAudioControllerProvider),
        equals(<String, ExerciseStepAudioState>{}),
      );
    });

    test('unavailable TTS becomes unavailable state', () async {
      ttsService.setAvailable(false);

      await controller.playStep(exerciseId: 1, stepIndex: 0, text: 'Step one');

      final state = container.read(
        AppProviders.exerciseStepAudioControllerProvider,
      );

      final stepState = state[key(1, 0)];
      expect(stepState, isNotNull);
      expect(stepState!.phase, ExerciseStepAudioPhase.unavailable);
      expect(stepState.errorCode, 'tts_unavailable');
      expect(stepState.errorMessage, AppErrorStrings.ttsUnavailableMessage);
    });

    test('cache hit updates last accessed and speaks', () async {
      final textHash = sha256.convert(utf8.encode('Step one')).toString();
      await dao.upsertCacheEntry(
        ExerciseAudioCacheCompanion.insert(
          id: '1:0:$textHash',
          exerciseId: 1,
          stepIndex: 0,
          textHash: textHash,
          localRelativePath: 'audio-cache/exercise_steps/1/0-hash.wav',
          generatedAt: DateTime.now(),
        ),
      );

      await controller.playStep(exerciseId: 1, stepIndex: 0, text: 'Step one');

      final state = container.read(
        AppProviders.exerciseStepAudioControllerProvider,
      );
      final stepState = state[key(1, 0)];
      expect(stepState, isNotNull);
      expect(stepState!.phase, ExerciseStepAudioPhase.speaking);
      expect(ttsService.lastSpokenText, 'Step one');

      final entry = await dao.getByExerciseAndStep(
        exerciseId: 1,
        stepIndex: 0,
        textHash: textHash,
      );
      expect(entry, isNotNull);
      expect(entry!.lastAccessedAt, isNotNull);
    });

    test('cache miss generates and stores cache entry', () async {
      final textHash = sha256.convert(utf8.encode('Step one')).toString();

      await controller.playStep(exerciseId: 1, stepIndex: 0, text: 'Step one');

      final state = container.read(
        AppProviders.exerciseStepAudioControllerProvider,
      );
      final stepState = state[key(1, 0)];
      expect(stepState, isNotNull);
      expect(stepState!.phase, ExerciseStepAudioPhase.speaking);
      expect(ttsService.lastSpokenText, 'Step one');

      final entry = await dao.getByExerciseAndStep(
        exerciseId: 1,
        stepIndex: 0,
        textHash: textHash,
      );
      expect(entry, isNotNull);
      expect(entry!.textHash, textHash);
    });

    test('generation failure becomes failed state', () async {
      ttsService.shouldFailSynthesis = true;

      await controller.playStep(exerciseId: 1, stepIndex: 0, text: 'Step one');

      final state = container.read(
        AppProviders.exerciseStepAudioControllerProvider,
      );
      final stepState = state[key(1, 0)];
      expect(stepState, isNotNull);
      expect(stepState!.phase, ExerciseStepAudioPhase.speaking);
      expect(ttsService.lastSpokenText, 'Step one');
    });

    test('stop returns to idle', () async {
      await controller.playStep(exerciseId: 1, stepIndex: 0, text: 'Step one');

      await controller.stop(1, 0);

      final state = container.read(
        AppProviders.exerciseStepAudioControllerProvider,
      );
      final stepState = state[key(1, 0)];
      expect(stepState, isNotNull);
      expect(stepState!.phase, ExerciseStepAudioPhase.idle);
    });
  });
}
