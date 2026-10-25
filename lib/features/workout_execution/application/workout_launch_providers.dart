import 'package:aedify/app/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One launch per mounted route; retries preserve any session already started.
class WorkoutLaunchProviders {
  const WorkoutLaunchProviders._();

  static final launch = FutureProvider.autoDispose
      .family<WorkoutLaunchResult, String?>((ref, sourceSessionId) async {
        final repository = ref.read(
          AppProviders.workoutSessionRepositoryProvider,
        );
        final existing = await repository.getActiveSession();
        if (existing != null) {
          return WorkoutLaunchResult(
            sessionId: existing.session.id,
            alreadyActive: true,
          );
        }
        final useCase = ref.read(
          AppProviders.startWorkoutSessionUseCaseProvider,
        );
        final session = sourceSessionId == null
            ? await useCase.startStandalone()
            : await useCase.repeatCompleted(sourceSessionId);
        if (ref.mounted) {
          ref.invalidate(AppProviders.activeWorkoutSessionProvider);
        }
        return WorkoutLaunchResult(
          sessionId: session.sessionId,
          alreadyActive: false,
        );
      });
}

class WorkoutLaunchResult {
  const WorkoutLaunchResult({
    required this.sessionId,
    required this.alreadyActive,
  });
  final String sessionId;
  final bool alreadyActive;
}
