import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/workout_execution/data/weight_suggestion_repository.dart';
import 'package:aedify/features/workout_execution/domain/weight_suggestion.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeightSuggestionViewData {
  const WeightSuggestionViewData({
    required this.supported,
    this.target,
    this.suggestion,
  });
  final bool supported;
  final WeightSuggestionTarget? target;
  final WeightSuggestion? suggestion;
}

class WeightSuggestionTargets
    extends Notifier<Map<String, WeightSuggestionTarget>> {
  @override
  Map<String, WeightSuggestionTarget> build() => const {};
  void setTarget(String exerciseId, WeightSuggestionTarget target) {
    state = {...state, exerciseId: target};
  }
}

abstract final class WeightSuggestionProviders {
  static final targetsProvider = NotifierProvider.autoDispose
      .family<
        WeightSuggestionTargets,
        Map<String, WeightSuggestionTarget>,
        String
      >((id) => WeightSuggestionTargets());
  static final repositoryProvider = Provider<WeightSuggestionRepository>(
    (ref) => DriftWeightSuggestionRepository(
      ref.watch(AppProviders.appDatabaseProvider),
    ),
  );
  static final clockProvider = Provider<DateTime Function()>(
    (ref) => DateTime.now,
  );
  static final evidenceProvider = StreamProvider.autoDispose
      .family<WeightSuggestionEvidence, int>(
        (ref, id) => ref.watch(repositoryProvider).watchEvidence(id),
      );

  static final viewProvider = Provider.autoDispose
      .family<
        AsyncValue<WeightSuggestionViewData>,
        ({
          WorkoutRunnerSessionViewData session,
          WorkoutRunnerExerciseItem exercise,
          WorkoutRunnerSetItem set,
          WeightSuggestionTarget? target,
        })
      >((ref, request) {
        final target =
            request.target ?? WeightSuggestionTarget.fromSet(request.set);
        final evidence = ref.watch(evidenceProvider(request.set.exerciseId));
        return evidence.whenData(
          (data) => WeightSuggestionViewData(
            supported: data.supported,
            target: target,
            suggestion: target == null
                ? null
                : WeightSuggestionPolicy.calculate(
                    evidence: data,
                    session: request.session,
                    exercise: request.exercise,
                    set: request.set,
                    target: target,
                    now: ref.watch(clockProvider)(),
                  ),
          ),
        );
      });
}
