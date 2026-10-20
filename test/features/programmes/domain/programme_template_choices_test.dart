import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/programme_template_choices.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fixtures {
  _Fixtures._();

  static ProgrammeBuilderTemplateDraft template(
    String id,
    List<int> exerciseIds, {
    String name = 'Push Day',
    int reps = 8,
  }) => ProgrammeBuilderTemplateDraft(
    id: id,
    templateKey: id,
    name: name,
    exercises: [
      for (var i = 0; i < exerciseIds.length; i++)
        ProgrammeExerciseDraft(
          id: '$id-exercise-$i',
          exerciseId: exerciseIds[i],
          sortOrder: i,
          sets: [
            SetPrescriptionDraft(
              id: '$id-set-$i',
              setIndex: 0,
              setType: SetType.working,
              prescribedRepsExact: reps,
            ),
          ],
        ),
    ],
  );
}

void main() {
  group('ProgrammeTemplateChoices', () {
    test(
      'collapses copied assignments with different row and template IDs',
      () {
        final first = _Fixtures.template('week-1', [1, 2]);
        final copy = _Fixtures.template('week-2', [1, 2]);
        final choices = ProgrammeTemplateChoices.distinctByExercises([
          first,
          copy,
          first,
        ]);
        expect(choices, hasLength(1));
        expect(choices.single, same(first));
      },
    );

    test('keeps the same name when the exercise collections differ', () {
      final first = _Fixtures.template('week-1', [1, 2]);
      final different = _Fixtures.template('week-2', [1, 3]);
      expect(ProgrammeTemplateChoices.distinctByExercises([first, different]), [
        first,
        different,
      ]);
    });

    test('ignores exercise order, names and prescription changes', () {
      final first = _Fixtures.template('week-1', [2, 1]);
      final changed = _Fixtures.template(
        'week-2',
        [1, 2],
        name: 'Upper Body',
        reps: 12,
      );
      expect(ProgrammeTemplateChoices.distinctByExercises([first, changed]), [
        first,
      ]);
      expect(first.exercises.map((exercise) => exercise.exerciseId), [2, 1]);
      expect(changed.exercises.first.sets.first.prescribedRepsExact, 12);
    });

    test('preserves different exercise multiplicities and choice order', () {
      final first = _Fixtures.template('week-1', [1, 2]);
      final repeated = _Fixtures.template('week-2', [1, 1, 2]);
      final repeatedCopy = _Fixtures.template('week-3', [2, 1, 1]);
      expect(
        ProgrammeTemplateChoices.distinctByExercises([
          first,
          repeated,
          repeatedCopy,
        ]),
        [first, repeated],
      );
    });

    test('handles empty sources and identical empty exercise collections', () {
      expect(ProgrammeTemplateChoices.distinctByExercises([]), isEmpty);
      final empty = _Fixtures.template('empty', []);
      expect(
        ProgrammeTemplateChoices.distinctByExercises([
          empty,
          _Fixtures.template('empty-copy', []),
          _Fixtures.template('different-name', [], name: 'Lower Body'),
        ]),
        [empty],
      );
    });
  });
}
