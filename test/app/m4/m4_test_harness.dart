import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/app/router/app_router.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'fake_m4_dependencies.dart';

class M4TestHarness {
  late final AppDatabase database;
  late final FakeSavedWorkoutRepository savedWorkoutRepository;
  late final FakeProgrammeRepository programmeRepository;
  late final FakeWorkoutSessionRepository workoutSessionRepository;
  late final FakeExerciseRepository exerciseRepository;
  late final FakeWorkoutHistoryRepository workoutHistoryRepository;
  late final FakeNetworkStatus networkStatus;

  void setUp() {
    database = AppDatabase(NativeDatabase.memory());
    savedWorkoutRepository = FakeSavedWorkoutRepository();
    programmeRepository = FakeProgrammeRepository();
    workoutSessionRepository = FakeWorkoutSessionRepository();
    exerciseRepository = FakeExerciseRepository();
    workoutHistoryRepository = FakeWorkoutHistoryRepository();
    networkStatus = FakeNetworkStatus(isOnline: false);
  }

  Future<void> tearDown() async {
    await database.close();
  }

  Future<GoRouter> pumpApp({
    required WidgetTester tester,
    DraftGuard draftGuard = DraftGuard.clear,
    FeatureFlags featureFlags = FeatureFlags.defaultFlags,
  }) async {
    GoRouter? router;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppBootstrap.controllerProvider.overrideWith(
            () => _CompleteBootstrapController(),
          ),
          AppProviders.appDatabaseProvider.overrideWithValue(database),
          AppProviders.featureFlagsProvider.overrideWithValue(featureFlags),
          AppProviders.savedWorkoutRepositoryProvider.overrideWithValue(
            savedWorkoutRepository,
          ),
          AppProviders.programmeRepositoryProvider.overrideWithValue(
            programmeRepository,
          ),
          AppProviders.workoutSessionRepositoryProvider.overrideWithValue(
            workoutSessionRepository,
          ),
          AppProviders.exerciseRepositoryProvider.overrideWithValue(
            exerciseRepository,
          ),
          AppProviders.workoutHistoryRepositoryProvider.overrideWithValue(
            workoutHistoryRepository,
          ),
          AppProviders.networkStatusProvider.overrideWithValue(networkStatus),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            router = ref.watch(AppRouter.appRouterProvider);
            return MaterialApp.router(routerConfig: router!);
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    return router!;
  }
}

class _CompleteBootstrapController extends BootstrapController {
  @override
  BootstrapState build() {
    return const BootstrapState.success();
  }
}
