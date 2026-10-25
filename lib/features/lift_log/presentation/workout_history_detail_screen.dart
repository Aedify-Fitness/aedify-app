import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_correction_sheet.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_error_banner.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_exercise_card.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_superset_group_card.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_visuals.dart';
import 'package:intl/intl.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: context.colorScheme.surface,
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
          IconButton(
            key: const Key('history_detail_back'),
            onPressed: context.canPop() ? () => context.pop() : null,
            tooltip: AppStrings.backLabel,
            style: IconButton.styleFrom(
              minimumSize: const Size.square(
                AppWorkoutHistoryTokens.controlSize,
              ),
              backgroundColor: context.colorScheme.surfaceContainerLow,
            ),
            icon: const HistoryIcon(asset: OutlinedSvgAssets.arrowLeft),
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
    final exerciseWidgets = _buildExerciseWidgets(
      context,
      detail.exercises,
      groups,
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppWorkoutHistoryTokens.maxWidth,
        ),
        child: CustomScrollView(
          key: const Key('workout_history_detail_scroll'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(child: _SessionHero(detail: detail)),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: OutlinedButton.icon(
                  key: const Key('history_repeat_workout'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppWorkoutHistoryTokens.controlSize,
                    ),
                  ),
                  onPressed: () => context.pushNamed(
                    AppRoutes.workoutRunnerRepeat().name,
                    pathParameters: {'sessionId': detail.sessionId},
                  ),
                  icon: const HistoryIcon(asset: OutlinedSvgAssets.arrowPath),
                  label: const Text(
                    WorkoutHistoryStrings.repeatWorkout,
                    style: AppTextStyles.labelMd,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  AppStrings.historyExerciseList,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            if (exerciseWidgets.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xl,
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
                  bottom: AppSpacing.xl,
                ),
                sliver: SliverList.builder(
                  itemCount: exerciseWidgets.length,
                  itemBuilder: (_, index) => exerciseWidgets[index],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExerciseWidgets(
    BuildContext context,
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
        widgets.add(
          WorkoutHistoryExerciseCard(
            item: exercise,
            onEditSet: exercise.canCorrectLogs
                ? (set) => _editSet(context, set)
                : null,
          ),
        );
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
          onEditSet: (set) => _editSet(context, set),
        ),
      );
    }
    return widgets;
  }

  Future<void> _editSet(BuildContext context, WorkoutHistorySetItem set) async {
    if (!set.hasCompletedLog) return;
    final exercise = detail.exercises
        .where((item) => item.sets.any((value) => value.id == set.id))
        .firstOrNull;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => WorkoutHistoryCorrectionSheet(
        sessionId: detail.sessionId,
        item: set,
        exerciseName: exercise?.exerciseName,
      ),
    );
  }
}

class _SessionHero extends StatelessWidget {
  const _SessionHero({required this.detail});
  final WorkoutHistoryDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    final total = detail.exercises.fold<int>(
      0,
      (sum, item) => sum + item.sets.length,
    );
    final logged = detail.exercises.fold<int>(
      0,
      (sum, item) => sum + item.sets.where((set) => set.hasCompletedLog).length,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              HistoryPill(
                label: _HistoryFormat.source(detail.source),
                emphasized: true,
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
          AppWhiteSpace.hSm,
          Text(
            '${AppStrings.completedOn}: ${DateFormat.yMMMd().format(detail.completedAt ?? detail.startedAt)}',
            style: AppTextStyles.bodySm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          AppWhiteSpace.hLg,
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              HistoryMetric(
                value: _HistoryFormat.duration(detail.durationSeconds),
                label: AppStrings.sessionDuration,
              ),
              HistoryMetric(
                value: '${detail.exercises.length}',
                label: AppStrings.exercisesCompleted,
              ),
              HistoryMetric(
                value: '$logged/$total',
                label: WorkoutHistoryStrings.loggedSets,
              ),
            ],
          ),
          if (detail.energyLevel != null ||
              detail.perceivedDifficulty != null) ...[
            AppWhiteSpace.hLg,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (detail.energyLevel != null)
                  HistoryPill(
                    label: '${AppStrings.performance}: ${detail.energyLevel}',
                  ),
                if (detail.perceivedDifficulty != null)
                  HistoryPill(
                    label:
                        '${AppStrings.filterDifficulty}: ${detail.perceivedDifficulty}',
                  ),
              ],
            ),
          ],
          if (detail.notes?.trim().isNotEmpty ?? false) ...[
            AppWhiteSpace.hLg,
            Divider(
              height: AppSizing.divider,
              color: context.colorScheme.outlineVariant.withValues(
                alpha: AppWorkoutHistoryTokens.borderOpacity,
              ),
            ),
            AppWhiteSpace.hMd,
            Text(
              AppStrings.sessionNotes,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            AppWhiteSpace.hXs,
            Text(
              detail.notes!,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

abstract final class _HistoryFormat {
  static String source(SessionSource value) => switch (value) {
    SessionSource.program => AppStrings.sourceProgramme,
    SessionSource.savedWorkout => AppStrings.sourceSavedWorkout,
    SessionSource.standalone => AppStrings.sourceStandalone,
  };
  static String duration(int? seconds) {
    if (seconds == null || seconds <= 0) {
      return AppStrings.onboardingReviewEmptyValue;
    }
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    return hours > 0
        ? '$hours${AppStrings.durationHoursAbbreviation} ${minutes % 60}${AppStrings.durationMinutesAbbreviation}'
        : '$minutes${AppStrings.durationMinutesAbbreviation}';
  }
}
