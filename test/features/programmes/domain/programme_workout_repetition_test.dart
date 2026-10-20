import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/features/programmes/domain/programme_workout_repetition.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fixtures {
  _Fixtures._();
  static ProgrammeBuilderTemplateDraft workout(String id) =>
      ProgrammeBuilderTemplateDraft(
        id: id,
        templateKey: id,
        name: 'Push',
        exercises: [
          for (var i = 0; i < 2; i++)
            ProgrammeExerciseDraft(
              id: '$id-ex-$i',
              exerciseId: i,
              sortOrder: i,
              supersetGroupId: '$id-group',
              supersetOrder: i,
              sets: [
                SetPrescriptionDraft(
                  id: '$id-set-$i',
                  setIndex: 0,
                  setType: SetType.working,
                  prescribedRepsExact: 8,
                  prescribedWeightKg: 30,
                  restSeconds: 60,
                ),
              ],
            ),
        ],
      );

  static ProgrammeBuilderDraft draft(
    ProgrammeBuilderTemplateDraft? second, {
    int secondDay = 0,
  }) => ProgrammeBuilderDraft(
    id: 'programme',
    name: 'Plan',
    source: WorkoutSource.manual,
    creationMethod: CreationMethod.manual,
    status: ProgramStatus.draft,
    trainingBlocks: const [
      ProgrammeTrainingBlockDraft(id: 'first', name: 'Base', weekCount: 2),
      ProgrammeTrainingBlockDraft(id: 'other', name: 'Peak', weekCount: 1),
    ],
    weeks: [
      ProgrammeBuilderWeekDraft(
        id: 'one',
        weekNumber: 1,
        slots: [
          ProgrammeBuilderWorkoutSlotDraft(
            slotIndex: 0,
            scheduledDayIndex: 0,
            template: workout('one'),
          ),
        ],
      ),
      ProgrammeBuilderWeekDraft(
        id: 'two',
        weekNumber: 2,
        slots: [
          ProgrammeBuilderWorkoutSlotDraft(
            slotIndex: 0,
            scheduledDayIndex: secondDay,
            template: second,
          ),
        ],
      ),
      const ProgrammeBuilderWeekDraft(id: 'other', weekNumber: 3, slots: []),
    ],
  );
}

void main() {
  test(
    'independent IDs and copied superset IDs match within the selected block',
    () {
      final draft = _Fixtures.draft(_Fixtures.workout('copy'));
      expect(ProgrammeWorkoutRepetition.repeatedSlots(draft, 0), {0});
      expect(ProgrammeWorkoutRepetition.repeatedSlots(draft, 1), {0});
      expect(ProgrammeWorkoutRepetition.repeatedSlots(draft, 2), isEmpty);
      expect(ProgrammeWorkoutRepetition.repeatedSlots(draft, -1), isEmpty);
    },
  );

  test('missing assignments or a different weekday are not repeated', () {
    expect(
      ProgrammeWorkoutRepetition.repeatedSlots(_Fixtures.draft(null), 0),
      isEmpty,
    );
    expect(
      ProgrammeWorkoutRepetition.repeatedSlots(
        _Fixtures.draft(_Fixtures.workout('copy'), secondDay: 1),
        0,
      ),
      isEmpty,
    );
  });

  test(
    'custom targets, notes or superset structure make the repeat action available again',
    () {
      final copy = _Fixtures.workout('copy');
      final exercise = copy.exercises.first;
      for (final changed in [
        exercise.copyWith(
          sets: [exercise.sets.single.copyWith(prescribedWeightKg: 40.0)],
        ),
        exercise.copyWith(
          sets: [exercise.sets.single.copyWith(restSeconds: 90)],
        ),
        exercise.copyWith(notes: 'Controlled tempo'),
        exercise.copyWith(supersetGroupId: 'different-group'),
      ]) {
        final draft = _Fixtures.draft(
          copy.copyWith(exercises: [changed, copy.exercises.last]),
        );
        expect(ProgrammeWorkoutRepetition.repeatedSlots(draft, 0), isEmpty);
      }
    },
  );
}
