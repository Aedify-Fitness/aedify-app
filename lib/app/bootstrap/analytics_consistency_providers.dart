import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps local derived flags current even when no analytics screen is open.
abstract final class AnalyticsConsistencyProviders {
  static final jobProvider = Provider.autoDispose<void>((ref) {
    final ready = ref.watch(
      AppBootstrap.controllerProvider.select(
        (state) => state.phase == StartupPhase.success,
      ),
    );
    if (!ready) return;

    // Share the screen's stream so opening Stats never starts a second writer.
    // Safe failures remain available through evaluationsProvider for UI retry;
    // the repository also retries on the next committed change or minute tick.
    ref.listen(PlateauProviders.evaluationsProvider, (_, _) {});
  });
}
