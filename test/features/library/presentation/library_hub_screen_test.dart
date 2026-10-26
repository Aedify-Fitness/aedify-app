import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/router/bottom_nav_shell.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_library_screen.dart';
import 'package:aedify/features/library/presentation/library_hub_screen.dart';
import 'package:aedify/features/programmes/application/saved_workout_library_controller.dart';
import 'package:aedify/features/programmes/application/saved_workout_library_state.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/presentation/saved_workout_library_screen.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _ExerciseRepository implements ExerciseRepository {
  List<ExerciseListItem> items = _LibraryFixtures.exercises();
  final searches = <ExerciseFilterState>[];
  Completer<List<ExerciseListItem>>? pendingSearch;
  bool shouldFail = false;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async {
    searches.add(filters);
    if (shouldFail) throw StateError('Exercise search unavailable');
    final pending = pendingSearch;
    if (pending != null) return pending.future;
    return items;
  }

  @override
  Future<ExerciseDetailViewData?> getExerciseDetail(int exerciseId) async =>
      null;

  @override
  Future<void> setFavorite({
    required int exerciseId,
    required bool isFavorite,
  }) async {}

  @override
  Future<void> setSubstitutedOut({
    required int exerciseId,
    required bool isSubstitutedOut,
  }) async {}

  @override
  Future<List<ExerciseListItem>> getCustomExercises() async => [];

  @override
  Future<ExerciseDetailViewData?> getCustomExerciseDetail(
    int exerciseId,
  ) async => null;

  @override
  Future<int> createCustomExercise(CustomExerciseSeed seed) async => -1;

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  }) async {}

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {}
}

class _SyncedDataset extends ExerciseDatasetSyncController {
  @override
  Future<ExerciseDatasetSyncState> build() async =>
      const ExerciseDatasetSyncState(phase: ExerciseDatasetSyncPhase.synced);
}

class _SavedWorkoutController extends SavedWorkoutLibraryController {
  List<SavedWorkoutListItem> items = _LibraryFixtures.workouts();
  bool shouldFail = false;
  int reloadCalls = 0;

  SavedWorkoutLibraryState get _loadedState => SavedWorkoutLibraryState(
    items: shouldFail ? [] : items,
    isLoading: false,
    errorCode: shouldFail ? AppErrorCodes.loadFailed : null,
    errorMessage: shouldFail ? AppStrings.workoutLibraryLoadFailed : null,
  );

  @override
  Future<SavedWorkoutLibraryState> build() async => _loadedState;

  @override
  Future<void> reload() async {
    reloadCalls++;
    state = AsyncData(_loadedState);
  }
}

