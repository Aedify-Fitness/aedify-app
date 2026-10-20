import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/template_reassignment_bottom_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';

class _SheetHarness {
  _SheetHarness._();

  static Widget wrap(Widget child, {bool dark = false, double scale = 1}) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: child),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
    );
  }

  static Future<void> open(
    WidgetTester tester,
    Widget child, {
    bool dark = false,
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => child,
                );
              },
              child: const Text('Open'),
            );
          },
        ),
        dark: dark,
        scale: scale,
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }
}

class _Fixtures {
  _Fixtures._();

  static ProgrammeBuilderTemplateDraft template(String id, String name) {
    return ProgrammeBuilderTemplateDraft(id: id, templateKey: id, name: name);
  }

  static SavedWorkoutListItem savedWorkout(
    String id,
    String name,
    int exerciseCount,
  ) {
    return SavedWorkoutListItem(
      id: id,
      name: name,
      status: SavedWorkoutStatus.active,
      exerciseCount: exerciseCount,
      updatedAt: DateTime(2025),
      modalities: [],
      focus: '',
    );
  }
}

void main() {
  group('TemplateReassignmentBottomSheet', () {
    testWidgets('shows one choice and count for copied programme exercises', (
      tester,
    ) async {
      _MobileViewport.set(tester);
      final first = _Fixtures.template('week-1', 'Push Day').copyWith(
        exercises: [
          const ProgrammeExerciseDraft(
            id: 'first',
            exerciseId: 1,
            sortOrder: 0,
            sets: [],
          ),
        ],
      );
      final copy = first.copyWith(
        id: 'week-2',
        templateKey: 'week-2',
        exercises: [first.exercises.single.copyWith(id: 'second')],
      );
      ProgrammeBuilderTemplateDraft? selected;
      await _SheetHarness.open(
        tester,
        TemplateReassignmentBottomSheet(
          availableTemplates: [first, copy],
          onSelected: (template) => selected = template,
        ),
      );
      expect(find.text('Push Day'), findsOneWidget);
      expect(tester.widget<AppBadge>(find.byType(AppBadge).first).label, '1');
      await tester.tap(find.text('Push Day'));
      await tester.pumpAndSettle();
      expect(selected, same(first));
      expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
    });

    testWidgets('keeps choices with the same name but different exercises', (
      tester,
    ) async {
      _MobileViewport.set(tester);
      final first = _Fixtures.template('week-1', 'Push Day').copyWith(
        exercises: [
          const ProgrammeExerciseDraft(
            id: 'first',
            exerciseId: 1,
            sortOrder: 0,
            sets: [],
          ),
        ],
      );
      final different = first.copyWith(
        id: 'week-2',
        templateKey: 'week-2',
        exercises: [
          first.exercises.single.copyWith(id: 'second', exerciseId: 2),
        ],
      );
      ProgrammeBuilderTemplateDraft? selected;
      await _SheetHarness.open(
        tester,
        TemplateReassignmentBottomSheet(
          availableTemplates: [first, different],
          onSelected: (template) => selected = template,
        ),
      );
      expect(find.text('Push Day'), findsNWidgets(2));
      expect(tester.widget<AppBadge>(find.byType(AppBadge).first).label, '2');
      await tester.ensureVisible(find.text('Push Day').last);
      await tester.tap(find.text('Push Day').last);
      await tester.pumpAndSettle();
      expect(selected, same(different));
      expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
    });

    testWidgets('close dismisses without changing an assignment', (
      tester,
    ) async {
      var assignments = 0;
      await _SheetHarness.open(
        tester,
        TemplateReassignmentBottomSheet(
          availableTemplates: [_Fixtures.template('t-1', 'Push Day')],
          onSelected: (_) => assignments++,
          onSelectSavedWorkout: (_) => assignments++,
        ),
      );
      await tester.tap(find.byTooltip(AppStrings.close));
      await tester.pumpAndSettle();
      expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
      expect(assignments, 0);
    });

    testWidgets('backdrop dismisses without choosing a workout', (
      tester,
    ) async {
      _MobileViewport.set(tester);
      await _SheetHarness.open(tester, const TemplateReassignmentBottomSheet());
      await tester.tapAt(const Offset(12, 12));
      await tester.pumpAndSettle();
      expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
    });

    testWidgets('uses actual exercise totals and optional stored estimates', (
      tester,
    ) async {
      _MobileViewport.set(tester);
      await _SheetHarness.open(
        tester,
        TemplateReassignmentBottomSheet(
          savedWorkouts: [
            SavedWorkoutListItem(
              id: 'saved',
              name: 'Upper Body A',
              status: SavedWorkoutStatus.active,
              exerciseCount: 4,
              estimatedDurationMinutes: 45,
              updatedAt: DateTime(2025),
              modalities: const [],
              focus: '',
            ),
          ],
          availableTemplates: [_Fixtures.template('push', 'Push Day')],
        ),
      );
      expect(find.text(AppStrings.workoutExerciseTotal(4)), findsOneWidget);
      expect(find.text(AppStrings.workoutExerciseTotal(0)), findsOneWidget);
      expect(find.text(AppStrings.workoutDurationEstimate(45)), findsOneWidget);
      expect(find.text(AppStrings.assignWorkoutHint), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final dark in [false, true]) {
      testWidgets(
        'long choices scroll on a small phone with large text in ${dark ? 'dark' : 'light'} mode',
        (tester) async {
          _MobileViewport.set(tester, size: const Size(320, 740));
          SavedWorkoutListItem? selected;
          await _SheetHarness.open(
            tester,
            TemplateReassignmentBottomSheet(
              availableTemplates: [
                _Fixtures.template(
                  'push',
                  'Push Day with a longer workout name',
                ),
              ],
              savedWorkouts: List.generate(
                20,
                (index) => _Fixtures.savedWorkout(
                  'saved-$index',
                  'Saved workout $index with a longer name',
                  4,
                ),
              ),
              onSelectSavedWorkout: (workout) => selected = workout,
            ),
            dark: dark,
            scale: 2,
          );
          final close = find.byTooltip(AppStrings.close);
          final initialClosePosition = tester.getRect(close);
          final last = find.text('Saved workout 19 with a longer name');
          await tester.ensureVisible(last);
          await tester.pumpAndSettle();
          expect(tester.getRect(close), initialClosePosition);
          expect(tester.takeException(), isNull);
          await tester.tap(last);
          await tester.pumpAndSettle();
          expect(selected?.id, 'saved-19');
          expect(find.byType(TemplateReassignmentBottomSheet), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('shows assign workout title', (tester) async {
      await tester.pumpWidget(
        _SheetHarness.wrap(const TemplateReassignmentBottomSheet()),
      );
      expect(find.text(AppStrings.assignTemplate), findsOneWidget);
    });

    testWidgets('always shows create template button', (tester) async {
      await tester.pumpWidget(
        _SheetHarness.wrap(const TemplateReassignmentBottomSheet()),
      );
      expect(find.text(AppStrings.createTemplate), findsOneWidget);
    });

    testWidgets('create template tap pops with true', (tester) async {
      await tester.pumpWidget(
        _SheetHarness.wrap(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await showModalBottomSheet<bool>(
                    context: context,
                    builder: (_) => const TemplateReassignmentBottomSheet(),
                  );
                  expect(result, isTrue);
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();
      await tester.ensureVisible(find.text(AppStrings.createTemplate));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(AppStrings.createTemplate),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('shows no saved workouts message when none provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _SheetHarness.wrap(
          const TemplateReassignmentBottomSheet(savedWorkouts: []),
        ),
      );
      expect(find.text(AppStrings.noSavedWorkoutsToImport), findsOneWidget);
    });

    testWidgets('shows saved workouts when provided', (tester) async {
      await tester.pumpWidget(
        _SheetHarness.wrap(
          TemplateReassignmentBottomSheet(
            savedWorkouts: [_Fixtures.savedWorkout('sw-1', 'Upper Body A', 4)],
          ),
        ),
      );
      expect(find.text('Upper Body A'), findsOneWidget);
      expect(find.text(AppStrings.workoutExerciseTotal(4)), findsOneWidget);
    });

    testWidgets('calls onSelectSavedWorkout when saved workout is tapped', (
      tester,
    ) async {
      SavedWorkoutListItem? selected;
      await _SheetHarness.open(
        tester,
        TemplateReassignmentBottomSheet(
          savedWorkouts: [_Fixtures.savedWorkout('sw-1', 'Upper Body A', 4)],
          onSelectSavedWorkout: (item) => selected = item,
        ),
      );
      await tester.ensureVisible(find.text('Upper Body A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upper Body A'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(selected?.id, 'sw-1');
    });

    testWidgets(
      'shows programme templates section header when templates exist',
      (tester) async {
        await tester.pumpWidget(
          _SheetHarness.wrap(
            TemplateReassignmentBottomSheet(
              availableTemplates: [_Fixtures.template('t-1', 'Push Day')],
            ),
          ),
        );
        expect(find.text(AppStrings.programmeTemplates), findsOneWidget);
        expect(find.text('Push Day'), findsOneWidget);
      },
    );

    testWidgets('does not show programme templates section when none exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        _SheetHarness.wrap(
          const TemplateReassignmentBottomSheet(availableTemplates: []),
        ),
      );
      expect(find.text(AppStrings.programmeTemplates), findsNothing);
    });

    testWidgets('shows both saved workouts and programme templates', (
      tester,
    ) async {
      await tester.pumpWidget(
        _SheetHarness.wrap(
          TemplateReassignmentBottomSheet(
            savedWorkouts: [_Fixtures.savedWorkout('sw-1', 'Upper Body A', 4)],
            availableTemplates: [_Fixtures.template('t-1', 'Push Day')],
          ),
        ),
      );
      expect(find.text(AppStrings.fromSavedWorkouts), findsOneWidget);
      expect(find.text('Upper Body A'), findsOneWidget);
      expect(find.text(AppStrings.programmeTemplates), findsOneWidget);
      expect(find.text('Push Day'), findsOneWidget);
    });

    testWidgets('calls onSelected when programme template is tapped', (
      tester,
    ) async {
      ProgrammeBuilderTemplateDraft? selected;
      await _SheetHarness.open(
        tester,
        TemplateReassignmentBottomSheet(
          availableTemplates: [_Fixtures.template('t-1', 'Push Day')],
          onSelected: (template) => selected = template,
        ),
      );
      await tester.ensureVisible(find.text('Push Day'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push Day'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(selected?.name, 'Push Day');
    });
  });
}

class _MobileViewport {
  _MobileViewport._();

  static void set(WidgetTester tester, {Size size = const Size(390, 844)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
}
