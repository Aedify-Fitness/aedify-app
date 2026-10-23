import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/application/workout_detail_controller.dart';
import 'package:aedify/features/programmes/domain/programme_workout_detail_view_data.dart';
import 'package:aedify/features/programmes/presentation/workout_detail_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/workout_detail_button_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _DetailController extends WorkoutDetailController {
  _DetailController(this.nextDetail, {String? programId, this.initial})
    : super((programId: programId, workoutId: _DetailFixtures.workoutId));

  ProgrammeWorkoutDetailViewData? nextDetail;
  final Future<ProgrammeWorkoutDetailViewData?>? initial;
  int reloadCount = 0;

  @override
  Future<ProgrammeWorkoutDetailViewData?> build() async {
    if (initial != null) return await initial!;
    return nextDetail;
  }

  @override
  Future<void> reload() async {
    reloadCount++;
    state = const AsyncValue.loading();
    state = AsyncValue.data(await Future.value(nextDetail));
  }

  void fail() {
    state = AsyncValue.error(StateError('fixture failure'), StackTrace.current);
  }
}

class _DetailFixtures {
  _DetailFixtures._();

  static const workoutId = 'legs-a';
  static const programId = 'programme-1';
  static const openKey = ValueKey('open_workout_detail');
  static const returnKey = ValueKey('return_to_workout_detail');
  static const scrollKey = ValueKey('workout_detail_scroll_view');
  static const actionKey = ValueKey('workout_detail_primary_action');

  static ProgrammeWorkoutDetailViewData detail({
    WorkoutDetailButtonState buttonState = WorkoutDetailButtonState.start,
    String name = 'Legs A',
    int duration = 75,
    String? programmeName = 'Strength Programme',
    String dayLabel = 'Monday',
    List<ExerciseDetailItem>? exercises,
  }) => ProgrammeWorkoutDetailViewData(
    workoutName: name,
    dayLabel: dayLabel,
    programmeName: programmeName,
    durationMinutes: duration,
    exercises: exercises ?? [_exercise(1), _exercise(2)],
    focusAreas: 'Quads, Core',
    buttonState: buttonState,
  );

  static ExerciseDetailItem _exercise(int id, {bool longLabels = false}) =>
      ExerciseDetailItem(
        exerciseId: id,
        name: longLabels
            ? 'Single-leg supported rear-foot elevated split squat $id'
            : 'Exercise $id',
        equipment: longLabels
            ? 'Adjustable dumbbells and flat exercise bench'
            : 'Dumbbell',
        loggingType: ExerciseLoggingType.repsWeight,
        sets: [
          for (var set = 0; set < id + 1; set++)
            SetPrescriptionItem(
              setIndex: set,
              setType: set == 0 ? 'warmup' : 'working',
              repsDisplay: set == 0 ? '10' : '6-8',
              weightDisplay: set == 0 ? '20.0 kg' : '40.0 kg',
              rpeDisplay: set == 0 ? null : 'RIR 2',
              restSeconds: 90,
            ),
        ],
      );

