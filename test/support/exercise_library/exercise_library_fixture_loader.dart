import 'dart:convert';
import 'dart:io';

class ExerciseLibraryFixtureLoader {
  ExerciseLibraryFixtureLoader._();

  static const _fixtureDir = 'test/fixtures/exercise_library';

  static Future<String> loadRawString(String fixtureName) async {
    final file = File('$_fixtureDir/$fixtureName');
    if (!await file.exists()) {
      throw Exception('Fixture not found: $_fixtureDir/$fixtureName');
    }
    return file.readAsString();
  }

  static Future<Map<String, Object?>> loadJsonObject(String fixtureName) async {
    final raw = await loadRawString(fixtureName);
    final parsed = json.decode(raw);
    if (parsed is! Map<String, Object?>) {
      throw Exception('Fixture $fixtureName is not a JSON object');
    }
    return parsed;
  }

  static Future<List<Object?>> loadJsonArray(String fixtureName) async {
    final raw = await loadRawString(fixtureName);
    final parsed = json.decode(raw);
    if (parsed is! List<Object?>) {
      throw Exception('Fixture $fixtureName is not a JSON array');
    }
    return parsed;
  }
}
