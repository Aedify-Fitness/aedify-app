import 'package:aedify/features/workout_builder/presentation/workout_builder_screen.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/app/router/app_router.dart';
import 'package:aedify/app/router/bottom_nav_shell.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/workout_execution/presentation/workout_runner_screen.dart';
import 'package:aedify/features/programmes/presentation/programme_builder_screen.dart';
import 'package:aedify/features/programmes/presentation/programme_calendar_screen.dart';
import 'package:aedify/features/programmes/presentation/programmes_screen.dart';
import 'package:aedify/features/programmes/presentation/workout_detail_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppRouter redirects', () {
    late AppDatabase testDatabase;

    setUp(() {
      testDatabase = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() {
      testDatabase.close();
    });

    /// Builds the app inside a ProviderScope with overrides and returns
    /// the GoRouter instance so tests can call [router.go] and assert.
    Future<GoRouter> pumpApp({
      required WidgetTester tester,
      required OnboardingStatus onboarding,
      required AiAvailability ai,
      required DraftGuard draft,
      FeatureFlags flags = FeatureFlags.defaultFlags,
    }) async {
      GoRouter? router;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            AppBootstrap.controllerProvider.overrideWith(
              () => _CompleteBootstrapController(),
            ),
            AppProviders.appDatabaseProvider.overrideWithValue(testDatabase),
            AppProviders.featureFlagsProvider.overrideWithValue(flags),
            AppProviders.onboardingStatusProvider.overrideWithValue(
              AsyncData(onboarding),
            ),
            AppProviders.aiAvailabilityProvider.overrideWith((ref) => ai),
            AppProviders.draftGuardProvider.overrideWith((ref) => draft),
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

    testWidgets('redirects completed onboarding from startup to home', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
      );

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.home().path),
      );
    });

    testWidgets('redirects unresolved onboarding status to startup', (
      tester,
    ) async {
      GoRouter? router;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            AppBootstrap.controllerProvider.overrideWith(
              () => _CompleteBootstrapController(),
            ),
            AppProviders.appDatabaseProvider.overrideWithValue(testDatabase),
            AppProviders.featureFlagsProvider.overrideWithValue(
              FeatureFlags.defaultFlags,
            ),
            AppProviders.onboardingStatusProvider.overrideWithValue(
              const AsyncLoading<OnboardingStatus>(),
            ),
            AppProviders.aiAvailabilityProvider.overrideWith(
              (ref) => AiAvailability.available,
            ),
            AppProviders.draftGuardProvider.overrideWith(
              (ref) => DraftGuard.clear,
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

      expect(
        router!.routeInformationProvider.value.uri.path,
        equals(AppRoutes.startup().path),
      );
    });

    testWidgets('redirects incomplete onboarding to onboarding', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.incomplete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
      );

      router.go(AppRoutes.home().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.onboarding().path),
      );
    });

    testWidgets('chat with missing key redirects to ai unavailable', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.missingKey,
        draft: DraftGuard.clear,
      );

      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.chat().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.aiUnavailable().path),
      );
    });

    testWidgets('chat with unsupported redirects to ai unsupported', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.unsupported,
        draft: DraftGuard.clear,
      );

      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.chat().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.aiUnsupported().path),
      );
    });

    testWidgets('guarded route with unsaved draft redirects to draft blocked', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.blockedByUnsavedDraft,
      );

      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.workout().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.draftBlocked().path),
      );
    });

    testWidgets('settings is accessible even when draft guard is blocked', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.blockedByUnsavedDraft,
      );

      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.settings().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.settings().path),
      );
    });

    testWidgets('chat passes through when AI is available', (tester) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
      );

      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.chat().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.chat().path),
      );
    });

    testWidgets('guarded route passes through when draft guard is clear', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
      );

      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.workout().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.workout().path),
      );
    });

    testWidgets(
      'programme template workout editor opens outside the bottom navigation shell',
      (tester) async {
        final router = await pumpApp(
          tester: tester,
          onboarding: OnboardingStatus.complete,
          ai: AiAvailability.available,
          draft: DraftGuard.clear,
        );
        router.goNamed(AppRoutes.programmeWorkoutBuilderCreate().name);
        await tester.pumpAndSettle();
        expect(find.byType(BottomNavShell), findsNothing);
        expect(
          tester
              .widget<WorkoutBuilderScreen>(find.byType(WorkoutBuilderScreen))
              .mode,
          WorkoutBuilderMode.programmeTemplate,
        );
      },
    );

    for (final route in [
      AppRoutes.programmeBuilderCreate(),
      AppRoutes.programmeBuilderEdit(),
      AppRoutes.programmeBuilderDuplicate(),
    ]) {
      testWidgets('${route.name} opens outside the bottom navigation shell', (
        tester,
      ) async {
        final router = await pumpApp(
          tester: tester,
          onboarding: OnboardingStatus.complete,
          ai: AiAvailability.available,
          draft: DraftGuard.clear,
        );
        final location = router.namedLocation(
          route.name,
          pathParameters: route.name == AppRoutes.programmeBuilderCreate().name
              ? const {}
              : const {'id': 'programme-1'},
        );
        router.go(location);
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, location);
        expect(find.byType(ProgrammeBuilderScreen), findsOneWidget);
        expect(find.byType(BottomNavShell), findsNothing);
      });
    }

    testWidgets('programme builder restores the Plan navigation on return', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
      );
      router.goNamed(AppRoutes.programmes().name);
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavShell), findsOneWidget);
      router.pushNamed(AppRoutes.programmeBuilderCreate().name);
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavShell), findsNothing);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavShell), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.programmes().path,
      );
    });

    for (final detail in [
      (
        route: AppRoutes.programmeCalendar(),
        parameters: const {'id': 'programme-1'},
        programmeId: 'programme-1',
        workoutId: null,
      ),
      (
        route: AppRoutes.programmeWorkoutDetail(),
        parameters: const {
          'programId': 'programme-1',
          'workoutId': 'workout-1',
        },
        programmeId: 'programme-1',
        workoutId: 'workout-1',
      ),
      (
        route: AppRoutes.workoutDetail(),
        parameters: const {'workoutId': 'workout-1'},
        programmeId: null,
        workoutId: 'workout-1',
      ),
    ]) {
      testWidgets('${detail.route.name} opens without floating navigation', (
        tester,
      ) async {
        final router = await pumpApp(
          tester: tester,
          onboarding: OnboardingStatus.complete,
          ai: AiAvailability.available,
          draft: DraftGuard.clear,
        );

        router.goNamed(detail.route.name, pathParameters: detail.parameters);
        await tester.pumpAndSettle();

        expect(
          router.routeInformationProvider.value.uri.path,
          router.namedLocation(
            detail.route.name,
            pathParameters: detail.parameters,
          ),
        );
        if (detail.workoutId == null) {
          final screen = tester.widget<ProgrammeCalendarScreen>(
            find.byType(ProgrammeCalendarScreen),
          );
          expect(screen.programmeId, detail.programmeId);
        } else {
          final screen = tester.widget<WorkoutDetailScreen>(
            find.byType(WorkoutDetailScreen),
          );
          expect(screen.programId, detail.programmeId);
          expect(screen.workoutId, detail.workoutId);
        }
        expect(find.byType(BottomNavShell), findsNothing);
        expect(find.byType(NavigationBar), findsNothing);
      });

      testWidgets('${detail.route.name} restores Plan navigation on return', (
        tester,
      ) async {
        final router = await pumpApp(
          tester: tester,
          onboarding: OnboardingStatus.complete,
          ai: AiAvailability.available,
          draft: DraftGuard.clear,
        );
        router.goNamed(AppRoutes.programmes().name);
        await tester.pumpAndSettle();
        expect(find.byType(ProgrammesScreen), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);

        router.pushNamed(detail.route.name, pathParameters: detail.parameters);
        await tester.pumpAndSettle();
        expect(find.byType(BottomNavShell), findsNothing);
        expect(find.byType(NavigationBar), findsNothing);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(ProgrammesScreen), findsOneWidget);
        expect(find.byType(BottomNavShell), findsOneWidget);
        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          2,
        );
        expect(
          router.routeInformationProvider.value.uri.path,
          AppRoutes.programmes().path,
        );
      });
    }

    testWidgets(
      'calendar and workout detail keep navigation hidden until Plan',
      (tester) async {
        final router = await pumpApp(
          tester: tester,
          onboarding: OnboardingStatus.complete,
          ai: AiAvailability.available,
          draft: DraftGuard.clear,
        );
        router.goNamed(AppRoutes.programmes().name);
        await tester.pumpAndSettle();

        router.pushNamed(
          AppRoutes.programmeCalendar().name,
          pathParameters: const {'id': 'programme-1'},
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProgrammeCalendarScreen), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);

        router.pushNamed(
          AppRoutes.programmeWorkoutDetail().name,
          pathParameters: const {
            'programId': 'programme-1',
            'workoutId': 'workout-1',
          },
        );
        await tester.pumpAndSettle();
        expect(find.byType(WorkoutDetailScreen), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(ProgrammeCalendarScreen), findsOneWidget);
        expect(find.byType(WorkoutDetailScreen), findsNothing);
        expect(find.byType(NavigationBar), findsNothing);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(ProgrammesScreen), findsOneWidget);
        expect(find.byType(BottomNavShell), findsOneWidget);
        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          2,
        );
      },
    );

    testWidgets('program workout runner opens outside bottom nav shell', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
      );

      final location = router.namedLocation(
        AppRoutes.workoutRunnerProgramWorkout().name,
        pathParameters: const {
          'programId': 'program-1',
          'workoutId': 'workout-1',
        },
      );
      router.go(location);
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, equals(location));
      expect(find.byType(WorkoutRunnerScreen), findsOneWidget);
      expect(find.byType(BottomNavShell), findsNothing);
    });

    testWidgets('onboarding guard beats AI and draft guards', (tester) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.incomplete,
        ai: AiAvailability.missingKey,
        draft: DraftGuard.blockedByUnsavedDraft,
      );

      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.chat().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.onboarding().path),
      );
    });

    testWidgets('AI disabled redirects chat to ai disabled screen', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
        flags: const FeatureFlags(aiEnabled: false),
      );
      router.go(AppRoutes.home().path);
      await tester.pump();
      router.go(AppRoutes.chat().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.aiDisabled().path),
      );
    });

    testWidgets('imports disabled redirects import routes', (tester) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
        flags: const FeatureFlags(importsEnabled: false),
      );
      router.go(AppRoutes.home().path);
      await tester.pump();
      router.go(AppRoutes.import().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.importDisabled().path),
      );
    });

    testWidgets('sharing disabled redirects share route', (tester) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
        flags: const FeatureFlags(sharingEnabled: false),
      );
      router.go(AppRoutes.home().path);
      await tester.pump();
      router.go(AppRoutes.share().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.shareDisabled().path),
      );
    });

    testWidgets('progress disabled redirects progress route', (tester) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
        flags: const FeatureFlags(progressMediaEnabled: false),
      );
      router.go(AppRoutes.home().path);
      await tester.pump();
      router.go(AppRoutes.progress().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.progressDisabled().path),
      );
    });

    testWidgets('diagnostics disabled redirects diagnostics route home', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
        flags: const FeatureFlags(diagnosticsEnabled: false),
      );
      router.go(AppRoutes.home().path);
      await tester.pump();
      router.go(AppRoutes.diagnostics().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.home().path),
      );
    });

    testWidgets('diagnostics enabled allows diagnostics route', (tester) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
        flags: const FeatureFlags(diagnosticsEnabled: true),
      );
      router.go(AppRoutes.home().path);
      await tester.pump();
      router.go(AppRoutes.diagnostics().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.diagnostics().path),
      );
    });

    testWidgets('bodymap route is reachable when enabled', (tester) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
      );
      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.bodymap().path);
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.bodymap().path),
      );
    });

    testWidgets('settings and BYOK settings routes reachable post-onboarding', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.missingKey,
        draft: DraftGuard.clear,
      );
      router.go(AppRoutes.home().path);
      await tester.pump();

      // Settings should be reachable even with missing AI key
      router.go(AppRoutes.settings().path);
      await tester.pump();
      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.settings().path),
      );

      // BYOK settings should be reachable
      router.go(AppRoutes.byokSettings().path);
      await tester.pump();
      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.byokSettings().path),
      );
    });

    testWidgets('exercise library route reachable post-onboarding', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.clear,
      );
      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.exercises().path);
      await tester.pump();
      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.exercises().path),
      );
    });

    testWidgets(
      'import-image route blocked by importsDisabled flag, reachable when enabled',
      (tester) async {
        // Blocked when disabled
        final disabledRouter = await pumpApp(
          tester: tester,
          onboarding: OnboardingStatus.complete,
          ai: AiAvailability.available,
          draft: DraftGuard.clear,
          flags: const FeatureFlags(importsEnabled: false),
        );
        disabledRouter.go(AppRoutes.home().path);
        await tester.pump();
        disabledRouter.go(AppRoutes.importImage().path);
        await tester.pump();
        expect(
          disabledRouter.routeInformationProvider.value.uri.path,
          equals(AppRoutes.importDisabled().path),
        );

        // Reachable when enabled
        final enabledRouter = await pumpApp(
          tester: tester,
          onboarding: OnboardingStatus.complete,
          ai: AiAvailability.available,
          draft: DraftGuard.clear,
          flags: const FeatureFlags(importsEnabled: true),
        );
        enabledRouter.go(AppRoutes.home().path);
        await tester.pump();
        enabledRouter.go(AppRoutes.importImage().path);
        await tester.pump();
        expect(
          enabledRouter.routeInformationProvider.value.uri.path,
          equals(AppRoutes.importImage().path),
        );
      },
    );

    testWidgets('draft guard blocks import and import-image routes', (
      tester,
    ) async {
      final router = await pumpApp(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.blockedByUnsavedDraft,
      );
      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.import().path);
      await tester.pump();
      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.draftBlocked().path),
      );

      router.go(AppRoutes.importImage().path);
      await tester.pump();
      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.draftBlocked().path),
      );
    });
  });
}

class _CompleteBootstrapController extends BootstrapController {
  @override
  BootstrapState build() {
    return const BootstrapState.success();
  }
}
