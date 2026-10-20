import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/features/programmes/application/programme_builder_step_validator.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fixtures {
  _Fixtures._();

  static ProgrammeBuilderDraft draft(List<ProgrammeBuilderWeekDraft>? weeks) =>
      ProgrammeBuilderDraft(
        id: 'programme',
        name: 'Programme',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: ProgramStatus.draft,
        weeks: weeks,
      );

  static const assigned = ProgrammeBuilderWorkoutSlotDraft(
    slotIndex: 0,
    scheduledDayIndex: 0,
    template: ProgrammeBuilderTemplateDraft(
      id: 'workout',
      templateKey: 'workout',
      name: 'Workout',
    ),
  );
  static const unassigned = ProgrammeBuilderWorkoutSlotDraft(
    slotIndex: 1,
    scheduledDayIndex: 2,
  );
}

void main() {
  test(
    'blocks require names, positive lengths and full programme coverage',
    () {
      final draft = _Fixtures.draft(const [
        ProgrammeBuilderWeekDraft(id: 'week', weekNumber: 1),
      ]);
      expect(
        ProgrammeBuilderStepValidator.blocks(draft).single.code,
        AppErrorCodes.noTrainingBlocks,
      );
      final block = ProgrammeTrainingBlockDraft(
        id: 'block',
        name: ' ',
        weekCount: 0,
      );
      expect(
        ProgrammeBuilderStepValidator.blocks(
          draft.copyWith(trainingBlocks: [block]),
        ),
        hasLength(2),
      );
      expect(
        ProgrammeBuilderStepValidator.blocks(
          draft.copyWith(
            trainingBlocks: [block.copyWith(name: 'Base', weekCount: 2)],
          ),
        ),
        hasLength(1),
      );
      expect(
        ProgrammeBuilderStepValidator.blocks(
          draft.copyWith(
            trainingBlocks: [block.copyWith(name: 'Base', weekCount: 1)],
          ),
        ),
        isEmpty,
      );
    },
  );

  for (final weeks in [null, <ProgrammeBuilderWeekDraft>[]]) {
    test('schedule and review require a week when weeks=$weeks', () {
      final draft = _Fixtures.draft(weeks);
      expect(
        ProgrammeBuilderStepValidator.schedule(draft).single.code,
        AppErrorCodes.noWeeks,
      );
      expect(
        ProgrammeBuilderStepValidator.workouts(draft).single.code,
        AppErrorCodes.noWeeks,
      );
    });
  }

  for (final slots in [null, <ProgrammeBuilderWorkoutSlotDraft>[]]) {
    test('each week requires a workout day when slots=$slots', () {
      final draft = _Fixtures.draft([
        const ProgrammeBuilderWeekDraft(
          id: 'first',
          weekNumber: 1,
          slots: [_Fixtures.assigned],
        ),
        ProgrammeBuilderWeekDraft(id: 'second', weekNumber: 2, slots: slots),
      ]);
      final error = ProgrammeBuilderStepValidator.schedule(draft).single;
      expect(error.code, AppErrorCodes.noSlots);
      expect(error.weekIndex, 1);
      expect(
        ProgrammeBuilderStepValidator.workouts(draft).single.code,
        AppErrorCodes.noSlots,
      );
    });
  }

  test('schedule allows days to be unassigned until Training Blocks', () {
    final draft = _Fixtures.draft([
      const ProgrammeBuilderWeekDraft(
        id: 'week',
        weekNumber: 1,
        slots: [_Fixtures.unassigned],
      ),
    ]);
    expect(ProgrammeBuilderStepValidator.schedule(draft), isEmpty);
    final error = ProgrammeBuilderStepValidator.workouts(draft).single;
    expect(error.code, AppErrorCodes.missingTemplate);
    expect(error.weekIndex, 0);
    expect(error.slotIndex, 1);
  });

  test('review checks every day across every week', () {
    final draft = _Fixtures.draft([
      const ProgrammeBuilderWeekDraft(
        id: 'first',
        weekNumber: 1,
        slots: [_Fixtures.assigned],
      ),
      const ProgrammeBuilderWeekDraft(
        id: 'second',
        weekNumber: 2,
        slots: [_Fixtures.assigned, _Fixtures.unassigned],
      ),
    ]);
    final errors = ProgrammeBuilderStepValidator.workouts(draft);
    expect(errors, hasLength(1));
    expect(errors.single.weekIndex, 1);
    expect(errors.single.slotIndex, 1);
  });

  test('all weeks and assignments allow both transitions', () {
    final draft = _Fixtures.draft([
      const ProgrammeBuilderWeekDraft(
        id: 'first',
        weekNumber: 1,
        slots: [_Fixtures.assigned],
      ),
      const ProgrammeBuilderWeekDraft(
        id: 'second',
        weekNumber: 2,
        slots: [_Fixtures.assigned],
      ),
    ]);
    expect(ProgrammeBuilderStepValidator.schedule(draft), isEmpty);
    expect(ProgrammeBuilderStepValidator.workouts(draft), isEmpty);
  });
}
