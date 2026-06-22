import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/exercise_library/exercise_library_fixture_loader.dart';

void main() {
  group('ExerciseDatasetManifest', () {
    group('fromJson with valid fixture', () {
      late Map<String, Object?> validJson;

      setUp(() async {
        validJson = await ExerciseLibraryFixtureLoader.loadJsonObject(
          'manifest_valid.json',
        );
      });

      test('valid manifest parses', () async {
        final manifest = ExerciseDatasetManifest.fromJson(validJson);
        expect(manifest.schemaVersion, 1);
        expect(manifest.manifestVersion, 3);
        expect(manifest.datasetVersion, '2026-06-22-v1');
        expect(manifest.generatedAt, DateTime.utc(2026, 6, 22));
        expect(manifest.source, 'musclewiki');
        expect(manifest.exerciseCount, 350);
      });

      test('history parses correctly from fixture', () async {
        final manifest = ExerciseDatasetManifest.fromJson(validJson);
        expect(manifest.history, hasLength(2));
        expect(manifest.history[0].datasetVersion, '2026-06-01-v0');
        expect(manifest.history[0].generatedAt, DateTime.utc(2026, 6, 1));
        expect(manifest.history[1].datasetVersion, '2026-05-15-v0');
        expect(manifest.history[1].generatedAt, DateTime.utc(2026, 5, 15));
      });

      test('active parses correctly from fixture', () async {
        final manifest = ExerciseDatasetManifest.fromJson(validJson);
        expect(manifest.active.path, 'datasets/exercises/2026-06-22-v1.json');
        expect(manifest.active.sizeBytes, 285000);
        expect(manifest.active.schemaVersion, 1);
        expect(manifest.active.minimumSupportedAppSchemaVersion, 1);
      });
    });

    group('missing schema_version fails', () {
      test('from valid fixture', () async {
        final json = await ExerciseLibraryFixtureLoader.loadJsonObject(
          'manifest_valid.json',
        );
        (json as Map).remove('schema_version');
        expect(
          () => ExerciseDatasetManifest.fromJson(json),
          throwsFormatException,
        );
      });
    });

    test('missing active fails', () async {
      final json = await ExerciseLibraryFixtureLoader.loadJsonObject(
        'manifest_missing_active.json',
      );
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('invalid schema_version type fails', () async {
      final json = await ExerciseLibraryFixtureLoader.loadJsonObject(
        'manifest_valid.json',
      );
      json['schema_version'] = 'not_an_int';
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('invalid active type fails', () async {
      final json = await ExerciseLibraryFixtureLoader.loadJsonObject(
        'manifest_valid.json',
      );
      json['active'] = 'not_an_object';
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('missing active.path field fails', () async {
      final json = await ExerciseLibraryFixtureLoader.loadJsonObject(
        'manifest_valid.json',
      );
      json['active'] = <String, Object?>{
        'content_type': 'application/json',
        'size_bytes': 50000,
        'sha256': 'abc123',
        'schema_version': 1,
        'minimum_supported_app_schema_version': 1,
      };
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('invalid active.size_bytes type fails', () async {
      final json = await ExerciseLibraryFixtureLoader.loadJsonObject(
        'manifest_valid.json',
      );
      json['active'] = <String, Object?>{
        'path': 'datasets/exercises/v1/exercises.json',
        'content_type': 'application/json',
        'size_bytes': 'not_an_int',
        'sha256': 'abc123',
        'schema_version': 1,
        'minimum_supported_app_schema_version': 1,
      };
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('missing history field fails', () async {
      final json = await ExerciseLibraryFixtureLoader.loadJsonObject(
        'manifest_valid.json',
      );
      (json as Map).remove('history');
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('invalid history entry type fails', () async {
      final json = await ExerciseLibraryFixtureLoader.loadJsonObject(
        'manifest_valid.json',
      );
      json['history'] = ['not_a_map'];
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    group('future schema manifest', () {
      test('requires minimum_supported_app_schema_version 2', () async {
        final json = await ExerciseLibraryFixtureLoader.loadJsonObject(
          'manifest_future_schema_required.json',
        );
        final manifest = ExerciseDatasetManifest.fromJson(json);
        expect(manifest.active.minimumSupportedAppSchemaVersion, 2);
      });
    });
  });
}
