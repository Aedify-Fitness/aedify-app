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
import 'fake_m3_dependencies.dart';

class M3TestHarness {
  late final AppDatabase database;
  late final FakeOnboardingRepository onboardingRepo;
  late final FakeByokRepository byokRepo;
  late final FakeProfileRepository profileRepo;
  late final FakeProviderCapabilityRepository capabilityRepo;
  late final FakeNetworkStatus networkStatus;
  late final FakeExerciseRepository exerciseRepo;

  void setUp() {
    database = AppDatabase(NativeDatabase.memory());
    onboardingRepo = FakeOnboardingRepository();
    byokRepo = FakeByokRepository();
    profileRepo = FakeProfileRepository();
    capabilityRepo = FakeProviderCapabilityRepository();
    networkStatus = FakeNetworkStatus(isOnline: true);
    exerciseRepo = FakeExerciseRepository();
  }

  Future<void> tearDown() async {
    await database.close();
  }

  Future<GoRouter> pumpApp({
    required WidgetTester tester,
    OnboardingStatus? onboardingStatusOverride,
    AiAvailability aiAvailability = AiAvailability.available,
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
          AppProviders.onboardingRepositoryProvider.overrideWithValue(
            onboardingRepo,
          ),
          AppProviders.byokRepositoryProvider.overrideWithValue(byokRepo),
          AppProviders.profileRepositoryProvider.overrideWithValue(profileRepo),
          AppProviders.providerCapabilityRepositoryProvider.overrideWithValue(
            capabilityRepo,
          ),
          AppProviders.exerciseRepositoryProvider.overrideWithValue(
            exerciseRepo,
          ),
          AppProviders.networkStatusProvider.overrideWithValue(networkStatus),
          AppProviders.aiAvailabilityProvider.overrideWith(
            (ref) => aiAvailability,
          ),
          AppProviders.draftGuardProvider.overrideWith((ref) => draftGuard),
          if (onboardingStatusOverride != null)
            AppProviders.onboardingStatusProvider.overrideWithValue(
              AsyncData(onboardingStatusOverride),
            ),
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
