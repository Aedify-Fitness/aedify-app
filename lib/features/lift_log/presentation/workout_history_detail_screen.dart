import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_error_banner.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_exercise_card.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_superset_group_card.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/components/app_section_header.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class WorkoutHistoryDetailScreen extends ConsumerWidget {
  const WorkoutHistoryDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(
      AppProviders.workoutHistoryDetailControllerProvider(sessionId),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _QuietHeader(),
            Expanded(
              child: asyncState.when(
                loading: () => const _LoadingState(),
                error: (error, stack) =>
                    _ErrorState(onRetry: () => _reload(ref)),
                data: (state) {
                  if (state.isLoading) return const _LoadingState();
                  if (state.errorCode != null) {
                    return _ErrorState(
                      message: state.errorMessage,
                      onRetry: () => _reload(ref),
                    );
                  }
                  final detail = state.item;
                  if (detail == null) return const _MissingState();
                  return _DetailContent(detail: detail);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reload(WidgetRef ref) {
    ref
        .read(
          AppProviders.workoutHistoryDetailControllerProvider(
            sessionId,
          ).notifier,
        )
        .reload();
  }
}

class _QuietHeader extends StatelessWidget {
  const _QuietHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          AppIconButton(
            asset: OutlinedSvgAssets.arrowLeft,
            onPressed: context.canPop() ? () => context.pop() : null,
            semanticLabel: AppStrings.backLabel,
            backgroundColor: context.colorScheme.surfaceContainerLow,
          ),
          AppWhiteSpace.wSm,
          Expanded(
            child: Text(
              AppStrings.workoutHistoryDetails,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.loading,
            style: AppTextStyles.bodySm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: HistoryErrorBanner(
        message: message ?? AppStrings.workoutHistoryDetailLoadFailed,
        onRetry: onRetry,
      ),
    );
  }
}

class _MissingState extends StatelessWidget {
  const _MissingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppEmptyState(
          iconAsset: OutlinedSvgAssets.clock,
          title: AppStrings.missingSession,
        ),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.detail});

  final WorkoutHistoryDetailViewData detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref
        .watch(AppProviders.workoutHistoryGroupingMapperProvider)
        .buildGroups(detail.exercises);
    final exerciseWidgets = _buildExerciseWidgets(detail.exercises, groups);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            top: AppSpacing.sm,
            right: AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(child: _SessionHero(detail: detail)),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            top: AppSpacing.xl,
            right: AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: AppSectionHeader(title: AppStrings.historyExerciseList),
          ),
        ),
        if (exerciseWidgets.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.xxl,
            ),
            sliver: SliverToBoxAdapter(
              child: AppEmptyState(
                iconAsset: OutlinedSvgAssets.listBullet,
                title: AppStrings.noExercisesInWorkout,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.xxl,
            ),
            sliver: SliverList.builder(
              itemCount: exerciseWidgets.length,
              itemBuilder: (context, index) => exerciseWidgets[index],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildExerciseWidgets(
    List<WorkoutHistoryExerciseItem> exercises,
    List<SupersetGroupSummary> groups,
  ) {
    final groupedIds = <String>{};
    for (final group in groups) {
      groupedIds.addAll(group.memberIds);
    }

    final widgets = <Widget>[];
    final seenGroups = <String>{};
    for (final exercise in exercises) {
      if (!groupedIds.contains(exercise.id)) {
        widgets.add(WorkoutHistoryExerciseCard(item: exercise));
        continue;
      }

      final groupId = exercise.supersetGroupId!;
      if (!seenGroups.add(groupId)) continue;
      final group = groups.firstWhere((item) => item.groupId == groupId);
      final groupExercises = group.memberIds
          .map((id) => exercises.firstWhere((item) => item.id == id))
          .toList();
      widgets.add(
        WorkoutHistorySupersetGroupCard(
          group: group,
          exercises: groupExercises,
        ),
      );
    }
    return widgets;
  }
}

class _SessionHero extends StatelessWidget {
  const _SessionHero({required this.detail});

  final WorkoutHistoryDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    final totalSets = detail.exercises.fold<int>(
      0,
      (total, exercise) => total + exercise.sets.length,
    );
    final completedSets = detail.exercises.fold<int>(
      0,
      (total, exercise) =>
          total + exercise.sets.where((set) => set.completed).length,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppBadge(
                  label: _sourceLabel(),
                  backgroundColor: context.colorScheme.secondaryContainer,
                  foregroundColor: context.colorScheme.onSecondaryContainer,
                  borderRadius: AppRadius.full,
                ),
                Text(
                  '${AppStrings.completedOn}: '
                  '${_formatDate(detail.completedAt ?? detail.startedAt)}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            AppWhiteSpace.hMd,
            Text(
              detail.name,
              style: AppTextStyles.headlineLgMobile.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hLg,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _HeroMetric(
                  label: AppStrings.sessionDuration,
                  value: _formatDuration(detail.durationSeconds),
                ),
                _HeroMetric(
                  label: AppStrings.exercisesCompleted,
                  value: '${detail.exercises.length}',
                ),
                _HeroMetric(
                  label: AppStrings.setsCompleted,
                  value: '$completedSets/$totalSets',
                ),
              ],
            ),
            if (detail.energyLevel != null ||
                detail.perceivedDifficulty != null) ...[
              AppWhiteSpace.hMd,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (detail.energyLevel != null)
                    _SessionRating(
                      iconAsset: OutlinedSvgAssets.bolt,
                      label: AppStrings.performance,
                      value: '${detail.energyLevel}',
                    ),
                  if (detail.perceivedDifficulty != null)
                    _SessionRating(
                      iconAsset: OutlinedSvgAssets.adjustmentsHorizontal,
                      label: AppStrings.filterDifficulty,
                      value: '${detail.perceivedDifficulty}',
                    ),
                ],
              ),
            ],
            if (detail.notes != null && detail.notes!.isNotEmpty) ...[
              AppWhiteSpace.hLg,
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.sessionNotes,
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppWhiteSpace.hXs,
                      Text(
                        detail.notes!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _sourceLabel() {
    return switch (detail.source) {
      SessionSource.program => AppStrings.sourceProgramme,
      SessionSource.savedWorkout => AppStrings.sourceSavedWorkout,
      SessionSource.standalone => AppStrings.sourceStandalone,
    };
  }

  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) {
      return AppStrings.onboardingReviewEmptyValue;
    }
    final minutes = totalSeconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '$hours${AppStrings.durationHoursAbbreviation} '
          '$remainingMinutes${AppStrings.durationMinutesAbbreviation}';
    }
    return '$minutes${AppStrings.durationMinutesAbbreviation}';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: AppSizing.metricTileMinWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.bodyLg.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionRating extends StatelessWidget {
  const _SessionRating({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  final String iconAsset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: AppSizing.iconXs,
              height: AppSizing.iconXs,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wXs,
            Text(
              '$label: $value',
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
