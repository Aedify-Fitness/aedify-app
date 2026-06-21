import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_parser.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_validation_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseDatasetParser', () {
    late ExerciseDatasetParser parser;

    setUp(() {
      parser = const ExerciseDatasetParser();
    });

    String validDataset({int count = 1, int schema = 1, int minSchema = 1}) {
      final exercises = List.generate(count, (i) => exerciseJson(id: i + 1));
      return '''
{
  "schema_version": $schema,
  "generated_at": "2024-01-01T00:00:00.000Z",
  "source": "musclewiki",
  "exercise_count": $count,
  "exercises": [${exercises.join(',')}]
}
''';
    }

    group('parse valid dataset', () {
      test('parses valid dataset', () {
        final dataset = parser.parse(
          rawJson: validDataset(),
          supportedSchemaVersion: 1,
          minimumSupportedAppSchemaVersion: 1,
        );

        expect(dataset.schemaVersion, 1);
        expect(dataset.source, 'musclewiki');
        expect(dataset.exerciseCount, 1);
        expect(dataset.exercises.length, 1);

        final ex = dataset.exercises.first;
        expect(ex.id, 1);
        expect(ex.name, 'Bench Press');
        expect(ex.difficulty, 'intermediate');
        expect(ex.primaryMuscles, ['Chest']);
        expect(ex.muscleGroups, ['Chest', 'Triceps']);
        expect(ex.category, 'compound');
        expect(ex.modality, 'strength');
        expect(ex.equipment, 'barbell');
        expect(ex.force, 'push');
        expect(ex.mechanic, 'compound');
        expect(ex.grips, ['barbell']);
        expect(ex.steps, ['Lie on bench', 'Press bar']);
        expect(ex.videos.length, 1);
        expect(ex.videos[0].url.toString(), 'https://example.com/video.mp4');
        expect(ex.videos[0].angle, 'front');
        expect(ex.videos[0].gender, 'male');
        expect(ex.videos[0].ogImage, 'https://example.com/thumb.jpg');
      });

      test('parses multiple exercises', () {
        final dataset = parser.parse(
          rawJson: validDataset(count: 3),
          supportedSchemaVersion: 1,
          minimumSupportedAppSchemaVersion: 1,
        );

        expect(dataset.exercises.length, 3);
        expect(dataset.exercises[0].id, 1);
        expect(dataset.exercises[1].id, 2);
        expect(dataset.exercises[2].id, 3);
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
      test('rejects unsupported dataset schema version', () {
        expect(
          () => parser.parse(
            rawJson: validDataset(schema: 2),
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

      test('rejects unsupported minimum app schema version', () {
        expect(
          () => parser.parse(
            rawJson: validDataset(schema: 0),
            supportedSchemaVersion: 1,
            minimumSupportedAppSchemaVersion: 1,
          ),
          throwsA(
            isA<ExerciseDatasetValidationFailure>().having(
              (f) => f.code,
              'code',
              ExerciseDatasetValidationFailureCode
                  .unsupportedMinimumAppSchemaVersion,
            ),
          ),
        );
      });
    });

    group('reject exercise count mismatch', () {
      test('rejects exercise_count less than actual', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 0,'
            '"exercises": ['
            '${exerciseJson(id: 1)}'
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
              ExerciseDatasetValidationFailureCode.exerciseCountMismatch,
            ),
          ),
        );
      });
    });

    group('reject duplicate IDs', () {
      test('rejects duplicate exercise ids', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 2,'
            '"exercises": ['
            '${exerciseJson(id: 1)},'
            '${exerciseJson(id: 1)}'
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

      test('rejects invalid difficulty', () {
        expect(
          () => parser.parse(
            rawJson: validDataset(
              count: 1,
            ).replaceAll('"intermediate"', '"expert"'),
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

      test('rejects invalid modality', () {
        expect(
          () => parser.parse(
            rawJson: validDataset(
              count: 1,
            ).replaceAll('"strength"', '"unknown_modality"'),
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

      test('rejects unknown muscle group bucket', () {
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
            '"muscle_groups": ["Spine"],'
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

      test('rejects empty steps', () {
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
              ExerciseDatasetValidationFailureCode.invalidSteps,
            ),
          ),
        );
      });

      test('rejects empty primary_muscles', () {
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
              ExerciseDatasetValidationFailureCode.invalidPrimaryMuscles,
            ),
          ),
        );
      });
    });

    group('reject invalid video', () {
      test('rejects invalid video url', () {
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
            '"url": "not-a-valid-url",'
            '"angle": "front",'
            '"gender": "male"'
            '}'
            ']'
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

      test('allows nullable equipment for non-strength modality', () {
        final json =
            '{'
            '"schema_version": 1,'
            '"generated_at": "2024-01-01T00:00:00.000Z",'
            '"source": "musclewiki",'
            '"exercise_count": 1,'
            '"exercises": ['
            '{'
            '"id": 1,'
            '"name": "Stretch",'
            '"difficulty": "beginner",'
            '"primary_muscles": ["Back"],'
            '"muscle_groups": ["Back"],'
            '"modality": "flexibility",'
            '"grips": [],'
            '"steps": ["Reach forward"],'
            '"videos": []'
            '}'
            ']'
            '}';
        final dataset = parser.parse(
          rawJson: json,
          supportedSchemaVersion: 1,
          minimumSupportedAppSchemaVersion: 1,
        );

        expect(dataset.exercises[0].equipment, isNull);
      });

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

    test('accepts empty videos list', () {
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

String exerciseJson({
  int id = 1,
  String difficulty = 'intermediate',
  String modality = 'strength',
  String? equipment = 'barbell',
  List<String>? muscleGroups,
}) {
  return '''
{
  "id": $id,
  "name": "Bench Press",
  "difficulty": "$difficulty",
  "primary_muscles": ["Chest"],
  "muscle_groups": ${jsonList(muscleGroups ?? ['Chest', 'Triceps'])},
  "category": "compound",
  "modality": "$modality",
  "equipment": ${equipment != null ? '"$equipment"' : null},
  "force": "push",
  "mechanic": "compound",
  "grips": ["barbell"],
  "steps": ["Lie on bench", "Press bar"],
  "videos": [
    {
      "url": "https://example.com/video.mp4",
      "angle": "front",
      "gender": "male",
      "og_image": "https://example.com/thumb.jpg"
    }
  ]
}
''';
}

String jsonList(List<String> items) {
  return '[${items.map((s) => '"$s"').join(',')}]';
}
