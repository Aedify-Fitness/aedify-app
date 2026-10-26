import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/application/programme_review_summary.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_review.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Harness {
  _Harness._();

  static const draft = ProgrammeBuilderDraft(
    id: 'programme',
    name: 'Advanced Power Building',
    source: WorkoutSource.manual,
    creationMethod: CreationMethod.manual,
    status: ProgramStatus.inactive,
    trainingBlocks: [
      ProgrammeTrainingBlockDraft(
        id: 'block',
        name: 'Foundation',
        weekCount: 1,
        progressionNotes: 'Add reps with controlled form.',
      ),
    ],
    weeks: [
      ProgrammeBuilderWeekDraft(
        id: 'week',
        weekNumber: 1,
        slots: [
          ProgrammeBuilderWorkoutSlotDraft(
            slotIndex: 0,
            scheduledDayIndex: 0,
            template: ProgrammeBuilderTemplateDraft(
              id: 'workout',
              templateKey: 'workout',
              name: 'Push',
              exercises: [
                ProgrammeExerciseDraft(
                  id: 'exercise',
                  exerciseId: 1,
                  sortOrder: 0,
                  exerciseRef: 'Bench Press',
                  sets: [
                    SetPrescriptionDraft(
                      id: 'set',
                      setIndex: 0,
                      setType: SetType.working,
                      prescribedRpeMin: 7,
                      prescribedRpeMax: 9,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );

  static ProgrammeBuilderDraft withRir() {
    final week = draft.weeks!.single;
    final slot = week.slots!.single;
    final template = slot.template!;
    final exercise = template.exercises.single;
    return draft.copyWith(
      weeks: [
        week.copyWith(
          slots: [
            slot.copyWith(
              template: template.copyWith(
                exercises: [
                  exercise.copyWith(
                    sets: [
                      exercise.sets.single.copyWith(
                        prescribedRpeMin: null,
                        prescribedRpeMax: null,
                        prescribedRir: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget wrap({
    bool dark = false,
    double scale = 1,
    ProgrammeBuilderDraft programme = draft,
  }) {
    return MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: ProgrammeBuilderReview(
              draft: programme,
              summary: ProgrammeReviewSummary.fromDraft(programme),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'summary badge uses the first programme goal instead of block focus',
    (tester) async {
      await tester.pumpWidget(
        _Harness.wrap(
          programme: _Harness.draft.copyWith(
            goalTags: {GoalTag.increaseStrength, GoalTag.buildMuscle},
          ),
        ),
      );
      expect(find.text(AppStrings.strengthGoal.toUpperCase()), findsOneWidget);
      expect(
        find.text(AppStrings.programmeReviewPhase('Base').toUpperCase()),
        findsNothing,
      );
    },
  );

  testWidgets(
    'review renders actual summary, phase, publication and workload data',
    (tester) async {
      await tester.pumpWidget(_Harness.wrap());
      await tester.pumpAndSettle();
      expect(find.text(_Harness.draft.name), findsOneWidget);
      expect(
        find.text(AppStrings.programmeReviewPhaseName(1, 'Foundation')),
        findsOneWidget,
      );
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text(AppStrings.programmePrivateLocal), findsOneWidget);
      expect(find.text('8.0'), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget);
      expect(
        find.text(AppStrings.programmeReviewBusiestWeek(1)),
        findsOneWidget,
      );
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).bottomNavigationBar,
        isNull,
      );
      expect(find.byType(Image), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      final bars = tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .toList();
      expect(bars.map((bar) => bar.value), [0.8, 1.0]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('RIR-only targets show estimated RPE and explain the fallback', (
    tester,
  ) async {
    await tester.pumpWidget(_Harness.wrap(programme: _Harness.withRir()));
    await tester.pumpAndSettle();
    expect(find.text('8.0'), findsOneWidget);
    expect(find.text(AppStrings.programmeTargetsNotSet), findsNothing);
    expect(find.text(AppStrings.programmeAverageEstimatedRpe), findsOneWidget);
    expect(
      find.text(AppStrings.programmeRpeIncludesRirEstimates),
      findsOneWidget,
    );
    expect(find.text(AppStrings.programmeRirEstimateHint), findsOneWidget);
    final bar = tester
        .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .first;
    expect(bar.value, 0.8);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unset targets show honest empty values', (tester) async {
    await tester.pumpWidget(
      _Harness.wrap(programme: _Harness.draft.copyWith(weeks: [])),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.programmeTargetsNotSet), findsNWidgets(2));
    final bars = tester.widgetList<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bars.every((bar) => bar.value == 0), isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'mobile review scrolls with reachable publication and workload: dark=$dark scale=$scale',
        (tester) async {
          tester.view.physicalSize = const Size(320, 844);
          tester.view.devicePixelRatio = 1;
          tester.view.padding = const FakeViewPadding(bottom: 34);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPadding);
          await tester.pumpWidget(_Harness.wrap(dark: dark, scale: scale));
          await tester.pumpAndSettle();
          final workload = find.text(AppStrings.programmeReviewBusiestWeek(1));
          await tester.ensureVisible(workload);
          await tester.pumpAndSettle();
          expect(
            tester.getBottomLeft(workload).dy,
            lessThanOrEqualTo(844 - 34),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
