import 'package:aedify/features/programmes/application/programme_review_summary.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fixtures {
  _Fixtures._();
  static ProgrammeBuilderDraft draft() => ProgrammeBuilderDraft(
    id: 'programme',
    name: 'Strength plan',
    source: WorkoutSource.manual,
    creationMethod: CreationMethod.manual,
    status: ProgramStatus.inactive,
    trainingBlocks: const [
      ProgrammeTrainingBlockDraft(id: 'base', name: 'Foundation', weekCount: 1),
      ProgrammeTrainingBlockDraft(id: 'volume', name: 'Volume', weekCount: 1),
    ],
    weeks: [
      ProgrammeBuilderWeekDraft(
        id: 'week-1',
        weekNumber: 1,
        slots: [
          slot(0, 1, 'Bench Press', const [
            SetPrescriptionDraft(
              id: 'warmup',
              setIndex: 0,
              setType: SetType.warmup,
              prescribedRpeMin: 1,
            ),
            SetPrescriptionDraft(
              id: 'working',
              setIndex: 1,
              setType: SetType.working,
              prescribedRpeMin: 7,
              prescribedRpeMax: 9,
            ),
          ]),
        ],
      ),
      ProgrammeBuilderWeekDraft(
        id: 'week-2',
        weekNumber: 2,
        weekType: WeekType.deload,
        slots: [
          slot(0, 1, 'Bench Press', const [
            SetPrescriptionDraft(
              id: 'legacy',
              setIndex: 0,
              setType: SetType.working,
              rpeMax: 6,
            ),
          ]),
          slot(4, 2, 'Row', const [
            SetPrescriptionDraft(
              id: 'min-only',
              setIndex: 0,
              setType: SetType.working,
              prescribedRpeMin: 9,
            ),
          ]),
        ],
      ),
    ],
  );

  static ProgrammeReviewSummary summaryFor(List<SetPrescriptionDraft> sets) =>
      ProgrammeReviewSummary.fromDraft(
        draft().copyWith(
          weeks: [
            ProgrammeBuilderWeekDraft(
              id: 'rir-week',
              weekNumber: 1,
              slots: [slot(0, 1, 'Bench', sets)],
            ),
          ],
        ),
      );

  static SetPrescriptionDraft working({
    int? rir,
    double? rpe,
    double? legacyRpe,
  }) => SetPrescriptionDraft(
    id: 'set',
    setIndex: 0,
    setType: SetType.working,
    prescribedRir: rir,
    prescribedRpeMin: rpe,
    rpeMax: legacyRpe,
  );

  static ProgrammeBuilderWorkoutSlotDraft slot(
    int day,
    int exerciseId,
    String name,
    List<SetPrescriptionDraft> sets,
  ) => ProgrammeBuilderWorkoutSlotDraft(
    slotIndex: day,
    scheduledDayIndex: day,
    template: ProgrammeBuilderTemplateDraft(
      id: 'workout-$day-$exerciseId',
      templateKey: 'workout-$day-$exerciseId',
      name: 'Workout',
      exercises: [
        ProgrammeExerciseDraft(
          id: 'exercise-$day-$exerciseId',
          exerciseId: exerciseId,
          sortOrder: 0,
          exerciseRef: name,
          sets: sets,
        ),
      ],
    ),
  );
}

