import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart' as p;
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/core/tts/exercise_tts_service.dart';

class FlutterExerciseTtsService implements ExerciseTtsService {
  static final _logger = AppLogger(name: 'FlutterExerciseTtsService');

  FlutterExerciseTtsService({
    required FlutterTts flutterTts,
    required LocalFileStore fileStore,
  }) : _flutterTts = flutterTts,
       _fileStore = fileStore;

  final FlutterTts _flutterTts;
  final LocalFileStore _fileStore;

  @override
  Future<bool> isAvailable() async {
    try {
      final engines = await _flutterTts.getEngines;
      final available = engines != null && engines.isNotEmpty;
      _logger.info('isAvailable — result: $available');
      return available;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> speak(String text) async {
    _flutterTts.setCompletionHandler(() {});
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  Future<String?> synthesizeToFile({
    required String text,
    required String relativeOutputPath,
  }) async {
    _logger.info('synthesizeToFile — start');
    try {
      final absolutePath = await _fileStore.toAbsolutePath(relativeOutputPath);
      final dir = Directory(p.dirname(absolutePath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      _flutterTts.setCompletionHandler(() {});
      final result = await _flutterTts.synthesizeToFile(text, absolutePath);

      if (result != null && result.isNotEmpty) {
        final file = File(result);
        if (await file.exists()) {
          _logger.info('synthesizeToFile — complete');
          return relativeOutputPath;
        }
      }

      return null;
    } catch (e) {
      _logger.error('synthesizeToFile failed', error: e);
      return null;
    }
  }
}
