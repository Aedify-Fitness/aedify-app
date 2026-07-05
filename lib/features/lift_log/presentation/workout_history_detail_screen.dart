import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_error_banner.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_exercise_card.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_superset_group_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutHistoryDetailScreen extends ConsumerWidget {
  const WorkoutHistoryDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(
      AppProviders.workoutHistoryDetailControllerProvider(sessionId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.workoutHistoryDetails)),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => HistoryErrorBanner(
          message: AppStrings.workoutHistoryDetailLoadFailed,
          onRetry: () => ref
              .read(
                AppProviders.workoutHistoryDetailControllerProvider(
                  sessionId,
                ).notifier,
              )
              .reload(),
        ),
        data: (state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorCode != null) {
            return HistoryErrorBanner(
              message:
                  state.errorMessage ??
                  AppStrings.workoutHistoryDetailLoadFailed,
              onRetry: () => ref
                  .read(
                    AppProviders.workoutHistoryDetailControllerProvider(
                      sessionId,
                    ).notifier,
                  )
                  .reload(),
            );
          }
          final detail = state.item;
          if (detail == null) {
            return Center(child: Text(AppStrings.missingSession));
          }
          return _DetailContent(detail: detail);
        },
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.detail});

  final WorkoutHistoryDetailViewData detail;

  String _sourceLabel() {
    return switch (detail.source) {
      SessionSource.program => AppStrings.sourceProgramme,
      SessionSource.savedWorkout => AppStrings.sourceSavedWorkout,
      SessionSource.standalone => AppStrings.sourceStandalone,
    };
  }

  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) return '--';
    final minutes = totalSeconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '$hours${AppStrings.durationHoursAbbreviation} $remainingMinutes${AppStrings.durationMinutesAbbreviation}';
    }
    return '$minutes${AppStrings.durationMinutesAbbreviation}';
  }

  List<Widget> _buildExerciseWidgets(
    List<WorkoutHistoryExerciseItem> exercises,
    List<SupersetGroupSummary> groups,
  ) {
    final groupedIds = <String>{};
    for (final g in groups) {
      groupedIds.addAll(g.memberIds);
    }

    final widgets = <Widget>[];
    final seenGroups = <String>{};

    for (final exercise in exercises) {
      if (groupedIds.contains(exercise.id)) {
        final gid = exercise.supersetGroupId!;
        if (!seenGroups.contains(gid)) {
          seenGroups.add(gid);
          final group = groups.firstWhere((g) => g.groupId == gid);
          final groupExercises = group.memberIds
              .map((mid) => exercises.firstWhere((e) => e.id == mid))
              .toList();
          widgets.add(
            WorkoutHistorySupersetGroupCard(
              group: group,
              exercises: groupExercises,
            ),
          );
        }
      } else {
        widgets.add(WorkoutHistoryExerciseCard(item: exercise));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref
        .watch(AppProviders.workoutHistoryGroupingMapperProvider)
        .buildGroups(detail.exercises);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.name, style: context.textTheme.titleMedium),
                AppWhiteSpace.hSm,
                _InfoRow(
                  label: AppStrings.completedOn,
                  value: _formatDate(detail.completedAt ?? detail.startedAt),
                ),
                _InfoRow(
                  label: AppStrings.sessionDuration,
                  value: _formatDuration(detail.durationSeconds),
                ),
                _InfoRow(
                  label: AppStrings.sessionSource,
                  value: _sourceLabel(),
                ),
                if (detail.notes != null && detail.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      detail.notes!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.historyExerciseList,
          style: context.textTheme.titleSmall,
        ),
        AppWhiteSpace.hSm,
        ..._buildExerciseWidgets(detail.exercises, groups),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: AppSizing.dataFieldWidthMd,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
