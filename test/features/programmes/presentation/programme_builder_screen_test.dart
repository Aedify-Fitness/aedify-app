import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/features/workout_builder/application/load_workout_draft_use_case.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/presentation/workout_builder_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/application/list_saved_workouts_use_case.dart';
import 'package:aedify/features/programmes/application/list_programmes_use_case.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/template_reassignment_bottom_sheet.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/features/programmes/application/load_programme_builder_draft_use_case.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/features/programmes/application/save_programme_builder_draft_use_case.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/presentation/programme_builder_screen.dart';
import 'package:aedify/shared/components/app_toggle_pill.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Fixtures {
  _Fixtures._();
  static ProgrammeBuilderDraft draft({bool assigned = false}) =>
      ProgrammeBuilderDraft(
        id: 'programme',
        name: assigned ? 'Training Programme' : '',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: ProgramStatus.inactive,
        goalTags: const {GoalTag.increaseStrength},
        templates: const [],
        trainingBlocks: assigned
            ? const [
                ProgrammeTrainingBlockDraft(
                  id: 'base-block',
                  name: 'Base',
                  weekCount: 1,
                ),
              ]
            : const [],
        weeks: assigned
            ? [
                const ProgrammeBuilderWeekDraft(
                  id: 'week',
                  weekNumber: 1,
                  slots: [
                    ProgrammeBuilderWorkoutSlotDraft(
                      slotIndex: 0,
                      scheduledDayIndex: 0,
                      scheduledDay: TrainingDay.monday,
                      template: ProgrammeBuilderTemplateDraft(
                        id: 'push',
                        templateKey: 'push',
                        name: 'Push Day',
                        exercises: [
                          ProgrammeExerciseDraft(
                            id: 'exercise',
                            exerciseId: 1,
                            sortOrder: 0,
                            sets: [
                              SetPrescriptionDraft(
                                id: 'set',
                                setIndex: 0,
                                setType: SetType.working,
                                prescribedRepsExact: 8,
                                prescribedWeightKg: 30,
                                restSeconds: 60,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : [],
      );
  static ProgrammeBuilderDraft workouts() {
    final draft = _Fixtures.draft(assigned: true);
    final base = draft.weeks!.first.slots!.first.template!;
    final push = base.copyWith(
      exercises: [
        base.exercises.first.copyWith(exerciseRef: 'Bench Press'),
        base.exercises.first.copyWith(
          id: 'fly',
          exerciseId: 2,
          exerciseRef: 'Cable Fly',
          sortOrder: 1,
        ),
      ],
    );
    final pull = base.copyWith(
      id: 'pull',
      templateKey: 'pull',
      name: 'Pull Day',
      exercises: [
        base.exercises.first.copyWith(
          id: 'row',
          exerciseId: 3,
          exerciseRef: 'Cable Row',
        ),
      ],
    );
    return draft.copyWith(
      weeks: [
        draft.weeks!.first.copyWith(
          slots: [
            draft.weeks!.first.slots!.first.copyWith(template: push),
            ProgrammeBuilderWorkoutSlotDraft(
              slotIndex: 1,
              scheduledDayIndex: 2,
              scheduledDay: TrainingDay.wednesday,
              template: pull,
            ),
          ],
        ),
      ],
    );
  }
}

class _Load implements LoadProgrammeBuilderDraftUseCase {
  _Load(this.draft);
  final ProgrammeBuilderDraft draft;
  @override
  Future<ProgrammeBuilderDraft> createEmptyDraft() async => draft;
  @override
  Future<ProgrammeBuilderDraft> loadForEdit(String id) async => draft;
  @override
  Future<ProgrammeBuilderDraft> loadDuplicate(String id) async => draft;
}

class _Save implements SaveProgrammeBuilderDraftUseCase {
  int calls = 0;
  bool shouldThrow = false;
  ProgrammeBuilderDraft? lastDraft;
  @override
  Future<String> save(ProgrammeBuilderDraft draft) async {
    calls++;
    lastDraft = draft;
    if (shouldThrow) throw StateError('Save failed');
    return draft.id;
  }
}

class _Workouts implements ListSavedWorkoutsUseCase {
  @override
  Future<List<SavedWorkoutListItem>> execute() async => [];
}

class _Programmes implements ListProgrammesUseCase {
  @override
  Future<List<ProgrammeListItem>> execute() async => [];
}

class _ProgrammeWorkoutRepository implements SavedWorkoutRepository {
  int saveCalls = 0;
  @override
  Future<SavedWorkoutAggregate?> getSavedWorkout(String id) async => null;
  @override
  Future<List<SavedWorkoutAggregate>> listSavedWorkouts({
    String? status,
  }) async => [];
  @override
  Future<String> saveSavedWorkout(SavedWorkoutDraft draft) async {
    saveCalls++;
    return 'unexpected-library-save';
  }

  @override
  Future<void> archiveSavedWorkout(String id) async {}
  @override
  Future<void> deleteSavedWorkout(String id) async {}
}

class _Harness {
  _Harness({ProgrammeBuilderDraft? draft, this.dark = false, this.scale = 1})
    : load = _Load(draft ?? _Fixtures.draft());
  final _Load load;
  final save = _Save();
  final workouts = _ProgrammeWorkoutRepository();
  final bool dark;
  final double scale;
  late final router = GoRouter(
    initialLocation: '/builder',
    routes: [
      GoRoute(
        path: AppRoutes.programmeWorkoutBuilderCreate().path,
        name: AppRoutes.programmeWorkoutBuilderCreate().name,
        builder: (_, _) => const WorkoutBuilderScreen.programmeTemplate(),
      ),
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Library')),
        routes: [
          GoRoute(
            path: 'builder',
            builder: (_, _) => ProgrammeBuilderScreen.create(),
          ),
        ],
      ),
    ],
  );
  Widget app() => ProviderScope(
    overrides: [
      AppProviders.savedWorkoutRepositoryProvider.overrideWithValue(workouts),
      AppProviders.loadWorkoutDraftUseCaseProvider.overrideWithValue(
        LoadWorkoutDraftUseCase(savedWorkoutRepository: workouts),
      ),
      AppProviders.exerciseDetailControllerProvider.overrideWith(
        (ref, id) async => null,
      ),
      AppProviders.listSavedWorkoutsUseCaseProvider.overrideWithValue(
        _Workouts(),
      ),
      AppProviders.listProgrammesUseCaseProvider.overrideWithValue(
        _Programmes(),
      ),
      AppProviders.loadProgrammeBuilderDraftUseCaseProvider.overrideWithValue(
        load,
      ),
      AppProviders.saveProgrammeBuilderDraftUseCaseProvider.overrideWithValue(
        save,
      ),
    ],
    child: MaterialApp.router(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
    ),
  );
  static const argument = (
    mode: ProgrammeBuilderMode.create,
    programmeId: null,
  );
  ProviderContainer container(WidgetTester tester) => ProviderScope.containerOf(
    tester.element(find.byType(ProgrammeBuilderScreen)),
  );
  ProgrammeBuilderDraft current(WidgetTester tester) => container(tester)
      .read(AppProviders.programmeBuilderControllerProvider(argument))
      .requireValue
      .draft;
}

class _Driver {
  _Driver._();
  static void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  static Future<void> load(WidgetTester tester, _Harness harness) async {
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
  }

  static Future<void> createTemplateFromMonday(WidgetTester tester) async {
    final assignment = find.widgetWithText(OutlinedButton, 'Push Day');
    if (assignment.evaluate().isEmpty) {
      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(assignment);
    await tester.tap(assignment);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(TemplateReassignmentBottomSheet),
        matching: find.text(AppStrings.createTemplate),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutBuilderScreen), findsOneWidget);
  }

  static Future<void> authorProgrammeWorkout(
    WidgetTester tester,
    String name,
  ) async {
    await tester.enterText(
      find.widgetWithText(TextField, AppStrings.workoutNameHint),
      name,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorkoutBuilderScreen)),
    );
    final provider = AppProviders.workoutBuilderControllerProvider((
      mode: WorkoutBuilderMode.programmeTemplate,
      savedWorkoutId: null,
    ));
    final controller = container.read(provider.notifier);
    await controller.addExercise(
      const ExerciseReference(
        exerciseId: 100,
        name: 'Cable Row',
        modality: 'strength',
      ),
    );
    final exercise = container
        .read(provider)
        .requireValue
        .draft
        .exercises
        .single;
    final set = exercise.sets.single;
    await controller.updateSet(
      exerciseDraftId: exercise.id,
      setId: set.id,
      prescription: set.copyWith(
        prescribedRepsExact: 12,
        prescribedWeightKg: 25,
        restSeconds: 90,
      ),
    );
    await controller.updateExerciseNotes(exercise.id, 'Smooth repetitions');
    await tester.pumpAndSettle();
  }

  static Future<void> saveTemplate(WidgetTester tester) async {
    final save = find.text(AppStrings.saveTemplate);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
  }

  static Future<void> openSchedule(WidgetTester tester) async {
    await next(tester);
    await next(tester);
  }

  static Future<void> openWorkouts(WidgetTester tester) async {
    await openSchedule(tester);
    await next(tester);
  }

  static Future<void> next(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('programme_builder_next')));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets(
    'day-card repetition confirms once and hides when the weekday matches across the block',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final original = _Fixtures.draft(assigned: true);
      final week = original.weeks!.single;
      final other = week.slots!.single.copyWith(
        template: week.slots!.single.template!.copyWith(
          name: 'Different workout',
        ),
      );
      final harness = _Harness(
        draft: original.copyWith(
          trainingBlocks: const [
            ProgrammeTrainingBlockDraft(id: 'base', name: 'Base', weekCount: 2),
          ],
          weeks: [
            week,
            week.copyWith(id: 'week-2', weekNumber: 2, slots: [other]),
          ],
        ),
      );
      await _Driver.load(tester, harness);
      await _Driver.openSchedule(tester);
      final monday = find.byKey(const ValueKey('programme_schedule_0_monday'));
      await tester.ensureVisible(monday);
      await tester.tap(
        find.descendant(of: monday, matching: find.text('Monday')),
      );
      await tester.pumpAndSettle();
      final repeat = find.descendant(
        of: monday,
        matching: find.text(AppStrings.programmeRepeatInBlock),
      );
      await tester.ensureVisible(repeat);
      await tester.tap(repeat);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      final before = harness.current(tester);
      await tester.tap(find.text(AppStrings.programmeCustomDay));
      await tester.pumpAndSettle();
      expect(harness.current(tester), same(before));
      expect(repeat, findsOneWidget);
      await tester.tap(repeat);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, AppStrings.programmeRepeatInBlock),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(repeat, findsNothing);
      final provider = AppProviders.programmeBuilderControllerProvider(
        _Harness.argument,
      );
      final source = harness
          .current(tester)
          .weeks!
          .first
          .slots!
          .single
          .template!;
      harness
          .container(tester)
          .read(provider.notifier)
          .updateTemplateExercise(
            source.id,
            source.exercises.first.copyWith(notes: 'Custom now'),
          );
      await tester.pumpAndSettle();
      expect(repeat, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'repeat scope picker and direct action fit 320px at 2x text: dark=$dark',
      (tester) async {
        _Driver.viewport(tester, const Size(320, 844));
        final original = _Fixtures.draft(assigned: true);
        final week = original.weeks!.single;
        final harness = _Harness(
          dark: dark,
          scale: 2,
          draft: original.copyWith(
            trainingBlocks: const [
              ProgrammeTrainingBlockDraft(
                id: 'base',
                name: 'Base',
                weekCount: 2,
              ),
            ],
            weeks: [
              week,
              week.copyWith(
                id: 'week-2',
                weekNumber: 2,
                slots: [
                  week.slots!.single.copyWith(
                    template: week.slots!.single.template!.copyWith(
                      name: 'Different workout',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        await _Driver.load(tester, harness);
        await _Driver.openSchedule(tester);
        final monday = find.byKey(
          const ValueKey('programme_schedule_0_monday'),
        );
        final day = find.descendant(of: monday, matching: find.text('Monday'));
        await tester.ensureVisible(day);
        await tester.tap(day);
        await tester.pumpAndSettle();
        final pick = find.descendant(
          of: monday,
          matching: find.text('Push Day'),
        );
        await tester.ensureVisible(pick);
        await tester.tap(pick);
        await tester.pumpAndSettle();
        final scope = find.widgetWithText(
          ChoiceChip,
          AppStrings.programmeRepeatInBlock,
        );
        await tester.ensureVisible(scope);
        await tester.tap(scope);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip(AppStrings.close));
        await tester.pumpAndSettle();
        await _Driver.next(tester);
        final repeat = find.byKey(
          const ValueKey('programme_repeat_selected_workout'),
        );
        await tester.ensureVisible(repeat);
        await tester.tap(repeat);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(AlertDialog), findsNothing);
        expect(repeat, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'workout scope copies a weekday in its block from both schedule and Define Workouts',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final original = _Fixtures.draft(assigned: true);
      final week = original.weeks!.single;
      final draft = original.copyWith(
        trainingBlocks: const [
          ProgrammeTrainingBlockDraft(id: 'base', name: 'Base', weekCount: 2),
          ProgrammeTrainingBlockDraft(id: 'peak', name: 'Peak', weekCount: 1),
        ],
        weeks: [
          week,
          week.copyWith(id: 'week-2', weekNumber: 2),
          week.copyWith(id: 'week-3', weekNumber: 3),
        ],
      );
      final harness = _Harness(draft: draft);
      await _Driver.load(tester, harness);
      await _Driver.openSchedule(tester);
      final monday = find.byKey(const ValueKey('programme_schedule_0_monday'));
      await tester.ensureVisible(monday);
      await tester.tap(
        find.descendant(of: monday, matching: find.text('Monday')),
      );
      await tester.pumpAndSettle();
      final pick = find.descendant(of: monday, matching: find.text('Push Day'));
      await tester.ensureVisible(pick);
      await tester.tap(pick);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(
              find.widgetWithText(ChoiceChip, AppStrings.programmeCustomDay),
            )
            .selected,
        isTrue,
      );
      await tester.tap(
        find.widgetWithText(ChoiceChip, AppStrings.programmeRepeatInBlock),
      );
      final choose = find.descendant(
        of: find.byType(TemplateReassignmentBottomSheet),
        matching: find.text('Push Day'),
      );
      await tester.ensureVisible(choose);
      final before = harness.current(tester);
      await tester.tap(choose);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.descendant(
          of: monday,
          matching: find.text(AppStrings.programmeRepeatInBlock),
        ),
        findsNothing,
      );
      var after = harness.current(tester);
      expect(
        after.weeks![1].slots!.single.template!.id,
        isNot(before.weeks![1].slots!.single.template!.id),
      );
      expect(after.weeks![2], same(before.weeks![2]));
      await _Driver.next(tester);
      final repeat = find.byKey(
        const ValueKey('programme_repeat_selected_workout'),
      );
      expect(repeat, findsNothing);
      final source = harness
          .current(tester)
          .weeks!
          .first
          .slots!
          .single
          .template!;
      harness
          .container(tester)
          .read(
            AppProviders.programmeBuilderControllerProvider(
              _Harness.argument,
            ).notifier,
          )
          .updateTemplateExercise(
            source.id,
            source.exercises.first.copyWith(notes: 'Custom afterwards'),
          );
      await tester.pumpAndSettle();
      expect(repeat, findsOneWidget);
      await tester.ensureVisible(repeat);
      final beforeDirectRepeat = harness.current(tester);
      await tester.tap(repeat);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(repeat, findsNothing);
      final directRepeat = harness.current(tester);
      expect(
        directRepeat.weeks![1].slots!.single.template!.id,
        isNot(after.weeks![1].slots!.single.template!.id),
      );
      expect(directRepeat.weeks![2], same(beforeDirectRepeat.weeks![2]));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'block training days are optional and weeks remain editable independently',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      final controller = harness
          .container(tester)
          .read(
            AppProviders.programmeBuilderControllerProvider(
              _Harness.argument,
            ).notifier,
          );
      controller.resizeWeeks(2);
      await tester.pumpAndSettle();
      await _Driver.next(tester);
      final blockId = harness.current(tester).trainingBlocks.single.id;
      final next = find.byKey(const ValueKey('programme_builder_next'));
      expect(
        harness.current(tester).trainingBlocks.single.trainingDays,
        isEmpty,
      );
      expect(tester.widget<FilledButton>(next).onPressed, isNotNull);
      final friday = find.byKey(
        ValueKey('training_block_day_${blockId}_friday'),
      );
      await tester.ensureVisible(friday);
      await tester.tap(friday);
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(friday).selected, isTrue);
      expect(
        harness
            .current(tester)
            .weeks!
            .every(
              (week) => week.slots!.any((slot) => slot.scheduledDayIndex == 4),
            ),
        isTrue,
      );
      await _Driver.next(tester);
      final weekFriday = find.byKey(
        const ValueKey('programme_schedule_0_friday'),
      );
      await tester.ensureVisible(weekFriday);
      await tester.tap(
        find.descendant(of: weekFriday, matching: find.byType(AppTogglePill)),
      );
      await tester.pumpAndSettle();
      expect(
        harness
            .current(tester)
            .weeks!
            .first
            .slots!
            .map((slot) => slot.scheduledDayIndex),
        [0],
      );
      expect(
        harness
            .current(tester)
            .weeks!
            .last
            .slots!
            .map((slot) => slot.scheduledDayIndex),
        [0, 4],
      );
      final blocks = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.trainingBlocks,
      );
      await tester.tap(blocks);
      await tester.pumpAndSettle();
      await tester.ensureVisible(friday);
      expect(tester.widget<FilterChip>(friday).selected, isTrue);
      final wednesday = find.byKey(
        ValueKey('training_block_day_${blockId}_wednesday'),
      );
      await tester.ensureVisible(wednesday);
      await tester.tap(wednesday);
      await tester.pumpAndSettle();
      expect(
        harness
            .current(tester)
            .weeks!
            .first
            .slots!
            .map((slot) => slot.scheduledDayIndex),
        [0, 2],
      );
      expect(
        harness
            .current(tester)
            .weeks!
            .last
            .slots!
            .map((slot) => slot.scheduledDayIndex),
        [0, 4, 2],
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('removing an assigned block day asks before clearing workouts', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 1000));
    final harness = _Harness(draft: _Fixtures.draft(assigned: true));
    await _Driver.load(tester, harness);
    final controller = harness
        .container(tester)
        .read(
          AppProviders.programmeBuilderControllerProvider(
            _Harness.argument,
          ).notifier,
        );
    controller.setBlockTrainingDay('base-block', TrainingDay.monday, true);
    await tester.pumpAndSettle();
    await _Driver.next(tester);
    final monday = find.byKey(
      const ValueKey('training_block_day_base-block_monday'),
    );
    await tester.ensureVisible(monday);
    await tester.tap(monday);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.removeBlockTrainingDay), findsOneWidget);
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(
      harness.current(tester).weeks!.single.slots!.single.template,
      isNotNull,
    );
    expect(tester.widget<FilterChip>(monday).selected, isTrue);
    await tester.tap(monday);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.continueLabel));
    await tester.pumpAndSettle();
    expect(harness.current(tester).weeks!.single.slots, isEmpty);
    expect(harness.current(tester).trainingBlocks.single.trainingDays, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'training block cards fit a small phone at 2x text: dark=$dark',
      (tester) async {
        _Driver.viewport(tester, const Size(320, 844));
        final harness = _Harness(
          draft: _Fixtures.draft(assigned: true),
          dark: dark,
          scale: 2,
        );
        await _Driver.load(tester, harness);
        await _Driver.next(tester);
        final blockId = harness.current(tester).trainingBlocks.single.id;
        final increase = find.byKey(
          ValueKey('training_block_increase_$blockId'),
        );
        await tester.ensureVisible(increase);
        await tester.tap(increase);
        await tester.pumpAndSettle();
        expect(harness.current(tester).trainingBlocks.single.weekCount, 2);
        final notes = find.byKey(ValueKey('training_block_notes_$blockId'));
        await tester.ensureVisible(notes);
        await tester.enterText(
          notes,
          'Progress gradually with controlled repetitions',
        );
        await tester.pumpAndSettle();
        expect(
          harness.current(tester).trainingBlocks.single.progressionNotes,
          'Progress gradually with controlled repetitions',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'five step flow edits training blocks before schedule, workouts and review',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      await _Driver.next(tester);
      expect(find.text(AppStrings.trainingBlocks), findsNWidgets(2));
      expect(find.text(AppStrings.nextWeeklySchedule), findsOneWidget);
      final blockId = harness.current(tester).trainingBlocks.single.id;
      final name = find.byKey(ValueKey('training_block_name_$blockId'));
      await tester.enterText(name, 'Strength phase');
      final focus = find.byType(DropdownButtonFormField<TrainingBlockFocus>);
      await tester.ensureVisible(focus);
      await tester.tap(focus);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.blockFocusStrength).last);
      await tester.pumpAndSettle();
      final notes = find.byKey(ValueKey('training_block_notes_$blockId'));
      await tester.ensureVisible(notes);
      await tester.enterText(notes, 'Add load when all reps are complete');
      await tester.pumpAndSettle();
      await _Driver.next(tester);
      expect(find.text(AppStrings.planYourWeek), findsOneWidget);
      expect(find.text(AppStrings.nextDefineWorkouts), findsOneWidget);
      await _Driver.next(tester);
      expect(find.text(AppStrings.defineWorkouts), findsNWidgets(2));
      expect(find.text(AppStrings.nextReviewAndPublish), findsOneWidget);
      await _Driver.next(tester);
      expect(
        find.byKey(const ValueKey('programme_builder_publish')),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.programmeReviewPhaseName(1, 'Strength phase')),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('programme_builder_publish')),
      );
      await tester.tap(find.byKey(const ValueKey('programme_builder_publish')));
      await tester.pumpAndSettle();
      final block = harness.save.lastDraft!.trainingBlocks.single;
      expect(block.name, 'Strength phase');
      expect(block.focus, TrainingBlockFocus.strengthBiased);
      expect(block.progressionNotes, 'Add load when all reps are complete');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'training blocks create consecutive weeks and block navigation requires a name',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(
        draft: _Fixtures.draft().copyWith(name: 'New programme'),
      );
      await _Driver.load(tester, harness);
      await _Driver.next(tester);
      final next = find.byKey(const ValueKey('programme_builder_next'));
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      await tester.tap(
        find.byKey(const ValueKey('programme_add_training_block')),
      );
      await tester.pumpAndSettle();
      final first = harness.current(tester).trainingBlocks.single;
      expect(first.weekCount, 4);
      expect(first.name, isEmpty);
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      expect(
        find.text(AppStrings.trainingBlockWeekRange(1, 4)),
        findsOneWidget,
      );
      final name = find.byKey(ValueKey('training_block_name_${first.id}'));
      expect(tester.widget<TextFormField>(name).initialValue, isEmpty);
      await tester.enterText(name, ' ');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      final schedule = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.weeklySchedule,
      );
      await tester.tap(schedule);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.trainingBlockNameRequired), findsOneWidget);
      await tester.enterText(name, 'Volume');
      await tester.pumpAndSettle();
      final add = find.byKey(const ValueKey('programme_add_training_block'));
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      final second = harness.current(tester).trainingBlocks.last;
      expect(
        find.text(AppStrings.trainingBlockWeekRange(5, 8)),
        findsOneWidget,
      );
      final increase = find.byKey(
        ValueKey('training_block_increase_${first.id}'),
      );
      await tester.ensureVisible(increase);
      await tester.tap(increase);
      await tester.pumpAndSettle();
      expect(
        find.text(AppStrings.trainingBlockWeekRange(6, 9)),
        findsOneWidget,
      );
      final remove = find.byKey(ValueKey('training_block_remove_${second.id}'));
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      expect(harness.current(tester).trainingBlocks, hasLength(1));
      expect(harness.current(tester).weeks, hasLength(5));
      await _Driver.next(tester);
      expect(find.text(AppStrings.planYourWeek), findsOneWidget);
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'step validation blocks empty weeks and unassigned days through buttons and progress',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final draft = _Fixtures.draft(assigned: true);
      final harness = _Harness(
        draft: draft.copyWith(
          weeks: [
            draft.weeks!.single,
            const ProgrammeBuilderWeekDraft(
              id: 'week-2',
              weekNumber: 2,
              slots: [],
            ),
          ],
        ),
      );
      await _Driver.load(tester, harness);
      await _Driver.openSchedule(tester);
      final next = find.byKey(const ValueKey('programme_builder_next'));
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      expect(
        find.text(AppStrings.programmeWeekNeedsWorkoutDay(2)),
        findsOneWidget,
      );
      final training = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.defineWorkouts,
      );
      await tester.tap(training);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('programme_schedule_week_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('programme_builder_publish')),
        findsNothing,
      );
      final tuesday = find.byKey(
        const ValueKey('programme_schedule_1_tuesday'),
      );
      await tester.ensureVisible(tuesday);
      await tester.tap(
        find.descendant(of: tuesday, matching: find.byType(AppTogglePill)),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(next).onPressed, isNotNull);
      await _Driver.next(tester);
      expect(find.text(AppStrings.defineWorkouts), findsNWidgets(2));
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      expect(
        find.text(AppStrings.programmeDayNeedsWorkout(2, 'Tuesday')),
        findsOneWidget,
      );
      final review = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.reviewAndPublish,
      );
      await tester.tap(review);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('programme_builder_publish')),
        findsNothing,
      );
      final blank = find.byKey(const ValueKey('programme_unassigned_week-2_0'));
      await tester.ensureVisible(blank);
      await tester.tap(blank);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(TemplateReassignmentBottomSheet),
          matching: find.text('Push Day'),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(next).onPressed, isNotNull);
      await _Driver.next(tester);
      expect(
        find.byKey(const ValueKey('programme_builder_publish')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'step validation rechecks removals and permits going back to repair the schedule',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      final provider = AppProviders.programmeBuilderControllerProvider((
        mode: ProgrammeBuilderMode.create,
        programmeId: null,
      ));
      await harness.container(tester).read(provider.notifier).removeWeek(0);
      await tester.pumpAndSettle();
      final next = find.byKey(const ValueKey('programme_builder_next'));
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      expect(find.text(AppStrings.addAtLeastOneWeek), findsOneWidget);
      final review = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.reviewAndPublish,
      );
      await tester.tap(review);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.trainingBlocksRequired), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('programme_add_training_block')),
      );
      await tester.pumpAndSettle();
      final blockId = harness.current(tester).trainingBlocks.single.id;
      await tester.enterText(
        find.byKey(ValueKey('training_block_name_$blockId')),
        'Base',
      );
      final decrease = find.byKey(ValueKey('training_block_decrease_$blockId'));
      for (var i = 0; i < 3; i++) {
        await tester.ensureVisible(decrease);
        await tester.tap(decrease);
        await tester.pumpAndSettle();
      }
      await _Driver.next(tester);
      expect(
        find.byKey(const ValueKey('programme_builder_publish')),
        findsNothing,
      );
      final monday = find.byKey(const ValueKey('programme_schedule_0_monday'));
      await tester.ensureVisible(monday);
      await tester.tap(
        find.descendant(of: monday, matching: find.byType(AppTogglePill)),
      );
      await tester.pumpAndSettle();
      await _Driver.next(tester);
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      final remove = find.byTooltip(AppStrings.removeWorkoutDay('Monday'));
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      expect(
        find.text(AppStrings.programmeWeekNeedsWorkoutDay(1)),
        findsOneWidget,
      );
      final schedule = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.weeklySchedule,
      );
      await tester.tap(schedule);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.planYourWeek), findsOneWidget);
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Training Blocks removes the selected workout and saves remaining days',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.workouts());
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      final pull = find.byKey(const ValueKey('programme_template_pull'));
      await tester.ensureVisible(pull);
      await tester.tap(pull);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('programme_config_row')),
        findsOneWidget,
      );
      final remove = find.byTooltip(AppStrings.removeWorkoutDay('Wednesday'));
      await tester.ensureVisible(remove);
      expect(tester.getSize(remove).shortestSide, greaterThanOrEqualTo(48));
      await tester.tap(remove);
      await tester.pumpAndSettle();
      final slots = harness.current(tester).weeks!.single.slots!;
      expect(slots, hasLength(1));
      expect(slots.single.scheduledDay, TrainingDay.monday);
      expect(find.text(AppStrings.programmeWorkoutCount(1)), findsOneWidget);
      expect(
        find.byKey(const ValueKey('programme_config_exercise')),
        findsOneWidget,
      );
      expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
      await _Driver.next(tester);
      final save = find.byKey(const ValueKey('programme_builder_publish'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(harness.save.calls, 1);
      expect(harness.save.lastDraft!.weeks!.single.slots, hasLength(1));
      expect(harness.workouts.saveCalls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Training Blocks removes empty and final days only in the selected week',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final draft = _Fixtures.draft(assigned: true);
      final first = draft.weeks!.single;
      final harness = _Harness(
        draft: draft.copyWith(
          weeks: [
            first,
            first.copyWith(
              id: 'week-2',
              weekNumber: 2,
              slots: [
                first.slots!.single,
                const ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: 1,
                  scheduledDayIndex: 1,
                  scheduledDay: TrainingDay.tuesday,
                ),
              ],
            ),
          ],
        ),
      );
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      await tester.tap(find.byKey(const ValueKey('programme_workouts_week_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.programmeWeekLabel(2)).last);
      await tester.pumpAndSettle();
      final remove = find.byTooltip(AppStrings.removeWorkoutDay('Tuesday'));
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      expect(harness.current(tester).weeks!.last.slots, hasLength(1));
      expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
      final monday = find.byTooltip(AppStrings.removeWorkoutDay('Monday'));
      await tester.ensureVisible(monday);
      await tester.tap(monday);
      await tester.pumpAndSettle();
      final weeks = harness.current(tester).weeks!;
      expect(weeks.first.slots, hasLength(1));
      expect(weeks.last.slots, isEmpty);
      expect(find.text(AppStrings.programmeWorkoutCount(0)), findsOneWidget);
      expect(find.byType(WorkoutBuilderScreen), findsNothing);
      final plus = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.addWorkoutSlot,
      );
      await tester.ensureVisible(plus);
      await tester.tap(plus);
      await tester.pumpAndSettle();
      expect(
        harness.current(tester).weeks!.last.slots!.single.scheduledDay,
        TrainingDay.monday,
      );
      expect(
        harness.current(tester).weeks!.last.slots!.single.template,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Training Blocks + adds another blank day to the selected week when one is already unassigned',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final draft = _Fixtures.draft(assigned: true);
      final first = draft.weeks!.single;
      final harness = _Harness(
        draft: draft.copyWith(
          weeks: [
            first,
            first.copyWith(
              id: 'week-2',
              weekNumber: 2,
              slots: [
                first.slots!.single,
                const ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: 1,
                  scheduledDayIndex: 1,
                  scheduledDay: TrainingDay.tuesday,
                ),
              ],
            ),
          ],
        ),
      );
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      final picker = find.byKey(const ValueKey('programme_workouts_week_0'));
      await tester.tap(picker);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.programmeWeekLabel(2)).last);
      await tester.pumpAndSettle();
      final plus = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.addWorkoutSlot,
      );
      await tester.ensureVisible(plus);
      await tester.tap(plus);
      await tester.pumpAndSettle();
      final weeks = harness.current(tester).weeks!;
      expect(weeks.first.slots, hasLength(1));
      expect(weeks.last.slots, hasLength(3));
      expect(weeks.last.slots![1].template, isNull);
      expect(weeks.last.slots!.last.template, isNull);
      expect(weeks.last.slots!.last.scheduledDay, TrainingDay.wednesday);
      final tab = find.byKey(const ValueKey('programme_unassigned_week-2_2'));
      expect(tab, findsOneWidget);
      expect(tester.getRect(tab).right, lessThanOrEqualTo(390));
      expect(
        find.text(
          AppStrings.programmeDayTemplate(
            'Wednesday',
            AppStrings.selectWorkoutTemplate,
          ),
        ),
        findsOneWidget,
      );
      expect(find.text(AppStrings.programmeWorkoutCount(3)), findsOneWidget);
      expect(find.byType(WorkoutBuilderScreen), findsNothing);
      expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
      expect(harness.workouts.saveCalls, 0);
      expect(harness.save.calls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Training Blocks has one independent day template per selected week',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final draft = _Fixtures.draft(assigned: true);
      final firstWeek = draft.weeks!.single;
      final monday = firstWeek.slots!.single;
      final repeated = firstWeek.copyWith(
        slots: [
          monday,
          monday.copyWith(
            slotIndex: 1,
            scheduledDayIndex: 2,
            scheduledDay: TrainingDay.wednesday,
          ),
          monday.copyWith(
            slotIndex: 2,
            scheduledDayIndex: 4,
            scheduledDay: TrainingDay.friday,
          ),
        ],
      );
      final harness = _Harness(
        draft: draft.copyWith(
          weeks: [
            repeated,
            repeated.copyWith(id: 'week-2', weekNumber: 2),
          ],
        ),
      );
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      for (final day in ['Monday', 'Wednesday', 'Friday']) {
        expect(
          find.text(AppStrings.programmeDayTemplate(day, 'Push Day')),
          findsOneWidget,
        );
      }
      expect(find.text(AppStrings.programmeWorkoutCount(3)), findsOneWidget);
      var weeks = harness.current(tester).weeks!;
      expect(
        weeks.first.slots!.map((slot) => slot.template!.id).toSet(),
        hasLength(3),
      );
      final wednesday = weeks.first.slots![1].template!;
      final tab = find.byKey(ValueKey('programme_template_${wednesday.id}'));
      await tester.ensureVisible(tab);
      await tester.tap(tab);
      await tester.pumpAndSettle();
      final weight = find.descendant(
        of: find.byKey(
          ValueKey(
            'exercise_config_weight_${wednesday.exercises.single.sets.single.id}',
          ),
        ),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(weight);
      await tester.enterText(weight, '42.5');
      await tester.pumpAndSettle();
      final addSet = find.byKey(const ValueKey('exercise_config_add_set'));
      await tester.ensureVisible(addSet);
      await tester.tap(addSet);
      await tester.pumpAndSettle();
      weeks = harness.current(tester).weeks!;
      expect(
        weeks.first.slots![1].template!.exercises.single.sets,
        hasLength(2),
      );
      expect(
        weeks
            .first
            .slots![1]
            .template!
            .exercises
            .single
            .sets
            .first
            .prescribedWeightKg,
        42.5,
      );
      for (final index in [0, 2]) {
        expect(
          weeks.first.slots![index].template!.exercises.single.sets,
          hasLength(1),
        );
        expect(
          weeks
              .first
              .slots![index]
              .template!
              .exercises
              .single
              .sets
              .single
              .prescribedWeightKg,
          30,
        );
      }
      final weekPicker = find.byKey(
        const ValueKey('programme_workouts_week_0'),
      );
      await tester.ensureVisible(weekPicker);
      await tester.tap(weekPicker);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.programmeWeekLabel(2)).last);
      await tester.pumpAndSettle();
      expect(
        find.byKey(ValueKey('programme_template_${wednesday.id}')),
        findsNothing,
      );
      for (final day in ['Monday', 'Wednesday', 'Friday']) {
        expect(
          find.text(AppStrings.programmeDayTemplate(day, 'Push Day')),
          findsOneWidget,
        );
      }
      for (final slot in harness.current(tester).weeks!.last.slots!) {
        expect(slot.template!.exercises.single.sets, hasLength(1));
        expect(
          slot.template!.exercises.single.sets.single.prescribedWeightKg,
          30,
        );
      }
      await _Driver.next(tester);
      await tester.ensureVisible(
        find.byKey(const Key('programme_builder_publish')),
      );
      await tester.tap(find.byKey(const Key('programme_builder_publish')));
      await tester.pumpAndSettle();
      expect(harness.save.calls, 1);
      final saved = harness.save.lastDraft!.weeks!;
      expect(
        saved
            .expand((week) => week.slots!)
            .map((slot) => slot.template!.id)
            .toSet(),
        hasLength(6),
      );
      expect(
        saved
            .first
            .slots![1]
            .template!
            .exercises
            .single
            .sets
            .first
            .prescribedWeightKg,
        42.5,
      );
      expect(
        saved
            .last
            .slots![1]
            .template!
            .exercises
            .single
            .sets
            .single
            .prescribedWeightKg,
        30,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'an unassigned workout day gets its own template and becomes editable immediately',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final draft = _Fixtures.draft(assigned: true);
      final week = draft.weeks!.single;
      final monday = week.slots!.single;
      final harness = _Harness(
        draft: draft.copyWith(
          weeks: [
            week.copyWith(
              slots: [
                monday,
                monday.copyWith(
                  slotIndex: 1,
                  scheduledDayIndex: 2,
                  scheduledDay: TrainingDay.wednesday,
                  clearTemplate: true,
                ),
              ],
            ),
          ],
        ),
      );
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      final unassigned = find.byKey(
        ValueKey('programme_unassigned_${week.id}_1'),
      );
      expect(unassigned, findsOneWidget);
      expect(
        find.text(AppStrings.programmeDayTemplate('Monday', 'Push Day')),
        findsOneWidget,
      );
      await tester.ensureVisible(unassigned);
      await tester.tap(unassigned);
      await tester.pumpAndSettle();
      final choice = find.descendant(
        of: find.byType(TemplateReassignmentBottomSheet),
        matching: find.text('Push Day'),
      );
      expect(choice, findsOneWidget);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      final slots = harness.current(tester).weeks!.single.slots!;
      expect(slots[1].template!.id, isNot(slots[0].template!.id));
      expect(
        find.text(AppStrings.programmeDayTemplate('Wednesday', 'Push Day')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          ValueKey(
            'programme_config_${slots[1].template!.exercises.single.id}',
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Create template opens the workout builder and saves only with its programme',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      await _Driver.openSchedule(tester);
      await _Driver.createTemplateFromMonday(tester);
      expect(
        find.text(AppStrings.programmeTemplateBuilderHint),
        findsOneWidget,
      );
      expect(
        tester
            .widget<WorkoutBuilderScreen>(find.byType(WorkoutBuilderScreen))
            .mode,
        WorkoutBuilderMode.programmeTemplate,
      );
      await _Driver.authorProgrammeWorkout(tester, 'Programme Pull');
      await _Driver.saveTemplate(tester);
      expect(find.byType(WorkoutBuilderScreen), findsNothing);
      expect(find.byType(ProgrammeBuilderScreen), findsOneWidget);
      var template = harness
          .current(tester)
          .weeks!
          .single
          .slots!
          .single
          .template!;
      expect(template.name, 'Programme Pull');
      expect(template.exercises.single.exerciseRef, 'Cable Row');
      expect(template.exercises.single.notes, 'Smooth repetitions');
      expect(template.exercises.single.sets.single.prescribedRepsExact, 12);
      expect(template.exercises.single.sets.single.prescribedWeightKg, 25);
      expect(template.exercises.single.sets.single.restSeconds, 90);
      expect(harness.workouts.saveCalls, 0);
      expect(harness.save.calls, 0);
      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, 'Programme Pull'),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Programme Pull'));
      await tester.pumpAndSettle();
      final sheet = find.byType(TemplateReassignmentBottomSheet);
      expect(
        find.descendant(of: sheet, matching: find.text('Programme Pull')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(AppStrings.programmeTemplates),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(AppStrings.noSavedWorkoutsToImport),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip(AppStrings.close));
      await tester.pumpAndSettle();
      await _Driver.next(tester);
      await _Driver.next(tester);
      await tester.ensureVisible(
        find.byKey(const Key('programme_builder_publish')),
      );
      await tester.tap(find.byKey(const Key('programme_builder_publish')));
      await tester.pumpAndSettle();
      expect(harness.save.calls, 1);
      template = harness.save.lastDraft!.weeks!.single.slots!.single.template!;
      expect(template.name, 'Programme Pull');
      expect(template.exercises.single.sets.single.prescribedWeightKg, 25);
      expect(harness.workouts.saveCalls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cancelling a programme workout keeps its assignment and discards only the child draft',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      await _Driver.openSchedule(tester);
      await _Driver.createTemplateFromMonday(tester);
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.workoutNameHint),
        'Discard this template',
      );
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.unsavedChangesMessage), findsOneWidget);
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutBuilderScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.discardChanges));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutBuilderScreen), findsNothing);
      expect(
        harness.current(tester).weeks!.single.slots!.single.template!.name,
        'Push Day',
      );
      expect(harness.workouts.saveCalls, 0);
      await _Driver.createTemplateFromMonday(tester);
      expect(
        tester
            .widget<TextField>(
              find.widgetWithText(TextField, AppStrings.workoutNameHint),
            )
            .controller!
            .text,
        isEmpty,
      );
      expect(find.text(AppStrings.saveTemplate), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Training Blocks + adds an unassigned day before workout selection or creation',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.workouts());
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      final create = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == AppStrings.addWorkoutSlot,
      );
      await tester.ensureVisible(create);
      await tester.tap(create);
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutBuilderScreen), findsNothing);
      expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
      final added = harness.current(tester).weeks!.single.slots!;
      expect(added, hasLength(3));
      expect(added.last.scheduledDay, TrainingDay.tuesday);
      expect(added.last.template, isNull);
      expect(
        find.text(
          AppStrings.programmeDayTemplate(
            'Tuesday',
            AppStrings.selectWorkoutTemplate,
          ),
        ),
        findsOneWidget,
      );
      final unassigned = find.byKey(
        ValueKey(
          'programme_unassigned_${harness.current(tester).weeks!.single.id}_2',
        ),
      );
      await tester.ensureVisible(unassigned);
      await tester.tap(unassigned);
      await tester.pumpAndSettle();
      expect(find.byType(TemplateReassignmentBottomSheet), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(TemplateReassignmentBottomSheet),
          matching: find.text(AppStrings.createTemplate),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutBuilderScreen), findsOneWidget);
      await _Driver.authorProgrammeWorkout(tester, 'Programme Legs');
      await _Driver.saveTemplate(tester);
      final slots = harness.current(tester).weeks!.single.slots!;
      expect(slots, hasLength(3));
      expect(slots.map((slot) => slot.template!.name), [
        'Push Day',
        'Pull Day',
        'Programme Legs',
      ]);
      expect(slots.last.scheduledDay, TrainingDay.tuesday);
      expect(harness.workouts.saveCalls, 0);
      expect(harness.save.calls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'details matches the supplied hierarchy and edits the local draft',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 884));
      final harness = _Harness();
      await _Driver.load(tester, harness);
      expect(find.text(AppStrings.programmeCreateTitle), findsOneWidget);
      expect(find.text(AppStrings.saveDraft), findsOneWidget);
      expect(find.bySemanticsLabel(AppStrings.close), findsNothing);
      expect(
        find.text(AppStrings.programmeDetailsSectionTitle),
        findsOneWidget,
      );
      expect(find.text(AppStrings.primaryGoal), findsOneWidget);
      expect(find.text(AppStrings.nextTrainingBlocks), findsOneWidget);
      expect(
        find.byKey(const ValueKey('programme_builder_navigation')),
        findsNothing,
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('programme_name_field')),
          matching: find.byType(TextField),
        ),
        'Summer Strength',
      );
      await tester.tap(find.text(AppStrings.hypertrophyGoal));
      await tester.pumpAndSettle();
      expect(harness.current(tester).name, 'Summer Strength');
      expect(
        harness.current(tester).goalTags,
        containsAll([GoalTag.buildMuscle, GoalTag.increaseStrength]),
      );
      expect(
        tester
            .getRect(find.byKey(const ValueKey('programme_builder_next_bar')))
            .bottom,
        884,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Details requires a trimmed name and a goal before enabling Next',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft().copyWith(goalTags: {}));
      await _Driver.load(tester, harness);
      final next = find.byKey(const ValueKey('programme_builder_next'));
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      await tester.enterText(find.byType(TextField).first, '   ');
      await tester.tap(find.text(AppStrings.strengthGoal));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      await tester.enterText(find.byType(TextField).first, 'Summer Strength');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(next).onPressed, isNotNull);
      await tester.tap(find.text(AppStrings.strengthGoal));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      await tester.tap(find.text(AppStrings.hypertrophyGoal));
      await tester.pumpAndSettle();
      await _Driver.next(tester);
      expect(
        find.byKey(const ValueKey('programme_add_training_block')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'schedule training toggles and clears a template without losing the day',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      await _Driver.openSchedule(tester);
      expect(find.text(AppStrings.planYourWeek), findsOneWidget);
      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.clearSelection));
      await tester.pumpAndSettle();
      expect(
        harness.current(tester).weeks!.single.slots!.single.template,
        isNull,
      );
      final tuesday = find.byKey(
        const ValueKey('programme_schedule_0_tuesday'),
      );
      await tester.ensureVisible(tuesday);
      await tester.tap(
        find.descendant(of: tuesday, matching: find.byType(AppTogglePill)),
      );
      await tester.pumpAndSettle();
      expect(harness.current(tester).weeks!.single.slots, hasLength(2));
      expect(
        harness.current(tester).weeks!.single.slots!.last.scheduledDay,
        TrainingDay.tuesday,
      );
      await _Driver.next(tester);
      expect(find.text(AppStrings.defineWorkouts), findsNWidgets(2));
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('programme_builder_next')),
            )
            .onPressed,
        isNull,
      );
      expect(find.byKey(const Key('programme_builder_publish')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Save Draft requires a name without changing the current programme status',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 884));
      final harness = _Harness();
      await _Driver.load(tester, harness);
      await tester.tap(find.text(AppStrings.saveDraft));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.programmeInvalid), findsOneWidget);
      expect(find.text(AppStrings.programmeNameRequired), findsOneWidget);
      expect(harness.current(tester).status, ProgramStatus.inactive);
      expect(harness.save.calls, 0);
      expect(find.byType(ProgrammeBuilderScreen), findsOneWidget);
    },
  );

  testWidgets(
    'block shortening confirms removal and cancellation preserves workouts',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      harness
          .container(tester)
          .read(
            AppProviders.programmeBuilderControllerProvider(
              _Harness.argument,
            ).notifier,
          )
          .resizeWeeks(4);
      await tester.pumpAndSettle();
      await _Driver.next(tester);
      final blockId = harness.current(tester).trainingBlocks.single.id;
      final decrease = find.byKey(ValueKey('training_block_decrease_$blockId'));
      await tester.ensureVisible(decrease);
      await tester.tap(decrease);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.shortenProgrammeMessage), findsOneWidget);
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();
      expect(harness.current(tester).weeks, hasLength(4));
      await tester.tap(decrease);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pumpAndSettle();
      expect(harness.current(tester).weeks, hasLength(3));
      expect(harness.current(tester).trainingBlocks.single.weekCount, 3);
      expect(
        harness.current(tester).weeks!.first.slots!.single.template!.id,
        'push',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('assigns an existing template to a newly enabled day', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 1000));
    final harness = _Harness(draft: _Fixtures.draft(assigned: true));
    await _Driver.load(tester, harness);
    await _Driver.openSchedule(tester);
    final wednesday = find.byKey(
      const ValueKey('programme_schedule_0_wednesday'),
    );
    await tester.ensureVisible(wednesday);
    await tester.tap(
      find.descendant(of: wednesday, matching: find.text('Wednesday')),
    );
    await tester.pumpAndSettle();
    final select = find.descendant(
      of: wednesday,
      matching: find.text(AppStrings.selectWorkoutTemplate),
    );
    await tester.ensureVisible(select);
    await tester.tap(select);
    await tester.pumpAndSettle();
    expect(find.byType(TemplateReassignmentBottomSheet), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(TemplateReassignmentBottomSheet),
        matching: find.text('Push Day'),
      ),
    );
    await tester.pumpAndSettle();
    final slots = harness.current(tester).weeks!.single.slots!;
    expect(slots, hasLength(2));
    expect(slots.last.scheduledDay, TrainingDay.wednesday);
    expect(slots.last.template!.id, isNot(slots.first.template!.id));
    expect(slots.last.template!.name, 'Push Day');
    expect(
      slots.last.template!.exercises.single.exerciseId,
      slots.first.template!.exercises.single.exerciseId,
    );
    expect(slots.first.template!.id, 'push');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Save Draft persists a valid programme as a local draft and exits',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      await tester.enterText(find.byType(TextField).first, 'Summer Strength');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('programme_save_draft')));
      await tester.pumpAndSettle();
      expect(harness.save.calls, 1);
      expect(harness.save.lastDraft!.status, ProgramStatus.draft);
      expect(harness.save.lastDraft!.active, isFalse);
      expect(
        harness.save.lastDraft!.weeks!.single.slots!.single.template!.id,
        'push',
      );
      expect(find.byType(ProgrammeBuilderScreen), findsNothing);
      expect(find.text('Library'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Save Draft preserves named details without requiring goals or weeks',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft().copyWith(goalTags: {}));
      await _Driver.load(tester, harness);
      await tester.enterText(find.byType(TextField).first, 'Work in progress');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('programme_save_draft')));
      await tester.pumpAndSettle();
      expect(harness.save.calls, 1);
      expect(harness.save.lastDraft!.status, ProgramStatus.draft);
      expect(harness.save.lastDraft!.active, isFalse);
      expect(harness.save.lastDraft!.weeks, isEmpty);
      expect(harness.save.lastDraft!.goalTags, isEmpty);
      expect(find.text('Library'), findsOneWidget);
    },
  );

  testWidgets('retrying Save Draft keeps draft intent and unfinished details', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 1000));
    final harness = _Harness(draft: _Fixtures.draft().copyWith(goalTags: {}));
    harness.save.shouldThrow = true;
    await _Driver.load(tester, harness);
    await tester.enterText(find.byType(TextField).first, 'Work in progress');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('programme_save_draft')));
    await tester.pumpAndSettle();
    expect(harness.save.calls, 1);
    expect(find.byType(ProgrammeBuilderScreen), findsOneWidget);
    expect(harness.current(tester).name, 'Work in progress');
    harness.save.shouldThrow = false;
    final retry = find.text(AppStrings.retry);
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(harness.save.calls, 2);
    expect(harness.save.lastDraft!.status, ProgramStatus.draft);
    expect(harness.save.lastDraft!.goalTags, isEmpty);
    expect(find.text('Library'), findsOneWidget);
  });

  testWidgets(
    'app bar Back returns through every stage and preserves the draft',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 884));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      final back = find.byKey(const ValueKey('programme_builder_back'));
      final header = find.byKey(const ValueKey('programme_builder_header'));
      expect(find.descendant(of: header, matching: back), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Summer Strength');
      await tester.pumpAndSettle();
      for (var step = 1; step <= 4; step++) {
        await _Driver.next(tester);
        expect(find.descendant(of: header, matching: back), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('programme_builder_next_bar')),
            matching: back,
          ),
          findsNothing,
        );
      }
      for (var step = 3; step >= 0; step--) {
        await tester.tap(back);
        await tester.pumpAndSettle();
        expect(harness.current(tester).name, 'Summer Strength');
        expect(
          harness.current(tester).weeks!.single.slots!.single.template!.id,
          'push',
        );
        expect(back, findsOneWidget);
      }
      expect(find.text(AppStrings.primaryGoal), findsOneWidget);
      expect(harness.save.calls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Define Workouts switches templates and keeps editable targets and notes',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.workouts());
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      expect(find.text(AppStrings.defineWorkouts), findsNWidgets(2));
      expect(
        find.text(AppStrings.programmeExerciseCount(2).toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('programme_template_push')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('programme_template_pull')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('programme_config_exercise')),
        findsOneWidget,
      );

      Future<void> edit(String key, String text) async {
        final field = find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(field);
        await tester.enterText(field, text);
        await tester.pumpAndSettle();
      }

      await edit('exercise_config_reps_set', '8-12');
      await edit('exercise_config_target_set', '7.5-8.5');
      await edit('exercise_config_weight_set', '42.5');
      await edit('exercise_config_rest_set', '90');
      await edit('exercise_config_notes', 'Controlled lowering');
      var exercise = harness
          .current(tester)
          .weeks!
          .first
          .slots!
          .first
          .template!
          .exercises
          .first;
      expect(exercise.sets.single.prescribedRepsExact, isNull);
      expect(exercise.sets.single.prescribedRepsMin, 8);
      expect(exercise.sets.single.prescribedRepsMax, 12);
      expect(exercise.sets.single.prescribedRpeMin, 7.5);
      expect(exercise.sets.single.prescribedRpeMax, 8.5);
      expect(exercise.sets.single.prescribedWeightKg, 42.5);
      expect(exercise.sets.single.restSeconds, 90);
      expect(exercise.notes, 'Controlled lowering');
      await tester.ensureVisible(
        find.byKey(const ValueKey('exercise_config_add_set')),
      );
      await tester.tap(find.byKey(const ValueKey('exercise_config_add_set')));
      await tester.pumpAndSettle();
      exercise = harness
          .current(tester)
          .weeks!
          .first
          .slots!
          .first
          .template!
          .exercises
          .first;
      expect(exercise.sets, hasLength(2));
      expect(exercise.sets.last.prescribedWeightKg, 42.5);
      expect(exercise.sets.last.setIndex, 1);
      final type = find.byKey(const ValueKey('exercise_config_type_set'));
      await tester.ensureVisible(type);
      await tester.tap(type);
      await tester.pumpAndSettle();
      expect(
        harness
            .current(tester)
            .weeks!
            .first
            .slots!
            .first
            .template!
            .exercises
            .first
            .sets
            .first
            .setType,
        SetType.warmup,
      );
      final removeSet = find.byTooltip(AppStrings.removeSet).last;
      await tester.ensureVisible(removeSet);
      await tester.tap(removeSet);
      await tester.pumpAndSettle();
      expect(
        harness
            .current(tester)
            .weeks!
            .first
            .slots!
            .first
            .template!
            .exercises
            .first
            .sets,
        hasLength(1),
      );
      for (final template in ['pull', 'push']) {
        final tab = find.byKey(ValueKey('programme_template_$template'));
        await tester.ensureVisible(tab);
        await tester.tap(tab);
        await tester.pumpAndSettle();
        expect(
          find.byKey(
            ValueKey(
              'programme_config_${template == 'pull' ? 'row' : 'exercise'}',
            ),
          ),
          findsOneWidget,
        );
      }
      await _Driver.next(tester);
      await tester.tap(find.byKey(const ValueKey('programme_builder_back')));
      await tester.pumpAndSettle();
      exercise = harness
          .current(tester)
          .weeks!
          .first
          .slots!
          .first
          .template!
          .exercises
          .first;
      expect(exercise.notes, 'Controlled lowering');
      expect(exercise.sets.first.prescribedRepsMax, 12);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'all steps float actions and Review publishes without activation controls',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      for (var step = 0; step < 5; step++) {
        final surface = find.byKey(
          const ValueKey('programme_builder_action_surface'),
        );
        expect(surface, findsOneWidget);
        final bounds = tester.getRect(surface);
        expect(bounds.left, AppSpacing.md);
        expect(bounds.right, 390 - AppSpacing.md);
        expect(bounds.bottom, 1000 - AppSpacing.md);
        // Content occupies the screen behind the inset action surface.
        expect(
          tester
              .getRect(find.byKey(ValueKey('programme_builder_scroll_$step')))
              .bottom,
          1000,
        );
        if (step < 4) {
          expect(find.text(AppStrings.proceed), findsOneWidget);
          expect(harness.save.calls, 0);
          await _Driver.next(tester);
        }
      }
      expect(find.byType(AppTogglePill), findsNothing);
      expect(find.text(AppStrings.programmeBuilderStep(5)), findsOneWidget);
      expect(find.text(AppStrings.programmeReadyToPublish), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('programme_builder_publish')));
      await tester.pumpAndSettle();
      expect(harness.save.calls, 1);
      expect(harness.save.lastDraft!.active, isFalse);
      expect(harness.save.lastDraft!.status, ProgramStatus.inactive);
      expect(find.text('Library'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'floating action keeps the final content reachable above the phone safe area',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      tester.view.padding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.resetPadding);
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      final surface = find.byKey(
        const ValueKey('programme_builder_action_surface'),
      );
      final initialBounds = tester.getRect(surface);
      expect(initialBounds.bottom, 1000 - 34 - AppSpacing.md);
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const ValueKey('programme_builder_scroll_0')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), initialBounds);
      expect(
        tester.getBottomLeft(find.text(AppStrings.primaryGoal)).dy,
        lessThan(initialBounds.top),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'styled week management retains duplication, week types, removal, and collapse',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.draft(assigned: true));
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      final heading = find.text(AppStrings.manageTrainingWeeks);
      await tester.ensureVisible(heading);
      await tester.tap(heading);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('programme_week_management_surface')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.programmeWeeksSectionTitle), findsOneWidget);
      final duplicate = find.byTooltip(AppStrings.duplicateWeek);
      await tester.ensureVisible(duplicate);
      await tester.tap(duplicate);
      await tester.pumpAndSettle();
      expect(harness.current(tester).weeks, hasLength(2));
      final weekType = find.byType(DropdownButton<WeekType>).first;
      await tester.ensureVisible(weekType);
      await tester.tap(weekType);
      await tester.pumpAndSettle();
      await tester.tap(find.text('deload').last);
      await tester.pumpAndSettle();
      expect(harness.current(tester).weeks!.first.weekType, WeekType.deload);
      final remove = find.byTooltip(AppStrings.removeWeek).last;
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      expect(harness.current(tester).weeks, hasLength(1));
      await tester.ensureVisible(heading);
      await tester.tap(heading);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.programmeWeeksSectionTitle), findsNothing);
      expect(
        harness.current(tester).weeks!.first.slots!.first.template!.name,
        'Push Day',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('week exercise Edit focuses its shared configuration panel', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 1000));
    final harness = _Harness(draft: _Fixtures.workouts());
    await _Driver.load(tester, harness);
    await _Driver.openWorkouts(tester);
    final weeks = find.text(AppStrings.manageTrainingWeeks);
    await tester.ensureVisible(weeks);
    await tester.tap(weeks);
    await tester.pumpAndSettle();
    final row = find.byKey(const ValueKey('programme_week_exercise_fly'));
    final edit = find.descendant(
      of: row,
      matching: find.bySemanticsLabel(AppStrings.editExercise),
    );
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    final panel = find.byKey(const ValueKey('programme_config_fly'));
    expect(panel, findsOneWidget);
    expect(tester.getRect(panel).top, greaterThanOrEqualTo(0));
    expect(tester.getRect(panel).top, lessThan(1000));
    expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Define Workouts reorders and removes exercises in the draft', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 1000));
    final harness = _Harness(draft: _Fixtures.workouts());
    await _Driver.load(tester, harness);
    await _Driver.openWorkouts(tester);
    await tester.tap(find.text(AppStrings.reorderButton));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(AppStrings.moveExerciseUp).last);
    await tester.pumpAndSettle();
    expect(
      harness
          .current(tester)
          .weeks!
          .first
          .slots!
          .first
          .template!
          .exercises
          .first
          .id,
      'fly',
    );
    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('programme_exercise_fly')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip(AppStrings.removeExercise));
    await tester.tap(find.byTooltip(AppStrings.removeExercise));
    await tester.pumpAndSettle();
    expect(
      harness
          .current(tester)
          .weeks!
          .first
          .slots!
          .first
          .template!
          .exercises
          .single
          .id,
      'exercise',
    );
    expect(
      find.byKey(const ValueKey('programme_config_exercise')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'Define Workouts fits 320px and 2x text in ${dark ? 'dark' : 'light'} mode',
      (tester) async {
        _Driver.viewport(tester, const Size(320, 844));
        final harness = _Harness(
          draft: _Fixtures.workouts(),
          dark: dark,
          scale: 2,
        );
        await _Driver.load(tester, harness);
        await _Driver.openWorkouts(tester);
        expect(find.text(AppStrings.defineWorkouts), findsNWidgets(2));
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(
          find.byKey(const ValueKey('exercise_config_add_set')),
        );
        await tester.tap(find.byKey(const ValueKey('exercise_config_add_set')));
        await tester.pumpAndSettle();
        expect(
          harness
              .current(tester)
              .weeks!
              .first
              .slots!
              .first
              .template!
              .exercises
              .first
              .sets,
          hasLength(2),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'mobile Define Workouts places exercise cards above configuration',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness(draft: _Fixtures.workouts());
      await _Driver.load(tester, harness);
      await _Driver.openWorkouts(tester);
      final card = tester.getRect(
        find.byKey(const ValueKey('programme_exercise_exercise')),
      );
      final config = tester.getRect(
        find.byKey(const ValueKey('programme_config_exercise')),
      );
      expect(card.bottom, lessThan(config.top));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('edge back swipe returns through all steps and preserves edits', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 1000));
    final harness = _Harness(draft: _Fixtures.draft(assigned: true));
    await _Driver.load(tester, harness);
    await tester.enterText(find.byType(TextField).first, 'Summer Strength');
    await tester.pumpAndSettle();
    for (var step = 0; step < 4; step++) {
      await _Driver.next(tester);
    }
    for (var step = 3; step >= 0; step--) {
      await tester.dragFrom(const Offset(4, 350), const Offset(180, 0));
      await tester.pumpAndSettle();
      expect(
        find.byKey(ValueKey('programme_builder_scroll_$step')),
        findsOneWidget,
      );
      expect(harness.current(tester).name, 'Summer Strength');
      expect(
        harness.current(tester).weeks!.single.slots!.single.template!.id,
        'push',
      );
      expect(
        find.text(AppStrings.unsavedProgrammeChangesMessage),
        findsNothing,
      );
    }
    await tester.dragFrom(const Offset(4, 350), const Offset(180, 0));
    await tester.pumpAndSettle();
    expect(
      find.text(AppStrings.unsavedProgrammeChangesMessage),
      findsOneWidget,
    );
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(harness.current(tester).name, 'Summer Strength');
    expect(harness.save.calls, 0);
  });

  testWidgets(
    'first-step back button guards edits and discard returns to library',
    (tester) async {
      _Driver.viewport(tester, const Size(390, 1000));
      final harness = _Harness();
      await _Driver.load(tester, harness);
      await tester.enterText(find.byType(TextField).first, 'Summer Strength');
      await tester.pumpAndSettle();
      final back = find.byKey(const ValueKey('programme_builder_back'));
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(
        find.text(AppStrings.unsavedProgrammeChangesMessage),
        findsOneWidget,
      );
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();
      expect(harness.current(tester).name, 'Summer Strength');
      await tester.tap(back);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.discardProgrammeChanges));
      await tester.pumpAndSettle();
      expect(find.byType(ProgrammeBuilderScreen), findsNothing);
      expect(find.text('Library'), findsOneWidget);
      expect(harness.save.calls, 0);
    },
  );

  for (final swipe in [false, true]) {
    testWidgets(
      'first-step clean back returns to previous screen: swipe=$swipe',
      (tester) async {
        _Driver.viewport(tester, const Size(390, 1000));
        final harness = _Harness();
        await _Driver.load(tester, harness);
        if (swipe) {
          await tester.dragFrom(const Offset(4, 350), const Offset(180, 0));
        } else {
          await tester.tap(
            find.byKey(const ValueKey('programme_builder_back')),
          );
        }
        await tester.pumpAndSettle();
        expect(find.byType(ProgrammeBuilderScreen), findsNothing);
        expect(find.text('Library'), findsOneWidget);
        expect(
          find.text(AppStrings.unsavedProgrammeChangesMessage),
          findsNothing,
        );
      },
    );
  }

  testWidgets('system back returns one step instead of leaving the builder', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 1000));
    final harness = _Harness(draft: _Fixtures.draft(assigned: true));
    await _Driver.load(tester, harness);
    await _Driver.openWorkouts(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('programme_builder_scroll_2')),
      findsOneWidget,
    );
    expect(find.text(AppStrings.unsavedProgrammeChangesMessage), findsNothing);
    expect(find.byType(ProgrammeBuilderScreen), findsOneWidget);
  });

  testWidgets('short, reversed and non-edge swipes do not navigate', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 1000));
    final harness = _Harness(draft: _Fixtures.draft(assigned: true));
    await _Driver.load(tester, harness);
    await _Driver.next(tester);
    for (final drag in [
      (const Offset(4, 350), const Offset(35, 0)),
      (const Offset(4, 350), const Offset(-100, 0)),
      (const Offset(100, 350), const Offset(180, 0)),
      (const Offset(4, 350), const Offset(0, -180)),
    ]) {
      await tester.timedDragFrom(drag.$1, drag.$2, const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('programme_builder_scroll_1')),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.unsavedProgrammeChangesMessage),
        findsNothing,
      );
    }
  });

  for (final dark in [false, true]) {
    testWidgets('review floating publish fits 320px at 2x text: dark=$dark', (
      tester,
    ) async {
      _Driver.viewport(tester, const Size(320, 844));
      tester.view.padding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.resetPadding);
      final harness = _Harness(
        draft: _Fixtures.draft(assigned: true),
        dark: dark,
        scale: 2,
      );
      await _Driver.load(tester, harness);
      for (var step = 0; step < 4; step++) {
        await _Driver.next(tester);
      }
      final publish = find.byKey(const ValueKey('programme_builder_publish'));
      expect(tester.getSize(publish).height, greaterThanOrEqualTo(48));
      expect(tester.getBottomLeft(publish).dy, lessThanOrEqualTo(844 - 34));
      final workload = find.text(AppStrings.programmeReviewBusiestWeek(1));
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const ValueKey('programme_builder_scroll_4')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(workload).dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const ValueKey('programme_builder_action_surface')),
              )
              .dy,
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(publish);
      await tester.pumpAndSettle();
      expect(harness.save.calls, 1);
      expect(find.text('Library'), findsOneWidget);
    });
  }

  testWidgets('system back retains the dirty-draft discard confirmation', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 884));
    final harness = _Harness();
    await _Driver.load(tester, harness);
    await tester.enterText(find.byType(TextField).first, 'My programme');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.text(AppStrings.unsavedProgrammeChangesMessage),
      findsOneWidget,
    );
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(find.byType(ProgrammeBuilderScreen), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'small phone and large text fit details and schedule in ${dark ? 'dark' : 'light'} mode',
      (tester) async {
        _Driver.viewport(tester, const Size(320, 844));
        final harness = _Harness(dark: dark, scale: 2);
        await _Driver.load(tester, harness);
        expect(tester.takeException(), isNull);
        await tester.enterText(find.byType(TextField).first, 'Training Plan');
        await tester.pumpAndSettle();
        await _Driver.next(tester);
        expect(
          find.byKey(const ValueKey('programme_add_training_block')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Details keeps planning controls in their dedicated steps', (
    tester,
  ) async {
    _Driver.viewport(tester, const Size(390, 1000));
    final harness = _Harness();
    await _Driver.load(tester, harness);
    expect(find.text(AppStrings.primaryGoal), findsOneWidget);
    expect(find.byKey(const ValueKey('programme_duration')), findsNothing);
    expect(find.text(AppStrings.addWeek), findsNothing);
    expect(find.text('Monday'), findsNothing);
    expect(
      find.byKey(const ValueKey('programme_add_training_block')),
      findsNothing,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('programme_builder_next')),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
}
