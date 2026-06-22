abstract class ExerciseTtsService {
  Future<bool> isAvailable();

  Future<void> speak(String text);

  Future<void> stop();

  Future<String?> synthesizeToFile({
    required String text,
    required String relativeOutputPath,
  });
}