void main() {
  test(
    'badge uses first selected programme goal then the first workout goal',
    () {
      final original = _Fixtures.draft();
      final week = original.weeks!.first;
      final slot = week.slots!.first;
      final draft = original.copyWith(
        weeks: [
          week.copyWith(
            slots: [
              slot.copyWith(
                template: slot.template!.copyWith(goalTags: ['Workout goal']),
              ),
            ],
          ),
        ],
      );
      expect(
        ProgrammeReviewSummary.fromDraft(
          draft.copyWith(
            goalTags: {GoalTag.increaseStrength, GoalTag.buildMuscle},
          ),
        ).goalLabel,
        AppStrings.strengthGoal,
      );
      expect(
        ProgrammeReviewSummary.fromDraft(
          draft.copyWith(goalTags: {GoalTag.buildMuscle}),
        ).goalLabel,
        AppStrings.hypertrophyGoal,
      );
      expect(
        ProgrammeReviewSummary.fromDraft(
          draft.copyWith(goalTags: {}),
        ).goalLabel,
        'Workout goal',
      );
      expect(ProgrammeReviewSummary.fromDraft(original).goalLabel, isNull);
    },
  );

  test(
    'RIR estimates fill missing RPE without replacing explicit or legacy targets',
    () {
      final sets = [
        _Fixtures.working(rir: 2),
        _Fixtures.working(rir: 0),
        _Fixtures.working(rir: 4, rpe: 9),
        _Fixtures.working(rir: 4, legacyRpe: 7),
        _Fixtures.working(),
        const SetPrescriptionDraft(
          id: 'warmup',
          setIndex: 0,
          setType: SetType.warmup,
          prescribedRir: 9,
        ),
      ];
      final summary = _Fixtures.summaryFor(sets);
      expect(summary.averageTargetRpe, 8.5);
      expect(summary.hasRirEstimates, isTrue);
      expect(summary.averageWeeklySets, 5);
      expect(sets.first.prescribedRir, 2);
      expect(sets.first.prescribedRpeMin, isNull);
    },
  );

  test('RIR conversion respects scale bounds and skips invalid negatives', () {
    for (final rir in [0, 1, 2, 3, 9, 10, 20]) {
      final summary = _Fixtures.summaryFor([_Fixtures.working(rir: rir)]);
      expect(summary.averageTargetRpe, (10 - rir).clamp(1, 10));
      expect(summary.hasRirEstimates, isTrue);
    }
    final invalid = _Fixtures.summaryFor([_Fixtures.working(rir: -1)]);
    expect(invalid.averageTargetRpe, isNull);
    expect(invalid.hasRirEstimates, isFalse);
  });

  test('RIR estimates only count when used on working sets', () {
    final summary = _Fixtures.summaryFor([
      _Fixtures.working(rir: 4, rpe: 9),
      _Fixtures.working(rir: 4, legacyRpe: 7),
      const SetPrescriptionDraft(
        id: 'warmup',
        setIndex: 0,
        setType: SetType.warmup,
        prescribedRir: 2,
      ),
    ]);
    expect(summary.averageTargetRpe, 8);
    expect(summary.hasRirEstimates, isFalse);
  });

  test(
    'summary counts actual days, unique exercises and working sets across weeks',
    () {
      final summary = ProgrammeReviewSummary.fromDraft(_Fixtures.draft());
      expect(summary.weekCount, 2);
      expect(summary.minDaysPerWeek, 1);
      expect(summary.maxDaysPerWeek, 2);
      expect(summary.uniqueExerciseCount, 2);
      expect(summary.averageWeeklySets, 1.5);
      expect(summary.maxWeeklySets, 2);
      expect(summary.averageTargetRpe, closeTo(23 / 3, 0.0001));
      expect(summary.hasRirEstimates, isFalse);
      expect(summary.deloadWeekCount, 1);
      expect(summary.blocks.first.firstWeek, 1);
      expect(summary.blocks.first.lastWeek, 1);
      expect(summary.blocks.last.firstWeek, 2);
      expect(summary.blocks.last.lastWeek, 2);
      expect(summary.blocks.last.exerciseNames, ['Bench Press', 'Row']);
    },
  );

  test(
    'missing RPE targets stay unset and zero-week drafts do not divide by zero',
    () {
      final draft = _Fixtures.draft().copyWith(weeks: [], trainingBlocks: []);
      final summary = ProgrammeReviewSummary.fromDraft(draft);
      expect(summary.weekCount, 0);
      expect(summary.minDaysPerWeek, 0);
      expect(summary.maxDaysPerWeek, 0);
      expect(summary.averageWeeklySets, 0);
      expect(summary.maxWeeklySets, 0);
      expect(summary.averageTargetRpe, isNull);
      final withSets = ProgrammeReviewSummary.fromDraft(
        draft.copyWith(
          weeks: [
            ProgrammeBuilderWeekDraft(
              id: 'week',
              weekNumber: 1,
              slots: [
                _Fixtures.slot(0, 1, 'Bench', const [
                  SetPrescriptionDraft(
                    id: 'set',
                    setIndex: 0,
                    setType: SetType.working,
                  ),
                ]),
              ],
            ),
          ],
        ),
      );
      expect(withSets.averageWeeklySets, 1);
      expect(withSets.averageTargetRpe, isNull);
    },
  );

  test(
    'block exercise previews deduplicate repeats and show the remaining count',
    () {
      final slots = [
        for (var i = 0; i < 5; i++)
          _Fixtures.slot(0, i, 'Exercise $i', const []),
      ];
      final summary = ProgrammeReviewSummary.fromDraft(
        _Fixtures.draft().copyWith(
          trainingBlocks: const [
            ProgrammeTrainingBlockDraft(
              id: 'block',
              name: 'Base',
              weekCount: 2,
            ),
          ],
          weeks: [
            for (var i = 1; i <= 2; i++)
              ProgrammeBuilderWeekDraft(
                id: 'week-$i',
                weekNumber: i,
                slots: slots,
              ),
          ],
        ),
      );
      expect(summary.uniqueExerciseCount, 5);
      expect(summary.minDaysPerWeek, 1);
      expect(summary.blocks.single.exerciseNames, [
        'Exercise 0',
        'Exercise 1',
        'Exercise 2',
      ]);
      expect(summary.blocks.single.remainingExercises, 2);
    },
  );
}