  static GoRouter router({
    String? programme,
    ValueChanged<GoRouterState>? onDestination,
    bool directEntry = false,
  }) {
    final detailRoute = programme == null
        ? AppRoutes.workoutDetail()
        : AppRoutes.programmeWorkoutDetail();
    final parameters = {'workoutId': workoutId, 'programId': ?programme};
    final detailPath = programme == null
        ? '/workouts/$workoutId'
        : '/programmes/$programme/workouts/$workoutId';
    return GoRouter(
      initialLocation: directEntry ? detailPath : '/',
      routes: [
        GoRoute(
          path: '/',
          name: AppRoutes.home().name,
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                key: openKey,
                onPressed: () => context.pushNamed(
                  detailRoute.name,
                  pathParameters: parameters,
                ),
                child: const Text('Open workout'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.workout().path,
          name: AppRoutes.workout().name,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Workout library'))),
        ),
        GoRoute(
          path: detailRoute.path,
          name: detailRoute.name,
          builder: (context, state) => WorkoutDetailScreen(
            workoutId: state.pathParameters['workoutId']!,
            programId: state.pathParameters['programId'],
          ),
        ),
        for (final destination in [
          AppRoutes.workoutRunnerSavedWorkout(),
          AppRoutes.workoutRunnerProgramWorkout(),
          AppRoutes.workoutRunnerActive(),
          AppRoutes.exerciseDetail(),
        ])
          GoRoute(
            path: destination.path,
            name: destination.name,
            builder: (context, state) {
              onDestination?.call(state);
              return Scaffold(
                body: Center(
                  child: TextButton(
                    key: returnKey,
                    onPressed: context.pop,
                    child: Text(destination.name),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  static Widget app({
    required _DetailController controller,
    required GoRouter router,
    String? programme,
    bool dark = false,
    double textScale = 1,
    bool accessible = false,
  }) => ProviderScope(
    overrides: [
      AppProviders.workoutDetailControllerProvider((
        programId: programme,
        workoutId: workoutId,
      )).overrideWith(() => controller),
    ],
    child: MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          accessibleNavigation: accessible,
          highContrast: accessible,
          disableAnimations: accessible,
        ),
        child: child!,
      ),
    ),
  );

  static void mobile(
    WidgetTester tester, {
    double width = 390,
    double height = 844,
  }) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  static Future<void> open(
    WidgetTester tester, {
    required _DetailController controller,
    GoRouter? router,
    String? programme,
    bool settle = true,
    bool dark = false,
    double textScale = 1,
    bool accessible = false,
  }) async {
    final configuration =
        router ?? _DetailFixtures.router(programme: programme);
    addTearDown(configuration.dispose);
    await tester.pumpWidget(
      app(
        controller: controller,
        router: configuration,
        programme: programme,
        dark: dark,
        textScale: textScale,
        accessible: accessible,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(openKey));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
    }
  }

  static Finder verticalScrollable() => find
      .descendant(
        of: find.byKey(scrollKey),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      )
      .first;

  static Future<void> reveal(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target,
      250,
      scrollable: verticalScrollable(),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  group('WorkoutDetailScreen', () {
    testWidgets('shows the workout context and honest prescription totals', (
      tester,
    ) async {
      _DetailFixtures.mobile(tester);
      await _DetailFixtures.open(
        tester,
        controller: _DetailController(_DetailFixtures.detail(duration: 0)),
      );
      final hero = find.byKey(const ValueKey('workout_detail_hero'));
      expect(
        find.byKey(const ValueKey('workout_detail_screen')),
        findsOneWidget,
      );
      expect(find.text('Legs A'), findsOneWidget);
      expect(find.text('LEGS A'), findsNothing);
      expect(find.textContaining('Strength Programme'), findsOneWidget);
      expect(find.textContaining('Monday'), findsOneWidget);
      expect(
        find.descendant(of: hero, matching: find.text('2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hero, matching: find.text('5')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: hero,
          matching: find.text(AppStrings.unavailableValue),
        ),
        findsOneWidget,
      );
      expect(find.text(AppStrings.workoutEstimatedDuration), findsOneWidget);
      expect(find.textContaining('~0'), findsNothing);
      expect(find.text(AppStrings.workoutFlow), findsOneWidget);
      expect(
        find.byKey(const ValueKey('workout_detail_atmospheric_section')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    for (final programme in [null, _DetailFixtures.programId]) {
      for (final action in WorkoutDetailButtonState.values) {
        testWidgets(
          '${programme == null ? 'saved' : 'programme'} workout ${action.name} action respects routes and reloads',
          (tester) async {
            _DetailFixtures.mobile(tester);
            final controller = _DetailController(
              _DetailFixtures.detail(buttonState: action),
              programId: programme,
            );
            GoRouterState? visited;
            final router = _DetailFixtures.router(
              programme: programme,
              onDestination: (state) => visited = state,
            );
            await _DetailFixtures.open(
              tester,
              controller: controller,
              router: router,
              programme: programme,
            );
            if (action == WorkoutDetailButtonState.hidden) {
              expect(find.byKey(_DetailFixtures.actionKey), findsNothing);
              expect(find.text(AppStrings.startWorkout), findsNothing);
              expect(find.text(AppStrings.resumeWorkout), findsNothing);
              expect(controller.reloadCount, 0);
              return;
            }
            final actionButton = find.byKey(_DetailFixtures.actionKey);
            expect(
              find.descendant(
                of: actionButton,
                matching: find.text(
                  action == WorkoutDetailButtonState.resume
                      ? AppStrings.resumeWorkout
                      : AppStrings.startWorkout,
                ),
              ),
              findsOneWidget,
            );
            expect(
              tester.getSize(actionButton).height,
              greaterThanOrEqualTo(48),
            );
            await tester.tap(actionButton);
            await tester.pumpAndSettle();
            final route = action == WorkoutDetailButtonState.resume
                ? AppRoutes.workoutRunnerActive()
                : programme == null
                ? AppRoutes.workoutRunnerSavedWorkout()
                : AppRoutes.workoutRunnerProgramWorkout();
            expect(visited?.name, route.name);
            expect(
              visited?.pathParameters,
              action == WorkoutDetailButtonState.resume
                  ? isEmpty
                  : programme == null
                  ? {'id': _DetailFixtures.workoutId}
                  : {
                      'programId': programme,
                      'workoutId': _DetailFixtures.workoutId,
                    },
            );
            expect(controller.reloadCount, 0);
            controller.nextDetail = _DetailFixtures.detail(
              name: 'Updated after session',
              buttonState: WorkoutDetailButtonState.hidden,
            );
            await tester.tap(find.byKey(_DetailFixtures.returnKey));
            await tester.pumpAndSettle();
            expect(controller.reloadCount, 1);
            expect(find.text('Updated after session'), findsOneWidget);
            expect(find.byKey(_DetailFixtures.actionKey), findsNothing);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets('opens the exercise guide and refreshes when it returns', (
      tester,
    ) async {
      _DetailFixtures.mobile(tester);
      final controller = _DetailController(_DetailFixtures.detail());
      GoRouterState? visited;
      final router = _DetailFixtures.router(
        onDestination: (state) => visited = state,
      );
      await _DetailFixtures.open(
        tester,
        controller: controller,
        router: router,
      );
      final guide = find.byKey(
        const ValueKey('workout_detail_exercise_guide_1'),
      );
      await _DetailFixtures.reveal(tester, guide);
      await tester.tap(guide);
      await tester.pumpAndSettle();
      expect(visited?.name, AppRoutes.exerciseDetail().name);
      expect(visited?.pathParameters, {'id': '1'});
      expect(controller.reloadCount, 0);
      await tester.tap(find.byKey(_DetailFixtures.returnKey));
      await tester.pumpAndSettle();
      expect(controller.reloadCount, 1);
      expect(find.byType(WorkoutDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps Back available while loading and before leaving', (
      tester,
    ) async {
      _DetailFixtures.mobile(tester);
      final initial = Completer<ProgrammeWorkoutDetailViewData?>();
      await _DetailFixtures.open(
        tester,
        controller: _DetailController(
          _DetailFixtures.detail(),
          initial: initial.future,
        ),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final back = find.byTooltip(AppStrings.backLabel);
      expect(back, findsOneWidget);
      expect(tester.getSize(back).shortestSide, greaterThanOrEqualTo(48));
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(find.byKey(_DetailFixtures.openKey), findsOneWidget);
      initial.complete(null);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('retries errors and retains an exit for missing workouts', (
      tester,
    ) async {
      _DetailFixtures.mobile(tester);
      final controller = _DetailController(_DetailFixtures.detail());
      await _DetailFixtures.open(tester, controller: controller);
      controller.fail();
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.workoutDetailLoadError), findsOneWidget);
      expect(find.byTooltip(AppStrings.backLabel), findsOneWidget);
      expect(find.byKey(_DetailFixtures.actionKey), findsNothing);
      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();
      expect(controller.reloadCount, 1);
      expect(find.text('Legs A'), findsOneWidget);
      controller.nextDetail = null;
      await controller.reload();
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.missingSession), findsOneWidget);
      expect(find.byTooltip(AppStrings.backLabel), findsOneWidget);
      expect(find.byKey(_DetailFixtures.actionKey), findsNothing);
      await tester.tap(find.byTooltip(AppStrings.backLabel));
      await tester.pumpAndSettle();
      expect(find.byKey(_DetailFixtures.openKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('returns a directly opened workout to the workout library', (
      tester,
    ) async {
      _DetailFixtures.mobile(tester);
      final router = _DetailFixtures.router(directEntry: true);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _DetailFixtures.app(
          controller: _DetailController(_DetailFixtures.detail()),
          router: router,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(AppStrings.backLabel));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/workout');
      expect(find.text('Workout library'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reloads prescriptions through pull to refresh', (
      tester,
    ) async {
      _DetailFixtures.mobile(tester);
      final controller = _DetailController(_DetailFixtures.detail());
      await _DetailFixtures.open(tester, controller: controller);
      controller.nextDetail = _DetailFixtures.detail(name: 'Refreshed workout');
      await tester.drag(
        find.byKey(_DetailFixtures.scrollKey),
        const Offset(0, 450),
      );
      await tester.pumpAndSettle();
      expect(controller.reloadCount, 1);
      expect(find.text('Refreshed workout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'explains an empty exercise flow without inventing prescriptions',
      (tester) async {
        _DetailFixtures.mobile(tester);
        await _DetailFixtures.open(
          tester,
          controller: _DetailController(
            _DetailFixtures.detail(
              exercises: [],
              duration: 0,
              programmeName: null,
              dayLabel: '',
              buttonState: WorkoutDetailButtonState.hidden,
            ),
          ),
        );
        expect(find.text(AppStrings.noExercisesInWorkout), findsOneWidget);
        expect(find.text('Strength Programme'), findsNothing);
        expect(find.text('Monday'), findsNothing);
        expect(find.byKey(_DetailFixtures.actionKey), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    for (final dark in [false, true]) {
      testWidgets(
        'supports small-screen accessibility and footer clearance in ${dark ? 'dark' : 'light'} mode',
        (tester) async {
          _DetailFixtures.mobile(tester, width: 320, height: 640);
          await _DetailFixtures.open(
            tester,
            controller: _DetailController(
              _DetailFixtures.detail(
                name: 'Lower body strength and controlled single-leg stability',
                programmeName:
                    'A progressive strength and conditioning programme',
                exercises: [
                  for (var id = 1; id <= 7; id++)
                    _DetailFixtures._exercise(id, longLabels: true),
                ],
              ),
            ),
            dark: dark,
            textScale: 2,
            accessible: true,
          );
          expect(tester.takeException(), isNull);
          final back = find.byTooltip(AppStrings.backLabel);
          final action = find.byKey(_DetailFixtures.actionKey);
          expect(tester.getSize(back).shortestSide, greaterThanOrEqualTo(48));
          expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
          expect(action.hitTestable(), findsOneWidget);
          final lastExercise = find.byKey(
            const ValueKey('workout_detail_exercise_7'),
          );
          final lastGuide = find.byKey(
            const ValueKey('workout_detail_exercise_guide_7'),
          );
          final lastDisclosure = find.byKey(
            const ValueKey('workout_detail_sets_7'),
          );
          await _DetailFixtures.reveal(tester, lastGuide);
          final visibleGuide = tester
              .getRect(lastGuide)
              .intersect(tester.getRect(find.byKey(_DetailFixtures.scrollKey)));
          expect(visibleGuide.height, greaterThanOrEqualTo(48));
          await tester.tapAt(visibleGuide.center);
          await tester.pumpAndSettle();
          expect(find.byKey(_DetailFixtures.returnKey), findsOneWidget);
          await tester.tap(find.byKey(_DetailFixtures.returnKey));
          await tester.pumpAndSettle();
          final scrollable = _DetailFixtures.verticalScrollable();
          final position = tester.state<ScrollableState>(scrollable).position;
          position.jumpTo(position.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(lastDisclosure.hitTestable(), findsOneWidget);
          expect(
            tester.getSize(lastDisclosure).height,
            greaterThanOrEqualTo(48),
          );
          expect(
            tester.getBottomRight(lastExercise).dy,
            lessThanOrEqualTo(tester.getTopLeft(action).dy),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
