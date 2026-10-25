import 'package:aedify/features/lift_log/application/workout_history_providers.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/features/lift_log/domain/exercise_history_session.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_error_banner.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_exercise_card.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_visuals.dart';
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.workoutHistory,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.invalidate(provider),
                        tooltip: WorkoutHistoryStrings.refreshHistory,
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(
                            AppWorkoutHistoryTokens.controlSize,
                          ),
                        ),
                        icon: const HistoryIcon(
                          asset: OutlinedSvgAssets.arrowPath,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    WorkoutHistoryStrings.historyHint,
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppWhiteSpace.hLg,
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
      Padding(
        key: ValueKey('exercise_history_session_${item.sessionId}'),
        padding: const EdgeInsets.only(bottom: AppSpacing.controlGap),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HistoryIcon(
              asset: OutlinedSvgAssets.calendarDays,
              size: AppSizing.iconS,
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMd().format(item.completedAt),
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  AppWhiteSpace.hXxs,
                  Text(
                    item.workoutName,
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
