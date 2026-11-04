import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_components.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_evaluation.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsPlateauPanel extends ConsumerWidget {
  const AnalyticsPlateauPanel({
    super.key,
    this.names = const {},
    this.exerciseId,
    this.onExercise,
  });
  final Map<int, String> names;
  final int? exerciseId;
  final ValueChanged<int>? onExercise;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(PlateauProviders.evaluationsProvider)
      .when(
        loading: () => const AnalyticsLoading(),
        error: (_, _) => AnalyticsMessage(
          message: AppErrorStrings.plateauLoadFailed,
          error: true,
          action: AppStrings.retry,
          onAction: () => ref.invalidate(PlateauProviders.evaluationsProvider),
        ),
        data: (evaluations) {
          final selected = evaluations
              .where(
                (item) => exerciseId == null
                    ? item.outcome == PlateauOutcome.plateau
                    : item.exerciseId == exerciseId,
              )
              .toList();
          if (selected.isEmpty) {
            return Text(
              AnalyticsStrings.plateauMinimum,
              style: AnalyticsStyles.small(context),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final evaluation in selected)
                _PlateauCard(
                  evaluation: evaluation,
                  name:
                      names[evaluation.exerciseId] ??
                      WorkoutHistoryStrings.exerciseReference(
                        evaluation.exerciseId,
                      ),
                  onReview: onExercise == null
                      ? null
                      : () => onExercise!(evaluation.exerciseId),
                ),
            ],
          );
        },
      );
}

class _PlateauCard extends ConsumerWidget {
  const _PlateauCard({
    required this.evaluation,
    required this.name,
    this.onReview,
  });
  final PlateauEvaluation evaluation;
  final String name;
  final VoidCallback? onReview;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(
      PlateauProviders.dismissalProvider(evaluation.exerciseId),
    );
    final message = switch (evaluation.outcome) {
      PlateauOutcome.plateau => AnalyticsStrings.plateauHint,
      PlateauOutcome.dismissed => AnalyticsStrings.plateauDismissed,
      PlateauOutcome.deload => AnalyticsStrings.deloadPaused,
      PlateauOutcome.unknownContext => AnalyticsStrings.unknownPlateauContext,
      PlateauOutcome.inactive => AnalyticsStrings.inactivePlateau,
      PlateauOutcome.unsupported => AnalyticsStrings.unsupportedPlateau,
      PlateauOutcome.progressing ||
      PlateauOutcome.insufficientHistory => AnalyticsStrings.plateauMinimum,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AnalyticsPanel(
        emphasized: evaluation.outcome == PlateauOutcome.plateau,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (evaluation.outcome == PlateauOutcome.plateau) ...[
              const AnalyticsSectionTitle(AnalyticsStrings.reviewPlateau),
              AppWhiteSpace.hSm,
            ],
            Text(name, style: AnalyticsStyles.label(context)),
            AppWhiteSpace.hSm,
            Text(message, style: AnalyticsStyles.small(context)),
            if (evaluation.outcome == PlateauOutcome.plateau) ...[
              AppWhiteSpace.hMd,
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  if (evaluation.reasons.contains(PlateauReason.missedTargets))
                    Text(
                      AnalyticsStrings.targetMisses,
                      style: AnalyticsStyles.label(context),
                    ),
                  if (evaluation.reasons.contains(PlateauReason.highEffort))
                    Text(
                      AnalyticsStrings.highEffort,
                      style: AnalyticsStyles.label(context),
                    ),
                ],
              ),
              if (action.hasError) ...[
                AppWhiteSpace.hSm,
                Text(
                  AppErrorStrings.plateauDismissFailed,
                  style: AnalyticsStyles.body(context),
                ),
              ],
              AppWhiteSpace.hSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (onReview != null)
                    TextButton(
                      onPressed: onReview,
                      child: const Text(AppStrings.historyTab),
                    ),
                  OutlinedButton(
                    key: ValueKey('plateau_dismiss_${evaluation.exerciseId}'),
                    onPressed: action.isLoading
                        ? null
                        : () => ref
                              .read(
                                PlateauProviders.dismissalProvider(
                                  evaluation.exerciseId,
                                ).notifier,
                              )
                              .dismiss(),
                    child: Text(
                      action.isLoading
                          ? AppStrings.loading
                          : AnalyticsStrings.dismissalHint,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
