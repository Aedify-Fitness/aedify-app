import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';

enum StartupPhase { initializing, success, failure }

class BootstrapFailure {
  final String code;
  final String message;
  final bool retryable;

  const BootstrapFailure({
    required this.code,
    required this.message,
    this.retryable = true,
  });
}

class BootstrapState {
  final StartupPhase phase;
  final BootstrapFailure? failure;
  final bool isOffline;

  const BootstrapState({
    required this.phase,
    this.failure,
    this.isOffline = false,
  });

  const BootstrapState.initializing() : this(phase: StartupPhase.initializing);

  const BootstrapState.success({bool isOffline = false})
    : this(phase: StartupPhase.success, isOffline: isOffline);

  const BootstrapState.failure(BootstrapFailure failure)
    : this(phase: StartupPhase.failure, failure: failure);
}

class BootstrapController extends Notifier<BootstrapState> {
  @override
  BootstrapState build() {
    return const BootstrapState.initializing();
  }

  Future<void> start() async {
    state = const BootstrapState.initializing();
    try {
      await ref.read(AppProviders.firebaseBootstrapProvider).initialize();
      await ref.read(AppProviders.appDatabaseProvider).readiness();
      await ref
          .read(AppProviders.localFileStoreProvider)
          .ensureCoreDirectories();

      bool offline = false;
      try {
        offline = !(await ref.read(AppProviders.networkStatusProvider).check());
      } catch (_) {
        offline = true;
      }

      state = BootstrapState.success(isOffline: offline);
    } on BootstrapFailure catch (f) {
      state = BootstrapState.failure(f);
    } catch (e) {
      state = BootstrapState.failure(
        BootstrapFailure(
          code: 'startup_error',
          message: e.toString(),
          retryable: true,
        ),
      );
    }
  }

  Future<void> retry() => start();
}
