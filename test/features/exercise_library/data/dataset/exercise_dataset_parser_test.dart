import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_parser.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_validation_failure.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_mechanic.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/exercise_library/exercise_library_fixture_loader.dart';

void main() {
  late ExerciseDatasetParser parser;

  setUp(() {
    parser = const ExerciseDatasetParser();
  });

  group('ExerciseDatasetParser', () {
    group('parse valid dataset fixture', () {
      test('parses all 12 exercises from dataset_valid.json', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_valid.json',
        );
        final dataset = parser.parse(
          rawJson: rawJson,
          supportedSchemaVersion: 1,
          minimumSupportedAppSchemaVersion: 1,
        );

        expect(dataset.schemaVersion, 1);
        expect(dataset.source, 'musclewiki');
        expect(dataset.exerciseCount, 12);
        expect(dataset.exercises.length, 12);

        final ex1 = dataset.exercises[0];
        expect(ex1.id, 1);
        expect(ex1.name, 'Barbell Bench Press');
        expect(ex1.difficulty, ExerciseDifficulty.intermediate);
        expect(ex1.modality, ExerciseModality.strength);
        expect(ex1.equipment, EquipmentTag.barbell);
        expect(ex1.mechanic, ExerciseMechanic.compound);
        expect(ex1.force, ExerciseForce.push);
        expect(ex1.videos.length, 2);
      });

      test('includes exercises with no videos', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_valid.json',
        );
        final dataset = parser.parse(
          rawJson: rawJson,
          supportedSchemaVersion: 1,
          minimumSupportedAppSchemaVersion: 1,
        );

        final noVideoIds = dataset.exercises
            .where((e) => e.videos.isEmpty)
            .map((e) => e.id)
            .toSet();
        expect(noVideoIds, containsAll([3, 4, 9, 11, 12]));
      });

      test('includes non-strength exercise with null equipment', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_valid.json',
        );
        final dataset = parser.parse(
          rawJson: rawJson,
          supportedSchemaVersion: 1,
          minimumSupportedAppSchemaVersion: 1,
        );

        final running = dataset.exercises.firstWhere((e) => e.id == 4);
        expect(running.modality, ExerciseModality.cardio);
        expect(running.equipment, isNull);
      });
    });

    group('reject malformed JSON', () {
      test('rejects non-JSON input', () {
        expect(
          () => parser.parse(
            rawJson: 'not json',
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.invalidTopLevelShape,
            ),
          ),
        );
      });

      test('rejects JSON array instead of object', () {
        expect(
          () => parser.parse(
            rawJson: '[1, 2, 3]',
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.invalidTopLevelShape,
            ),
          ),
        );
      });
    });

    group('reject missing fields', () {
      test('rejects missing schema_version', () {
        expect(
          () => parser.parse(
            rawJson:
                '{"generated_at": "2024-01-01T00:00:00.000Z", '
                '"source": "mw", "exercise_count": 1, "exercises": []}',
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.missingRequiredField,
            ),
          ),
        );
      });

      test('rejects missing generated_at', () {
        expect(
          () => parser.parse(
            rawJson:
                '{"schema_version": 1, '
                '"source": "mw", "exercise_count": 1, "exercises": []}',
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.missingRequiredField,
            ),
          ),
        );
      });

      test('rejects missing source', () {
        expect(
          () => parser.parse(
            rawJson:
                '{"schema_version": 1, '
                '"generated_at": "2024-01-01T00:00:00.000Z", '
                '"exercise_count": 1, "exercises": []}',
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.missingRequiredField,
            ),
          ),
        );
      });

      test('rejects missing exercise_count', () {
        expect(
          () => parser.parse(
            rawJson:
                '{"schema_version": 1, '
                '"generated_at": "2024-01-01T00:00:00.000Z", '
                '"source": "mw", "exercises": []}',
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.missingRequiredField,
            ),
          ),
        );
      });

      test('rejects missing exercises', () {
        expect(
          () => parser.parse(
            rawJson:
                '{"schema_version": 1, '
                '"generated_at": "2024-01-01T00:00:00.000Z", '
                '"source": "mw", "exercise_count": 0}',
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.missingRequiredField,
            ),
          ),
        );
      });
    });

    group('reject schema version issues', () {
      test('rejects unsupported dataset schema version via fixture', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_future_schema.json',
        );
        expect(
          () => parser.parse(
            rawJson: rawJson,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.unsupportedSchemaVersion,
            ),
          ),
        );
      });
    });

    group('reject exercise count mismatch', () {
      test('rejects count mismatch via fixture', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_count_mismatch.json',
        );
        expect(
          () => parser.parse(
            rawJson: rawJson,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.exerciseCountMismatch,
            ),
          ),
        );
      });
    });

    group('reject duplicate IDs', () {
      test('rejects duplicate exercise ids via fixture', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_duplicate_ids.json',
        );
        expect(
          () => parser.parse(
            rawJson: rawJson,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.duplicateExerciseId,
            ),
          ),
        );
      });
    });

    group('reject invalid exercise fields', () {
      test('rejects empty exercise name', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 1,'
            '"exercises": ['
            '{'
            '"id": 1,'
            '"name": "",'
            '"difficulty": "intermediate",'
            '"primary_muscles": ["Chest"],'
            '"muscle_groups": ["Chest"],'
            '"modality": "strength",'
            '"equipment": "barbell",'
            '"grips": ["barbell"],'
            '"steps": ["Step 1"],'
            '"videos": []'
            '}'
            ']'
            '}';
        expect(
          () => parser.parse(
            rawJson: json,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.missingRequiredField,
            ),
          ),
        );
      });

      test('rejects invalid difficulty via fixture', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_invalid_difficulty.json',
        );
        expect(
          () => parser.parse(
            rawJson: rawJson,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.invalidDifficulty,
            ),
          ),
        );
      });

      test('rejects invalid modality via fixture', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_invalid_modality.json',
        );
        expect(
          () => parser.parse(
            rawJson: rawJson,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.invalidModality,
            ),
          ),
        );
      });

      test('rejects unknown muscle group bucket via fixture', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_unknown_muscle_group.json',
        );
        expect(
          () => parser.parse(
            rawJson: rawJson,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.invalidMuscleGroup,
            ),
          ),
        );
      });

      test('rejects non-list primary_muscles', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 1,'
            '"exercises": ['
            '{'
            '"id": 1,'
            '"name": "Bench",'
            '"difficulty": "intermediate",'
            '"primary_muscles": "not_a_list",'
            '"muscle_groups": ["Chest"],'
            '"modality": "strength",'
            '"equipment": "barbell",'
            '"grips": [],'
            '"steps": ["Step 1"],'
            '"videos": []'
            '}'
            ']'
            '}';
        expect(
          () => parser.parse(
            rawJson: json,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.missingRequiredField,
            ),
          ),
        );
      });

      test('rejects non-list steps', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 1,'
            '"exercises": ['
            '{'
            '"id": 1,'
            '"name": "Bench",'
            '"difficulty": "intermediate",'
            '"primary_muscles": ["Chest"],'
            '"muscle_groups": ["Chest"],'
            '"modality": "strength",'
            '"equipment": "barbell",'
            '"grips": [],'
            '"steps": "not_a_list",'
            '"videos": []'
            '}'
            ']'
            '}';
        expect(
          () => parser.parse(
            rawJson: json,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.missingRequiredField,
            ),
          ),
        );
      });

      test('rejects non-list videos', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 1,'
            '"exercises": ['
            '{'
            '"id": 1,'
            '"name": "Bench",'
            '"difficulty": "intermediate",'
            '"primary_muscles": ["Chest"],'
            '"muscle_groups": ["Chest"],'
            '"modality": "strength",'
            '"equipment": "barbell",'
            '"grips": [],'
            '"steps": ["Step 1"],'
            '"videos": "not_a_list"'
            '}'
            ']'
            '}';
        expect(
          () => parser.parse(
            rawJson: json,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.missingRequiredField,
            ),
          ),
        );
      });

      test('allows empty steps', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 1,'
            '"exercises": ['
            '{'
            '"id": 1,'
            '"name": "Bench",'
            '"difficulty": "intermediate",'
            '"primary_muscles": ["Chest"],'
            '"muscle_groups": ["Chest"],'
            '"modality": "strength",'
            '"equipment": "barbell",'
            '"grips": [],'
            '"steps": [],'
            '"videos": []'
            '}'
            ']'
            '}';
        final dataset = parser.parse(
          rawJson: json,
          supportedSchemaVersion: 1,
          minimumSupportedAppSchemaVersion: 1,
        );
        expect(dataset.exercises, hasLength(1));
        expect(dataset.exercises.first.steps, isEmpty);
      });

      test('allows empty primary_muscles', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 1,'
            '"exercises": ['
            '{'
            '"id": 1,'
            '"name": "Bench",'
            '"difficulty": "intermediate",'
            '"primary_muscles": [],'
            '"muscle_groups": ["Chest"],'
            '"modality": "strength",'
            '"equipment": "barbell",'
            '"grips": [],'
            '"steps": ["Step 1"],'
            '"videos": []'
            '}'
            ']'
            '}';
        final dataset = parser.parse(
          rawJson: json,
          supportedSchemaVersion: 1,
          minimumSupportedAppSchemaVersion: 1,
        );
        expect(dataset.exercises, hasLength(1));
        expect(dataset.exercises.first.primaryMuscles, isEmpty);
      });
    });

    group('reject invalid video', () {
      test('rejects invalid video url via fixture', () async {
        final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
          'dataset_invalid_video_url.json',
        );
        expect(
          () => parser.parse(
            rawJson: rawJson,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.invalidVideoUrl,
            ),
          ),
        );
      });
    });

    group('nullable fields', () {
      test('allows nullable force and mechanic', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 1,'
            '"exercises": ['
            '{'
            '"id": 1,'
            '"name": "Bench",'
            '"difficulty": "intermediate",'
            '"primary_muscles": ["Chest"],'
            '"muscle_groups": ["Chest"],'
            '"modality": "strength",'
            '"equipment": "barbell",'
            '"grips": [],'
            '"steps": ["Step 1"],'
            '"videos": ['
            '{'
            '"url": "https://example.com/v.mp4",'
            '"angle": "front",'
            '"gender": "male"'
            '}'
            ']'
            '}'
            ']'
            '}';
        final dataset = parser.parse(
          rawJson: json,
          supportedSchemaVersion: 1,
          minimumSupportedAppSchemaVersion: 1,
        );

        expect(dataset.exercises[0].force, isNull);
        expect(dataset.exercises[0].mechanic, isNull);
      });

      test(
        'allows nullable equipment for non-strength modality via fixture',
        () async {
          final rawJson = await ExerciseLibraryFixtureLoader.loadRawString(
            'dataset_valid.json',
          );
          final dataset = parser.parse(
            rawJson: rawJson,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          );

          final running = dataset.exercises.firstWhere((e) => e.id == 4);
          expect(running.modality, ExerciseModality.cardio);
          expect(running.equipment, isNull);
        },
      );

      test('strength exercise without equipment is rejected', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 1,'
            '"exercises": ['
            '{'
            '"id": 1,'
            '"name": "Press",'
            '"difficulty": "intermediate",'
            '"primary_muscles": ["Chest"],'
            '"muscle_groups": ["Chest"],'
            '"modality": "strength",'
            '"grips": [],'
            '"steps": ["Press"],'
            '"videos": []'
            '}'
            ']'
            '}';
        expect(
          () => parser.parse(
            rawJson: json,
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode.invalidStrengthEquipment,
            ),
          ),
        );
      });
    });

    test('accepts empty videos list for exercise with videos field empty', () {
      final json =
          '{'
          '"schema_version": 1,'
          '"generated_at": "2024-01-01T00:00:00.000Z",'
          '"source": "musclewiki",'
          '"exercise_count": 1,'
          '"exercises": ['
          '{'
          '"id": 1,'
          '"name": "Bench",'
          '"difficulty": "intermediate",'
          '"primary_muscles": ["Chest"],'
          '"muscle_groups": ["Chest"],'
          '"modality": "strength",'
          '"equipment": "barbell",'
          '"grips": [],'
          '"steps": ["Step 1"],'
          '"videos": []'
          '}'
          ']'
          '}';
      final dataset = parser.parse(
        rawJson: json,
        supportedSchemaVersion: 1,
        minimumSupportedAppSchemaVersion: 1,
      );

      expect(dataset.exercises[0].videos, isEmpty);
    });
  });
}
