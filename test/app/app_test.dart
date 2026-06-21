import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/app.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/shared/constants/app_strings.dart';

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
