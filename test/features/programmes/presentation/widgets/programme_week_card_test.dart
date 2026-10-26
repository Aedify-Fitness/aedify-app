import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: widget)),
  );
}

class _CardFixtures {
  static const week = ProgrammeBuilderWeekDraft(
    id: 'week',
    weekNumber: 1,
    slots: [
      ProgrammeBuilderWorkoutSlotDraft(
        slotIndex: 0,
        scheduledDayIndex: 0,
        template: ProgrammeBuilderTemplateDraft(
          id: 'upper',
          templateKey: 'upper',
          name: 'Hypertrophy Upper A',
          estimatedDurationMinutes: 75,
          exercises: [
            ProgrammeExerciseDraft(
              id: 'shrugs',
              exerciseId: 1,
              sortOrder: 0,
              exerciseRef: 'Standing Barbell Shrugs',
              sets: [
                SetPrescriptionDraft(
                  id: 'warmup',
                  setIndex: 0,
                  setType: SetType.warmup,
                  prescribedRepsExact: 15,
                ),
                SetPrescriptionDraft(
                  id: 'working',
                  setIndex: 1,
                  setType: SetType.working,
                  prescribedRepsMin: 8,
                  prescribedRepsMax: 12,
                  prescribedRpeMin: 8.5,
                  prescribedRpeMax: 9.5,
                  restSeconds: 90,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

void main() {
  group('ProgrammeWeekCard', () {
    testWidgets(
      'supplied workout card shows real summaries and connects edit/add actions',
      (tester) async {
        String? edited;
        int? added;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              AppProviders.exerciseDetailControllerProvider.overrideWith(
                (ref, id) async => null,
              ),
            ],
            child: _wrap(
              ProgrammeWeekCard(
                week: _CardFixtures.week,
                weekIndex: 0,
                onAddSlot: () {},
                onRemoveSlot: (_) {},
                onAssignTemplate: (_) {},
                onDuplicate: () {},
                onRemove: () {},
                onAddExercises: (slot) => added = slot,
                onEditExercise: (slot, exercise) => edited = '$slot:$exercise',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Hypertrophy Upper A'), findsOneWidget);
        expect(find.text('1 Exercise • Estimated 75 mins'), findsOneWidget);
        expect(find.text('Standing Barbell Shrugs'), findsOneWidget);
        expect(find.text('2 sets'), findsOneWidget);
        expect(find.text('8-12 Reps'), findsOneWidget);
        expect(find.text('RPE 8.5-9.5'), findsOneWidget);
        expect(find.text('90s Rest'), findsOneWidget);
        await tester.tap(find.bySemanticsLabel(AppStrings.editExercise));
        expect(edited, '0:shrugs');
        await tester.tap(find.text(AppStrings.addExercise));
        expect(added, 0);
        expect(tester.takeException(), isNull);
      },
    );

    for (final dark in [false, true]) {
      testWidgets(
        'mobile workout rows fit 320px with large text in ${dark ? 'dark' : 'light'} mode',
        (tester) async {
          tester.view.physicalSize = const Size(320, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                AppProviders.exerciseDetailControllerProvider.overrideWith(
                  (ref, id) async => null,
                ),
              ],
              child: MaterialApp(
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: ProgrammeWeekCard(
                      week: _CardFixtures.week,
                      weekIndex: 0,
                      onAddSlot: () {},
                      onRemoveSlot: (_) {},
                      onAssignTemplate: (_) {},
                      onDuplicate: () {},
                      onRemove: () {},
                      onAddExercises: (_) {},
                      onEditExercise: (_, _) {},
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Standing Barbell Shrugs'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.text(AppStrings.addExercise));
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('displays week number', (tester) async {
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 3,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 2,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () {},
          ),
        ),
      );

      expect(find.text('${AppStrings.weekLabelPrefix} 3'), findsOneWidget);
    });

    testWidgets('shows add workout slot button', (tester) async {
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () {},
          ),
        ),
      );

      expect(find.text(AppStrings.addWorkoutSlot), findsOneWidget);
    });

    testWidgets('displays slot cards for each slot', (tester) async {
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [
          ProgrammeBuilderWorkoutSlotDraft(
            slotIndex: 0,
            scheduledDayIndex: 0,
            template: ProgrammeBuilderTemplateDraft(
              id: 't-1',
              templateKey: 't-1',
              name: 'Push Day',
            ),
          ),
          ProgrammeBuilderWorkoutSlotDraft(slotIndex: 1, scheduledDayIndex: 1),
        ],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () {},
          ),
        ),
      );

      expect(find.text('Push Day'), findsOneWidget);
      expect(find.text(AppStrings.weekTemplateEmpty), findsOneWidget);
    });

    testWidgets('calls onDuplicate when duplicate button is tapped', (
      tester,
    ) async {
      bool duplicated = false;
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () => duplicated = true,
            onRemove: () {},
          ),
        ),
      );

      await tester.tap(find.byTooltip(AppStrings.duplicateWeek));
      expect(duplicated, isTrue);
    });

    testWidgets('calls onRemove when remove button is tapped', (tester) async {
      bool removed = false;
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () => removed = true,
          ),
        ),
      );

      await tester.tap(find.byTooltip(AppStrings.removeWeek));
      expect(removed, isTrue);
    });

    testWidgets('calls onAddSlot when add slot button is tapped', (
      tester,
    ) async {
      bool added = false;
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () => added = true,
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () {},
          ),
        ),
      );

      await tester.tap(find.text(AppStrings.addWorkoutSlot));
      expect(added, isTrue);
    });

    testWidgets('collapsed week keeps day and workout summary visible', (
      tester,
    ) async {
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [
          ProgrammeBuilderWorkoutSlotDraft(
            slotIndex: 0,
            scheduledDayIndex: 0,
            template: ProgrammeBuilderTemplateDraft(
              id: 't-1',
              templateKey: 't-1',
              name: 'Push Day',
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () {},
          ),
        ),
      );

      await tester.tap(find.text('${AppStrings.weekLabelPrefix} 1'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Push Day'), findsOneWidget);
      expect(
        find.textContaining(AppStrings.onboardingDaySingle),
        findsOneWidget,
      );
    });
  });
}
