import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/app/router/app_router.dart';
import 'package:aedify/core/db/app_database.dart';
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
