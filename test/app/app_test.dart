import 'package:aedify/app/app.dart';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/router/app_router.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('renders startup loading state by default', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AedifyApp()));
    await tester.pump();
    expect(find.text(AppStrings.startingApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders startup failure state when bootstrap fails', (
    tester,
  ) async {
    final bootstrapOverride = AppBootstrap.controllerProvider.overrideWith(
      () => _FailingBootstrapController(),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: [bootstrapOverride], child: const AedifyApp()),
    );
    await tester.pump();
    expect(find.text(AppStrings.startupFailed), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);
  });

  testWidgets('redirects to onboarding when bootstrap succeeds', (
    tester,
  ) async {
    final bootstrapOverride = AppBootstrap.controllerProvider.overrideWith(
      () => _SucceedingBootstrapController(),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: [bootstrapOverride], child: const AedifyApp()),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text(AppStrings.onboardingTitle), findsOneWidget);
  });

  testWidgets(
    'shows offline info on onboarding when bootstrap succeeds offline',
    (tester) async {
      final bootstrapOverride = AppBootstrap.controllerProvider.overrideWith(
        () => _SucceedingOfflineBootstrapController(),
      );

      await tester.pumpWidget(
        ProviderScope(overrides: [bootstrapOverride], child: const AedifyApp()),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text(AppStrings.onboardingTitle), findsOneWidget);
      expect(find.text(AppStrings.offlineModeInfo), findsOneWidget);
    },
  );

  testWidgets('redirects to onboarding when onboarding incomplete', (
    tester,
  ) async {
    final bootstrapOverride = AppBootstrap.controllerProvider.overrideWith(
      () => _SucceedingBootstrapController(),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: [bootstrapOverride], child: const AedifyApp()),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.onboardingTitle), findsOneWidget);
  });

  testWidgets('allows navigation when onboarding complete', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppBootstrap.controllerProvider.overrideWith(
            () => _SucceedingBootstrapController(),
          ),
          onboardingStatusProvider.overrideWith(
            (ref) => OnboardingStatus.complete,
          ),
          aiAvailabilityProvider.overrideWith(
            (ref) => AiAvailability.available,
          ),
          draftGuardProvider.overrideWith((ref) => DraftGuard.clear),
        ],
        child: const AedifyApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.startingApp), findsNothing);
  });

  group('router guards', () {
    /// Pumps the app with overrides and returns a list containing the latest
    /// GoRouter. Uses a list (mutable reference) so the test always reads the
    /// most recent GoRouter instance — the Consumer rebuilds when
    /// appRouterProvider recreates the router after bootstrap succeeds.
    Future<List<GoRouter>> pumpAppWithOverrides({
      required WidgetTester tester,
      required OnboardingStatus onboarding,
      required AiAvailability ai,
      required DraftGuard draft,
    }) async {
      final result = <GoRouter>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            AppBootstrap.controllerProvider.overrideWith(
              () => _SucceedingBootstrapController(),
            ),
            onboardingStatusProvider.overrideWith((ref) => onboarding),
            aiAvailabilityProvider.overrideWith((ref) => ai),
            draftGuardProvider.overrideWith((ref) => draft),
          ],
          child: Consumer(builder: (context, ref, _) {
            final router = ref.watch(appRouterProvider);
            result
              ..clear()
              ..add(router);
            return MaterialApp.router(routerConfig: router);
          }),
        ),
      );
      return result;
    }

    testWidgets('shows ai unavailable when AI key missing', (tester) async {
      final routers = await pumpAppWithOverrides(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.missingKey,
        draft: DraftGuard.clear,
      );
      // First pump: BootstrapScreen renders and calls start()
      // which transitions bootstrap to success, triggering a new GoRouter.
      await tester.pump();
      // The Consumer rebuilds with the new GoRouter — routers[0] is now current.
      // Second pump: processes the new GoRouter's redirect (startup -> onboarding).
      await tester.pump();

      final router = routers[0];
      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.chat().path);
      router.refresh();
      await tester.pump();
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.aiUnavailable().path),
      );
      expect(find.text(AppStrings.aiUnavailableMessage), findsOneWidget);
    });

    testWidgets('shows ai unsupported when AI unsupported', (tester) async {
      final routers = await pumpAppWithOverrides(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.unsupported,
        draft: DraftGuard.clear,
      );
      await tester.pump();
      await tester.pump();
      final router = routers[0];
      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.chat().path);
      router.refresh();
      await tester.pump();
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.aiUnsupported().path),
      );
      expect(find.text(AppStrings.aiUnsupportedMessage), findsOneWidget);
    });

    testWidgets('shows draft blocked when draft guard is active', (
      tester,
    ) async {
      final routers = await pumpAppWithOverrides(
        tester: tester,
        onboarding: OnboardingStatus.complete,
        ai: AiAvailability.available,
        draft: DraftGuard.blockedByUnsavedDraft,
      );
      await tester.pump();
      await tester.pump();

      final router = routers[0];
      router.go(AppRoutes.home().path);
      await tester.pump();

      router.go(AppRoutes.workout().path);
      router.refresh();
      await tester.pump();
      await tester.pump();

      expect(
        router.routeInformationProvider.value.uri.path,
        equals(AppRoutes.draftBlocked().path),
      );
      expect(find.text(AppStrings.draftBlockedMessage), findsOneWidget);
    });
  });
}

class _FailingBootstrapController extends BootstrapController {
  @override
  BootstrapState build() {
    return const BootstrapState.initializing();
  }

  @override
  Future<void> start() async {
    state = BootstrapState.failure(
      const BootstrapFailure(
        code: 'test_error',
        message: 'Test failure',
        retryable: true,
      ),
    );
  }
}

class _SucceedingBootstrapController extends BootstrapController {
  @override
  BootstrapState build() {
    return const BootstrapState.initializing();
  }

  @override
  Future<void> start() async {
    state = const BootstrapState.success();
  }
}

class _SucceedingOfflineBootstrapController extends BootstrapController {
  @override
  BootstrapState build() {
    return const BootstrapState.initializing();
  }

  @override
  Future<void> start() async {
    state = const BootstrapState.success(isOffline: true);
  }
}
