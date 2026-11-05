import 'dart:async';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/app/router/app_router.dart';
import 'package:aedify/features/progress_media/application/progress_reminder_providers.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App bridge owns lifecycle and routing; feature services never depend on UI.
abstract final class ProgressReminderJob {
  static final provider = Provider.autoDispose<void>((ref) {
    final ready = ref.watch(
      AppBootstrap.controllerProvider.select(
        (s) => s.phase == StartupPhase.success,
      ),
    );
    final onboarded =
        ref.watch(AppProviders.onboardingStatusProvider).asData?.value ==
        OnboardingStatus.complete;
    if (!ready || !onboarded) return;
    final service = ref.watch(ProgressReminderProviders.serviceProvider);
    final capture = service.captureRequests.listen((_) {
      if (!ref.mounted) return;
      final router = ref.read(AppRouter.appRouterProvider);
      if (router.routeInformationProvider.value.uri.path !=
          AppRoutes.progressCapture().path) {
        router.pushNamed(AppRoutes.progressCapture().name);
      }
    });
    ref.onDispose(() => unawaited(capture.cancel()));
    ref.listen(ProgressReminderProviders.controllerProvider, (_, _) {});
    ref.listen(
      AppProviders.featureFlagsProvider,
      (_, _) => unawaited(
        ref
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh(),
      ),
    );
    final lifecycle = AppLifecycleListener(
      onResume: () {
        if (ref.mounted) {
          unawaited(
            ref
                .read(ProgressReminderProviders.controllerProvider.notifier)
                .refresh(),
          );
        }
      },
    );
    ref.onDispose(lifecycle.dispose);
  });
}
