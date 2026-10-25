import 'package:aedify/features/lift_log/application/workout_history_providers.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/features/lift_log/domain/exercise_history_session.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_error_banner.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_exercise_card.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Basic local set history. Strength analytics and charts belong to M5.
class ExerciseHistorySection extends ConsumerWidget {
  const ExerciseHistorySection({
    super.key,
    required this.exerciseId,
    required this.emptyState,
  });

  final int exerciseId;
  final Widget emptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = WorkoutHistoryProviders.exerciseHistoryProvider(
      exerciseId,
    );
    final history = ref.watch(provider);
    return history.when(
      loading: () => const Center(
        child: CircularProgressIndicator(semanticsLabel: AppStrings.loading),
      ),
      error: (_, _) => HistoryErrorBanner(
        message: AppStrings.workoutHistoryLoadFailed,
        onRetry: () => ref.invalidate(provider),
      ),
      data: (sessions) {
        final items = sessions
            .map((item) => item.completedLogsOnly)
            .nonNulls
            .toList();
        return items.isEmpty
            ? emptyState
            : Column(
                key: const Key('exercise_history_sessions'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => ref.invalidate(provider),
                      child: const Text(WorkoutHistoryStrings.refreshHistory),
                    ),
                  ),
                  for (final item in items) _ExerciseHistoryEntry(item: item),
                ],
              );
      },
    );
  }
}

class _ExerciseHistoryEntry extends StatelessWidget {
  const _ExerciseHistoryEntry({required this.item});

  final ExerciseHistorySession item;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        key: ValueKey('exercise_history_session_${item.sessionId}'),
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${item.workoutName} · ${DateFormat.yMMMd().format(item.completedAt)}',
          style: AppTextStyles.labelMd,
        ),
      ),
      AppWhiteSpace.hXs,
      for (final exercise in item.exercises)
        WorkoutHistoryExerciseCard(
          item: exercise,
          onTap: () => context.pushNamed(
            AppRoutes.workoutHistoryDetail().name,
            pathParameters: {'sessionId': item.sessionId},
          ),
        ),
    ],
  );
}
