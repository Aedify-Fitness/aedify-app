import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseDatasetManifest', () {
    final validJson = <String, Object?>{
      'schema_version': 1,
      'manifest_version': 1,
      'dataset_version': '2024-01-01',
      'generated_at': '2024-01-01T00:00:00.000Z',
      'source': 'musclewiki',
      'exercise_count': 100,
      'active': <String, Object?>{
        'path': 'datasets/exercises/v1/exercises.json',
        'content_type': 'application/json',
        'size_bytes': 50000,
        'sha256': 'abc123',
        'schema_version': 1,
        'minimum_supported_app_schema_version': 1,
      },
      'history': <Map<String, Object?>>[
        {
          'dataset_version': '2023-06-01',
          'path': 'datasets/exercises/v0/exercises.json',
          'sha256': 'def456',
          'size_bytes': 40000,
          'exercise_count': 90,
          'generated_at': '2023-06-01T00:00:00.000Z',
        },
      ],
    };

    test('valid manifest parses', () {
      final manifest = ExerciseDatasetManifest.fromJson(validJson);
      expect(manifest.schemaVersion, 1);
      expect(manifest.manifestVersion, 1);
      expect(manifest.datasetVersion, '2024-01-01');
      expect(manifest.generatedAt, DateTime.utc(2024, 1, 1));
      expect(manifest.source, 'musclewiki');
      expect(manifest.exerciseCount, 100);
      expect(manifest.active.path, 'datasets/exercises/v1/exercises.json');
      expect(manifest.active.contentType, 'application/json');
      expect(manifest.active.sizeBytes, 50000);
      expect(manifest.active.sha256, 'abc123');
      expect(manifest.active.schemaVersion, 1);
      expect(manifest.active.minimumSupportedAppSchemaVersion, 1);
    });

    test('history parses correctly', () {
      final manifest = ExerciseDatasetManifest.fromJson(validJson);
      expect(manifest.history.length, 1);
      expect(manifest.history[0].datasetVersion, '2023-06-01');
      expect(manifest.history[0].path, 'datasets/exercises/v0/exercises.json');
      expect(manifest.history[0].sha256, 'def456');
      expect(manifest.history[0].sizeBytes, 40000);
      expect(manifest.history[0].exerciseCount, 90);
      expect(manifest.history[0].generatedAt, DateTime.utc(2023, 6, 1));
    });

    test('missing schema_version fails', () {
      final json = Map<String, Object?>.from(validJson)
        ..remove('schema_version');
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('missing active fails', () {
      final json = Map<String, Object?>.from(validJson)..remove('active');
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('invalid schema_version type fails', () {
      final json = Map<String, Object?>.from(validJson)
        ..['schema_version'] = 'not_an_int';
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('invalid active type fails', () {
      final json = Map<String, Object?>.from(validJson)
        ..['active'] = 'not_an_object';
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('missing active.path field fails', () {
      final json = Map<String, Object?>.from(validJson)
        ..['active'] = <String, Object?>{
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

    test('invalid active.size_bytes type fails', () {
      final json = Map<String, Object?>.from(validJson)
        ..['active'] = <String, Object?>{
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

    test('missing history field fails', () {
      final json = Map<String, Object?>.from(validJson)..remove('history');
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });

    test('invalid history entry type fails', () {
      final json = Map<String, Object?>.from(validJson)
        ..['history'] = ['not_a_map'];
      expect(
        () => ExerciseDatasetManifest.fromJson(json),
        throwsFormatException,
      );
    });
  });
}