class _LibraryFixtures {
  _LibraryFixtures() {
    router = GoRouter(
      initialLocation: AppRoutes.library().path,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => BottomNavShell(navigationShell: shell),
          branches: [
            for (final destination in [
              (route: AppRoutes.home(), label: 'Home fixture'),
              (route: AppRoutes.library(), label: ''),
              (route: AppRoutes.programmes(), label: 'Plan fixture'),
              (route: AppRoutes.chat(), label: 'AI fixture'),
              (route: AppRoutes.analytics(), label: 'Stats fixture'),
            ])
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: destination.route.path,
                    name: destination.route.name,
                    builder: (_, _) => destination.label.isEmpty
                        ? const LibraryHubScreen()
                        : Scaffold(
                            body: Center(child: Text(destination.label)),
                          ),
                  ),
                ],
              ),
          ],
        ),
        for (final route in [
          AppRoutes.bodymap(),
          AppRoutes.customExerciseCreate(),
          AppRoutes.workoutBuilderCreate(),
          AppRoutes.exerciseDetail(),
          AppRoutes.workoutDetail(),
          AppRoutes.workoutRunnerSavedWorkout(),
          AppRoutes.workoutRunnerActive(),
          AppRoutes.workoutBuilderEdit(),
        ])
          GoRoute(
            path: route.path,
            name: route.name,
            builder: (context, state) => Scaffold(
              key: ValueKey('destination_${route.name}'),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.pathParameters.values.join(',')),
                    FilledButton(
                      key: const ValueKey('return_to_library'),
                      onPressed: () => context.pop(true),
                      child: const Text('Return to library'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  final exerciseRepository = _ExerciseRepository();
  final workoutController = _SavedWorkoutController();
  late final GoRouter router;

  static const exercisesTab = ValueKey('library_hub_exercises_tab');
  static const workoutsTab = ValueKey('library_hub_workouts_tab');
  static const createAction = ValueKey('library_hub_create_action');

  static List<ExerciseListItem> exercises({int count = 1}) => [
    for (var index = 0; index < count; index++)
      ExerciseListItem(
        id: index + 1,
        name: count == 1 ? 'Bench Press' : 'Exercise ${index + 1}',
        difficulty: ExerciseDifficulty.intermediate,
        muscleGroups: const {BodymapBucket.chest},
        modality: ExerciseModality.strength,
        equipment: EquipmentTag.barbell,
        isFavorite: false,
        isSubstitutedOut: false,
        isCustom: false,
      ),
  ];

  static List<SavedWorkoutListItem> workouts({int count = 1}) => [
    for (var index = 0; index < count; index++)
      SavedWorkoutListItem(
        id: 'workout-${index + 1}',
        name: count == 1 ? 'Upper body' : 'Workout ${index + 1}',
        status: SavedWorkoutStatus.active,
        exerciseCount: 4,
        updatedAt: DateTime(2026, 10, 24),
        modalities: const ['strength'],
        focus: 'Strength',
        estimatedDurationMinutes: 45,
      ),
  ];

  Widget app({
    ThemeData? theme,
    double textScale = 1,
    bool highContrast = false,
    bool reducedMotion = false,
    double keyboardInset = 0,
  }) => ProviderScope(
    overrides: [
      AppProviders.exerciseRepositoryProvider.overrideWithValue(
        exerciseRepository,
      ),
      AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
        _SyncedDataset.new,
      ),
      AppProviders.savedWorkoutLibraryControllerProvider.overrideWith(
        () => workoutController,
      ),
      AppProviders.activeWorkoutSessionProvider.overrideWith((_) async => null),
    ],
    child: MaterialApp.router(
      theme: theme ?? AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          highContrast: highContrast,
          disableAnimations: reducedMotion,
          accessibleNavigation: reducedMotion,
          padding: const EdgeInsets.only(top: 24, bottom: 24),
          viewPadding: const EdgeInsets.only(top: 24, bottom: 24),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: child!,
      ),
    ),
  );

  static void useSurface(WidgetTester tester, {bool compact = false}) {
    tester.view.physicalSize = compact
        ? const Size(320, 568)
        : const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  static Future<void> switchTo(
    WidgetTester tester,
    Key tab, {
    bool settle = true,
  }) async {
    await tester.tap(find.byKey(tab));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
    }
  }

  static bool isSelected(WidgetTester tester, Key tab) {
    final semantics = tester.widget<Semantics>(find.byKey(tab));
    return semantics.properties.selected ?? false;
  }

  static Finder get visibleSearch => find.byType(TextField).hitTestable();

  static Finder paneScroll(Type screenType) => find
      .descendant(
        of: find.byType(screenType),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      )
      .last;

  static Future<void> reachLastItem(
    WidgetTester tester, {
    required Type screenType,
    required String label,
  }) async {
    await tester.scrollUntilVisible(
      find.text(label),
      300,
      scrollable: paneScroll(screenType),
      maxScrolls: 40,
    );
    await tester.drag(paneScroll(screenType), const Offset(0, -600));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('shows Exercises first and supports selected tabs and swipes', (
    tester,
  ) async {
    _LibraryFixtures.useSurface(tester);
    final fixture = _LibraryFixtures();
    addTearDown(fixture.router.dispose);
    await tester.pumpWidget(fixture.app());
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text(AppStrings.navLibrary).hitTestable(), findsOneWidget);
    expect(
      find.byKey(_LibraryFixtures.createAction).hitTestable(),
      findsOneWidget,
    );
    expect(find.text('Bench Press').hitTestable(), findsOneWidget);
    expect(
      _LibraryFixtures.isSelected(tester, _LibraryFixtures.exercisesTab),
      isTrue,
    );
    expect(
      _LibraryFixtures.isSelected(tester, _LibraryFixtures.workoutsTab),
      isFalse,
    );
    expect(find.byTooltip(AppStrings.createExercise), findsOneWidget);
    expect(find.byKey(const ValueKey('create_action_fab')), findsNothing);

    await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);
    expect(find.text(AppStrings.navLibrary).hitTestable(), findsOneWidget);
    expect(
      find.byKey(_LibraryFixtures.createAction).hitTestable(),
      findsOneWidget,
    );
    expect(find.text('Upper body').hitTestable(), findsOneWidget);
    expect(
      _LibraryFixtures.isSelected(tester, _LibraryFixtures.workoutsTab),
      isTrue,
    );
    expect(find.byTooltip(AppStrings.createWorkout), findsOneWidget);
    expect(find.byKey(const ValueKey('create_action_fab')), findsNothing);

    await tester.drag(find.byType(TabBarView), const Offset(330, 0));
    await tester.pumpAndSettle();
    expect(find.text('Bench Press').hitTestable(), findsOneWidget);
    expect(
      _LibraryFixtures.isSelected(tester, _LibraryFixtures.exercisesTab),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('retains exercise list position when changing panes', (
    tester,
  ) async {
    _LibraryFixtures.useSurface(tester);
    final fixture = _LibraryFixtures();
    addTearDown(fixture.router.dispose);
    fixture.exerciseRepository.items = _LibraryFixtures.exercises(count: 12);
    await tester.pumpWidget(fixture.app());
    await tester.pumpAndSettle();
    await _LibraryFixtures.reachLastItem(
      tester,
      screenType: ExerciseLibraryScreen,
      label: 'Exercise 12',
    );
    final position = tester
        .state<ScrollableState>(
          _LibraryFixtures.paneScroll(ExerciseLibraryScreen),
        )
        .position
        .pixels;
    expect(position, greaterThan(0));

    await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);
    await _LibraryFixtures.switchTo(tester, _LibraryFixtures.exercisesTab);
    expect(
      tester
          .state<ScrollableState>(
            _LibraryFixtures.paneScroll(ExerciseLibraryScreen),
          )
          .position
          .pixels,
      closeTo(position, 1),
    );
    expect(find.text('Exercise 12').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'retains exercise search and pane selection across shell branches',
    (tester) async {
      _LibraryFixtures.useSurface(tester);
      final fixture = _LibraryFixtures();
      addTearDown(fixture.router.dispose);
      await tester.pumpWidget(fixture.app());
      await tester.pumpAndSettle();
      await tester.enterText(_LibraryFixtures.visibleSearch, 'Bench');
      await tester.pumpAndSettle();
      await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);

      await tester.tap(find.byType(NavigationDestination).first);
      await tester.pumpAndSettle();
      expect(find.text('Home fixture'), findsOneWidget);
      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle();
      expect(find.text('Upper body').hitTestable(), findsOneWidget);
      expect(
        _LibraryFixtures.isSelected(tester, _LibraryFixtures.workoutsTab),
        isTrue,
      );

      await _LibraryFixtures.switchTo(tester, _LibraryFixtures.exercisesTab);
      expect(
        tester
            .widget<TextField>(_LibraryFixtures.visibleSearch)
            .controller!
            .text,
        'Bench',
      );
      expect(fixture.exerciseRepository.searches.last.searchQuery, 'Bench');
      expect(tester.takeException(), isNull);
    },
  );

  for (final isWorkout in [false, true]) {
    testWidgets(
      'contextual create opens one named ${isWorkout ? 'workout' : 'exercise'} route and refreshes its pane',
      (tester) async {
        _LibraryFixtures.useSurface(tester);
        final fixture = _LibraryFixtures();
        addTearDown(fixture.router.dispose);
        await tester.pumpWidget(fixture.app());
        await tester.pumpAndSettle();
        if (isWorkout) {
          await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);
        }
        final searchesBefore = fixture.exerciseRepository.searches.length;
        final workoutReloadsBefore = fixture.workoutController.reloadCalls;
        final create = find.byKey(_LibraryFixtures.createAction);
        await tester.tap(create);
        await tester.tap(create, warnIfMissed: false);
        await tester.pumpAndSettle();

        final route = isWorkout
            ? AppRoutes.workoutBuilderCreate()
            : AppRoutes.customExerciseCreate();
        expect(
          find.byKey(ValueKey('destination_${route.name}')),
          findsOneWidget,
        );
        expect(
          find.byKey(
            ValueKey('destination_${route.name}'),
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('return_to_library')));
        await tester.pumpAndSettle();

        expect(find.byType(LibraryHubScreen), findsOneWidget);
        expect(
          _LibraryFixtures.isSelected(
            tester,
            isWorkout
                ? _LibraryFixtures.workoutsTab
                : _LibraryFixtures.exercisesTab,
          ),
          isTrue,
        );
        expect(
          fixture.exerciseRepository.searches.length,
          searchesBefore + (isWorkout ? 0 : 1),
        );
        expect(
          fixture.workoutController.reloadCalls,
          workoutReloadsBefore + (isWorkout ? 1 : 0),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'opens named ${isWorkout ? 'workout' : 'exercise'} detail and retains its pane on return',
      (tester) async {
        _LibraryFixtures.useSurface(tester);
        final fixture = _LibraryFixtures();
        addTearDown(fixture.router.dispose);
        await tester.pumpWidget(fixture.app());
        await tester.pumpAndSettle();
        if (isWorkout) {
          await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);
        }
        await tester.tap(find.text(isWorkout ? 'Upper body' : 'Bench Press'));
        await tester.pumpAndSettle();

        final route = isWorkout
            ? AppRoutes.workoutDetail()
            : AppRoutes.exerciseDetail();
        expect(
          find.byKey(ValueKey('destination_${route.name}')),
          findsOneWidget,
        );
        expect(find.text(isWorkout ? 'workout-1' : '1'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('return_to_library')));
        await tester.pumpAndSettle();
        expect(
          find.text(isWorkout ? 'Upper body' : 'Bench Press').hitTestable(),
          findsOneWidget,
        );
        expect(
          _LibraryFixtures.isSelected(
            tester,
            isWorkout
                ? _LibraryFixtures.workoutsTab
                : _LibraryFixtures.exercisesTab,
          ),
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('saved workouts remain usable while exercise search loads', (
    tester,
  ) async {
    _LibraryFixtures.useSurface(tester);
    final fixture = _LibraryFixtures();
    addTearDown(fixture.router.dispose);
    final pending = Completer<List<ExerciseListItem>>();
    fixture.exerciseRepository.pendingSearch = pending;
    await tester.pumpWidget(fixture.app());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await _LibraryFixtures.switchTo(
      tester,
      _LibraryFixtures.workoutsTab,
      settle: false,
    );
    expect(find.text('Upper body').hitTestable(), findsOneWidget);
    expect(find.byTooltip(AppStrings.createWorkout), findsOneWidget);
    pending.complete(_LibraryFixtures.exercises());
    await tester.pumpAndSettle();
    await _LibraryFixtures.switchTo(tester, _LibraryFixtures.exercisesTab);
    expect(find.text('Bench Press').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final failedWorkout in [false, true]) {
    testWidgets(
      '${failedWorkout ? 'saved workout' : 'exercise'} failure leaves the other pane usable and retries its own data',
      (tester) async {
        _LibraryFixtures.useSurface(tester);
        final fixture = _LibraryFixtures();
        addTearDown(fixture.router.dispose);
        fixture.exerciseRepository.shouldFail = !failedWorkout;
        fixture.workoutController.shouldFail = failedWorkout;
        await tester.pumpWidget(fixture.app());
        await tester.pumpAndSettle();
        if (failedWorkout) {
          expect(find.text('Bench Press').hitTestable(), findsOneWidget);
          await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);
        } else {
          expect(find.text(AppStrings.tryAgain).hitTestable(), findsOneWidget);
          await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);
          expect(find.text('Upper body').hitTestable(), findsOneWidget);
          await _LibraryFixtures.switchTo(
            tester,
            _LibraryFixtures.exercisesTab,
          );
        }
        fixture.exerciseRepository.shouldFail = false;
        fixture.workoutController.shouldFail = false;
        final searchesBefore = fixture.exerciseRepository.searches.length;
        final workoutReloadsBefore = fixture.workoutController.reloadCalls;
        await tester.tap(
          find
              .text(failedWorkout ? AppStrings.retry : AppStrings.tryAgain)
              .hitTestable(),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(failedWorkout ? 'Upper body' : 'Bench Press').hitTestable(),
          findsOneWidget,
        );
        expect(
          fixture.exerciseRepository.searches.length,
          searchesBefore + (failedWorkout ? 0 : 1),
        );
        expect(
          fixture.workoutController.reloadCalls,
          workoutReloadsBefore + (failedWorkout ? 1 : 0),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Bodymap opens its named local route and returns to Exercises', (
    tester,
  ) async {
    _LibraryFixtures.useSurface(tester);
    final fixture = _LibraryFixtures();
    addTearDown(fixture.router.dispose);
    await tester.pumpWidget(fixture.app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('exercise_library_bodymap')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(ValueKey('destination_${AppRoutes.bodymap().name}')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('return_to_library')));
    await tester.pumpAndSettle();
    expect(
      _LibraryFixtures.isSelected(tester, _LibraryFixtures.exercisesTab),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('both empty panes retain their contextual create action', (
    tester,
  ) async {
    _LibraryFixtures.useSurface(tester);
    final fixture = _LibraryFixtures();
    addTearDown(fixture.router.dispose);
    fixture.exerciseRepository.items = [];
    fixture.workoutController.items = [];
    await tester.pumpWidget(fixture.app());
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noExercisesFound), findsOneWidget);
    expect(find.byTooltip(AppStrings.createExercise), findsOneWidget);
    await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);
    expect(find.text(AppStrings.noSavedWorkoutsYet), findsOneWidget);
    expect(find.byTooltip(AppStrings.createWorkout), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'compact ${dark ? 'dark' : 'light'} large text keeps both lists clear of navigation',
      (tester) async {
        _LibraryFixtures.useSurface(tester, compact: true);
        final fixture = _LibraryFixtures();
        addTearDown(fixture.router.dispose);
        fixture.exerciseRepository.items = _LibraryFixtures.exercises(
          count: 12,
        );
        fixture.workoutController.items = _LibraryFixtures.workouts(count: 12);
        await tester.pumpWidget(
          fixture.app(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            textScale: 2,
            highContrast: true,
            reducedMotion: true,
          ),
        );
        await tester.pumpAndSettle();

        for (final tab in [
          _LibraryFixtures.exercisesTab,
          _LibraryFixtures.workoutsTab,
        ]) {
          expect(
            tester.getSize(find.byKey(tab)).height,
            greaterThanOrEqualTo(48),
          );
        }
        expect(
          tester.getSize(find.byKey(_LibraryFixtures.createAction)).height,
          greaterThanOrEqualTo(48),
        );
        expect(find.byKey(const ValueKey('create_action_fab')), findsNothing);
        await _LibraryFixtures.reachLastItem(
          tester,
          screenType: ExerciseLibraryScreen,
          label: 'Exercise 12',
        );
        final navigation = find.byKey(
          const ValueKey('bottom_navigation_glass_surface'),
        );
        expect(
          tester.getRect(find.text('Exercise 12')).bottom,
          lessThanOrEqualTo(tester.getRect(navigation).top),
        );
        expect(tester.takeException(), isNull);

        await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);
        await _LibraryFixtures.reachLastItem(
          tester,
          screenType: SavedWorkoutLibraryScreen,
          label: 'Workout 12',
        );
        expect(
          tester.getRect(find.text('Workout 12')).bottom,
          lessThanOrEqualTo(tester.getRect(navigation).top),
        );
        expect(find.byKey(const ValueKey('create_action_fab')), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'search remains editable with the keyboard and can switch panes',
    (tester) async {
      _LibraryFixtures.useSurface(tester);
      final fixture = _LibraryFixtures();
      addTearDown(fixture.router.dispose);
      await tester.pumpWidget(fixture.app());
      await tester.pumpAndSettle();
      await tester.enterText(_LibraryFixtures.visibleSearch, 'Bench');
      await tester.pumpWidget(fixture.app(keyboardInset: 280));
      await tester.pumpAndSettle();
      final search = _LibraryFixtures.visibleSearch;
      await tester.ensureVisible(search);
      await tester.pumpAndSettle();
      expect(tester.getRect(search).bottom, lessThanOrEqualTo(844 - 280));
      await tester.enterText(search, 'Bench Press');
      await tester.pumpAndSettle();
      expect(
        fixture.exerciseRepository.searches.last.searchQuery,
        'Bench Press',
      );
      await _LibraryFixtures.switchTo(tester, _LibraryFixtures.workoutsTab);
      expect(find.text('Upper body').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
