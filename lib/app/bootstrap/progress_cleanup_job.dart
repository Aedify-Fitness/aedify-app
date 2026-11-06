import 'dart:async';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/features/progress_media/application/progress_deletion_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cleanup failures stay retryable from Progress storage instead of blocking app entry.
abstract final class ProgressCleanupJob {
  static final provider = Provider.autoDispose<void>((ref) {
    final ready = ref.watch(
      AppBootstrap.controllerProvider.select(
        (s) => s.phase == StartupPhase.success,
      ),
    );
    if (!ready) return;
    void recover() {
      if (ref.mounted) {
        unawaited(
          ref
              .read(ProgressDeletionProviders.controllerProvider.notifier)
              .recover(),
        );
      }
    }

    Future.microtask(recover);
    final lifecycle = AppLifecycleListener(onResume: recover);
    ref.onDispose(lifecycle.dispose);
  });
}
