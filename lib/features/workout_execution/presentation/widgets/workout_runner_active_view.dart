import 'dart:ui';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/rest_timer_widget.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_header.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The controller-backed active state of the workout runner.
class WorkoutRunnerActiveView extends ConsumerWidget {
  const WorkoutRunnerActiveView({
    super.key,
    required this.session,
    required this.block,
    required this.activeExercise,
    required this.activeSet,
    required this.blockTitle,
    required this.showRestTimer,
    required this.restSeconds,
    required this.restTimerSerial,
    required this.isPaused,
    required this.canLogSet,
    required this.onClose,
    required this.onContinue,
    required this.onSubstitute,
    required this.onDismissRestTimer,
    required this.onUpdateSet,
    required this.onToggleCompleted,
    required this.onLogSet,
    required this.onAddSet,
    required this.onAddNote,
    required this.onShowExercise,
    required this.onFinish,
  });

  final WorkoutRunnerSessionViewData session;
  final WorkoutRunnerBlock block;
  final WorkoutRunnerExerciseItem activeExercise;
  final WorkoutRunnerSetItem? activeSet;
  final String blockTitle;
  final bool showRestTimer;
  final int restSeconds;
  final int restTimerSerial;
  final bool isPaused;
  final bool canLogSet;
  final VoidCallback onClose;
  final VoidCallback onContinue;
  final VoidCallback onSubstitute;
  final VoidCallback onDismissRestTimer;
  final void Function(String exerciseId, WorkoutRunnerSetItem set) onUpdateSet;
  final void Function(
    String exerciseId,
    WorkoutRunnerSetItem set,
    bool completed,
  )
  onToggleCompleted;
  final Future<void> Function() onLogSet;
  final VoidCallback onAddSet;
  final void Function(String exerciseId, WorkoutRunnerSetItem set) onAddNote;
  final ValueChanged<int> onShowExercise;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextExercise = _NextExerciseData.find(session, block);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final headerExtent = WorkoutRunnerHeader.extentFor(
      context,
      showSubstitute: !block.isSuperset,
    );
    final bottomChromeExtent = showRestTimer
        ? AppWorkoutRunnerTokens.restPanelExtent
        : AppWorkoutRunnerTokens.actionBarExtent;
    final bottomClearance =
        bottomInset +
        bottomChromeExtent +
        AppWorkoutRunnerTokens.contentBreathingSpace +
        AppSizing.divider;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            key: const ValueKey<String>('workout_runner_scroll_view'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              top: topInset + headerExtent,
              bottom: bottomClearance,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: AppWorkoutRunnerTokens.maxContentWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppWorkoutRunnerTokens.horizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isPaused) ...[
                        _PausedBanner(onContinue: onContinue),
                        AppWhiteSpace.hLg,
                      ],
                      if (block.isSuperset)
                        _SupersetBlockCard(
                          block: block,
                          activeSet: activeSet,
                          enabled: !isPaused,
                          canLogSet: canLogSet,
                          onUpdateSet: onUpdateSet,
                          onToggleCompleted: onToggleCompleted,
                          onLogSet: _logSet,
                          onAddSet: onAddSet,
                          onAddNote: onAddNote,
                          onShowExercise: onShowExercise,
                        )
                      else
                        _SingleExerciseContent(
                          exercise: block.members.single,
                          activeSet: activeSet,
                          enabled: !isPaused,
                          canLogSet: canLogSet,
                          onUpdateSet: onUpdateSet,
                          onToggleCompleted: onToggleCompleted,
                          onLogSet: _logSet,
                          onAddSet: onAddSet,
                          onAddNote: onAddNote,
                          onShowExercise: onShowExercise,
                        ),
                      AppWhiteSpace.hLg,
                      const _InsightCard(),
                      if (nextExercise != null) ...[
                        AppWhiteSpace.hLg,
                        _NextExerciseCard(
                          data: nextExercise,
                          onTap: () =>
                              onShowExercise(nextExercise.primary.exerciseId),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: WorkoutRunnerHeader(
            workoutTitle: session.name,
            exerciseTitle: blockTitle,
            workoutStartedAt: session.startedAt,
            isPaused: isPaused,
            pausedDurationSeconds: session.durationSeconds,
            onClose: onClose,
            onSubstitute: isPaused ? null : onSubstitute,
            showSubstitute: !block.isSuperset,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: showRestTimer
              ? RestTimerWidget(
                  key: ValueKey<String>(
                    'workout_runner_rest_timer_$restTimerSerial',
                  ),
                  seconds: restSeconds,
                  onDismiss: onDismissRestTimer,
                )
              : _WorkoutRunnerActionBar(
                  canLogSet: canLogSet && !isPaused,
                  logLabel: _logButtonLabel(),
                  onLogSet: _logSet,
                  onFinish: onFinish,
                ),
        ),
      ],
    );
  }

  Future<void> _logSet() async {
    if (showRestTimer) onDismissRestTimer();
    await onLogSet();
  }

  String _logButtonLabel() {
    final set = activeSet;
    if (set == null || !block.isSuperset) return AppStrings.logSet;
    return AppStrings.logSetWithLabel(
      const WorkoutRunnerBlockResolver().shortSetLabel(activeExercise, set),
      activeExercise.exerciseName,
    );
  }
}

class _PausedBanner extends StatelessWidget {
  const _PausedBanner({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.workoutInterrupted,
              style: AppTextStyles.bodySm.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onContinue,
            child: const Text(AppStrings.continueWorkout),
          ),
        ],
      ),
    );
  }
}

class _ExerciseMediaCard extends StatelessWidget {
  const _ExerciseMediaCard({required this.videos, required this.onShowGuide});

  final List<ExerciseDetailVideoViewData> videos;
  final VoidCallback onShowGuide;

  ExerciseDetailVideoViewData? get _thumbnailVideo {
    for (final video in videos) {
      if (video.hasThumbnail) return video;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailVideo = _thumbnailVideo;
    final mediaForeground = _RunnerColors.mediaForeground(context);

    return AspectRatio(
      aspectRatio: AppWorkoutRunnerTokens.mediaAspectRatio,
      child: Container(
        key: const ValueKey<String>('workout_runner_media'),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(
              alpha: AppWorkoutRunnerTokens.subtleBorderOpacity,
            ),
            width: AppSizing.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(
                alpha: AppWorkoutRunnerTokens.shadowOpacity,
              ),
              blurRadius: AppWorkoutRunnerTokens.shadowBlurRadius,
              offset: const Offset(0, AppWorkoutRunnerTokens.shadowOffsetY),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnailVideo != null)
              CachedNetworkImage(
                imageUrl: thumbnailVideo.ogImageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const _MediaFallback(),
                errorWidget: (_, _, _) => const _MediaFallback(),
              )
            else
              const _MediaFallback(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    context.colorScheme.shadow.withValues(
                      alpha: AppWorkoutRunnerTokens.mediaScrimOpacity,
                    ),
                    context.colorScheme.shadow.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              bottom: AppSpacing.md,
              child: _MediaGuideControl(
                foregroundColor: mediaForeground,
                onTap: onShowGuide,
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: _MediaInfoControl(
                foregroundColor: mediaForeground,
                onTap: onShowGuide,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.surfaceContainerHigh,
      child: Center(
        child: SvgPicture.asset(
          OutlinedSvgAssets.videoCamera,
          width: AppSizing.iconMd,
          height: AppSizing.iconMd,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _MediaGuideControl extends StatelessWidget {
  const _MediaGuideControl({
    required this.foregroundColor,
    required this.onTap,
  });

  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey<String>('workout_runner_media_guide'),
      button: true,
      label: AppStrings.formGuidance,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppWorkoutRunnerTokens.glassBlurSigma,
                sigmaY: AppWorkoutRunnerTokens.glassBlurSigma,
              ),
              child: Material(
                color: foregroundColor.withValues(
                  alpha: AppWorkoutRunnerTokens.mediaGlassSurfaceOpacity,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: foregroundColor.withValues(
                      alpha: AppWorkoutRunnerTokens.mediaGlassBorderOpacity,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.controlGap,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        OutlinedSvgAssets.playCircle,
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        colorFilter: ColorFilter.mode(
                          foregroundColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      AppWhiteSpace.wSm,
                      Flexible(
                        child: Text(
                          AppStrings.formGuidance.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMd.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaInfoControl extends StatelessWidget {
  const _MediaInfoControl({required this.foregroundColor, required this.onTap});

  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey<String>('workout_runner_media_info'),
      button: true,
      label: AppStrings.exerciseGuide,
      child: SizedBox(
        width: AppWorkoutRunnerTokens.mediaControlSize,
        height: AppWorkoutRunnerTokens.mediaControlSize,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppWorkoutRunnerTokens.glassBlurSigma,
                  sigmaY: AppWorkoutRunnerTokens.glassBlurSigma,
                ),
                child: Material(
                  color: foregroundColor.withValues(
                    alpha: AppWorkoutRunnerTokens.mediaGlassSurfaceOpacity,
                  ),
                  shape: CircleBorder(
                    side: BorderSide(
                      color: foregroundColor.withValues(
                        alpha: AppWorkoutRunnerTokens.mediaGlassBorderOpacity,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    child: Center(
                      child: SvgPicture.asset(
                        OutlinedSvgAssets.materialInfo,
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        colorFilter: ColorFilter.mode(
                          foregroundColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleExerciseContent extends ConsumerWidget {
  const _SingleExerciseContent({
    required this.exercise,
    required this.activeSet,
    required this.enabled,
    required this.canLogSet,
    required this.onUpdateSet,
    required this.onToggleCompleted,
    required this.onLogSet,
    required this.onAddSet,
    required this.onAddNote,
    required this.onShowExercise,
  });

  final WorkoutRunnerExerciseItem exercise;
  final WorkoutRunnerSetItem? activeSet;
  final bool enabled;
  final bool canLogSet;
  final void Function(String exerciseId, WorkoutRunnerSetItem set) onUpdateSet;
  final void Function(
    String exerciseId,
    WorkoutRunnerSetItem set,
    bool completed,
  )
  onToggleCompleted;
  final Future<void> Function() onLogSet;
  final VoidCallback onAddSet;
  final void Function(String exerciseId, WorkoutRunnerSetItem set) onAddNote;
  final ValueChanged<int> onShowExercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      AppProviders.exerciseDetailControllerProvider(exercise.exerciseId),
    );
    final detail = detailAsync.asData?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ExerciseMediaCard(
          videos: detail?.videos ?? const [],
          onShowGuide: () => onShowExercise(exercise.exerciseId),
        ),
        AppWhiteSpace.hLg,
        _TrainingLogCard(
          exerciseId: exercise.id,
          sets: exercise.sets,
          enabled: enabled,
          canLogSet: canLogSet,
          onUpdateSet: onUpdateSet,
          onToggleCompleted: onToggleCompleted,
          onLogSet: onLogSet,
          onAddSet: onAddSet,
          onAddNote: activeSet == null
              ? null
              : () => onAddNote(exercise.id, activeSet!),
        ),
      ],
    );
  }
}

class _SupersetBlockCard extends StatelessWidget {
  const _SupersetBlockCard({
    required this.block,
    required this.activeSet,
    required this.enabled,
    required this.canLogSet,
    required this.onUpdateSet,
    required this.onToggleCompleted,
    required this.onLogSet,
    required this.onAddSet,
    required this.onAddNote,
    required this.onShowExercise,
  });

  static const _resolver = WorkoutRunnerBlockResolver();

  final WorkoutRunnerBlock block;
  final WorkoutRunnerSetItem? activeSet;
  final bool enabled;
  final bool canLogSet;
  final void Function(String exerciseId, WorkoutRunnerSetItem set) onUpdateSet;
  final void Function(
    String exerciseId,
    WorkoutRunnerSetItem set,
    bool completed,
  )
  onToggleCompleted;
  final Future<void> Function() onLogSet;
  final VoidCallback onAddSet;
  final void Function(String exerciseId, WorkoutRunnerSetItem set) onAddNote;
  final ValueChanged<int> onShowExercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('workout_runner_superset_block'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(
            alpha: AppWorkoutRunnerTokens.subtleBorderOpacity,
          ),
          width: AppSizing.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(
              alpha: AppWorkoutRunnerTokens.shadowOpacity,
            ),
            blurRadius: AppWorkoutRunnerTokens.shadowBlurRadius,
            offset: const Offset(0, AppWorkoutRunnerTokens.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        children: [
          const _SupersetHeader(),
          ...List.generate(block.members.length, (i) {
            final member = block.members[i];
            return _SupersetMemberPreview(
              block: block,
              member: member,
              onTap: () => onShowExercise(member.exerciseId),
            );
          }),
          const _TrainingLogHeader(isSuperset: true),
          for (final type in SetType.values)
            for (
              var round = 0;
              round <
                  (type == SetType.warmup
                      ? _resolver.maxWarmupRounds(block)
                      : _resolver.maxWorkingRounds(block));
              round++
            )
              _SupersetRound(
                key: ValueKey<String>(
                  'workout_runner_superset_round_${type.name}_$round',
                ),
                block: block,
                rows: type == SetType.warmup
                    ? _resolver.warmupRoundSets(block, round)
                    : _resolver.workingRoundSets(block, round),
                activeSet: activeSet,
                enabled: enabled,
                canLogSet: canLogSet,
                onUpdateSet: onUpdateSet,
                onToggleCompleted: onToggleCompleted,
                onLogSet: onLogSet,
              ),
          _TrainingLogFooter(
            enabled: enabled,
            addSetLabel: AppStrings.addSuperset,
            onAddSet: onAddSet,
            onAddNote: activeSet == null
                ? null
                : () {
                    final member = block.members.firstWhere(
                      (candidate) =>
                          candidate.sets.any((set) => set.id == activeSet!.id),
                    );
                    onAddNote(member.id, activeSet!);
                  },
          ),
        ],
      ),
    );
  }
}

/// One linked warm-up or working round, sharing its active treatment.
class _SupersetRound extends StatelessWidget {
  const _SupersetRound({
    super.key,
    required this.block,
    required this.rows,
    required this.activeSet,
    required this.enabled,
    required this.canLogSet,
    required this.onUpdateSet,
    required this.onToggleCompleted,
    required this.onLogSet,
  });

  static const _resolver = WorkoutRunnerBlockResolver();

  final WorkoutRunnerBlock block;
  final List<WorkoutRunnerBlockSet> rows;
  final WorkoutRunnerSetItem? activeSet;
  final bool enabled;
  final bool canLogSet;
  final void Function(String exerciseId, WorkoutRunnerSetItem set) onUpdateSet;
  final void Function(
    String exerciseId,
    WorkoutRunnerSetItem set,
    bool completed,
  )
  onToggleCompleted;
  final Future<void> Function() onLogSet;

  @override
  Widget build(BuildContext context) {
    final active = rows.any((row) => row.set.id == activeSet?.id);
    final resolved = rows.every((row) => row.set.completed || row.set.skipped);
    final accent = _RunnerColors.accent(context);
    final surface = active
        ? Color.alphaBlend(
            accent.withValues(
              alpha: AppWorkoutRunnerTokens.activeRowSurfaceOpacity,
            ),
            context.colorScheme.surfaceContainerLowest,
          )
        : context.colorScheme.surfaceContainerLowest;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          bottom: BorderSide(color: context.colorScheme.outlineVariant),
        ),
      ),
      child: Opacity(
        opacity: active || resolved
            ? 1
            : AppWorkoutRunnerTokens.supersetUpcomingRoundOpacity,
        child: Stack(
          children: [
            if (rows.length > 1)
              Positioned(
                left: AppWorkoutRunnerTokens.supersetConnectorLeft,
                top: AppWorkoutRunnerTokens.supersetConnectorTop,
                bottom: AppWorkoutRunnerTokens.supersetConnectorBottom,
                width: AppWorkoutRunnerTokens.supersetConnectorWidth,
                child: DecoratedBox(
                  key: ValueKey<String>(
                    'workout_runner_superset_connector_${rows.first.set.id}',
                  ),
                  decoration: BoxDecoration(
                    color:
                        (active ? accent : context.colorScheme.outlineVariant)
                            .withValues(
                              alpha: AppWorkoutRunnerTokens
                                  .supersetConnectorOpacity,
                            ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
            Column(
              children: [
                for (final row in rows)
                  _SetLogRow(
                    key: ValueKey<String>(
                      'workout_runner_superset_set_row_${row.set.id}',
                    ),
                    set: row.set,
                    setLabel: _resolver.setLabel(block, row.exercise, row.set),
                    isActive: row.set.id == activeSet?.id,
                    grouped: true,
                    groupActive: active,
                    groupSurface: surface,
                    enabled: enabled,
                    canLogSet: canLogSet,
                    onUpdateSet: (set) => onUpdateSet(row.exercise.id, set),
                    onToggleCompleted: (completed) =>
                        onToggleCompleted(row.exercise.id, row.set, completed),
                    onLogSet: onLogSet,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SupersetHeader extends StatelessWidget {
  const _SupersetHeader();

  @override
  Widget build(BuildContext context) {
    final accent = _RunnerColors.accent(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        color: context.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: AppSizing.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.link,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
          ),
          AppWhiteSpace.wSm,
          Expanded(
            child: Text(
              AppStrings.superset.toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: AppWorkoutRunnerTokens.eyebrowLetterSpacing,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupersetMemberPreview extends ConsumerWidget {
  const _SupersetMemberPreview({
    required this.block,
    required this.member,
    required this.onTap,
  });

  static const _resolver = WorkoutRunnerBlockResolver();

  final WorkoutRunnerBlock block;
  final WorkoutRunnerExerciseItem member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref
        .watch(AppProviders.exerciseDetailControllerProvider(member.exerciseId))
        .asData
        ?.value;
    final thumbnail = _thumbnail(detail?.videos ?? const []);
    final target = _targetLabel(member);

    return Material(
      color: context.colorScheme.surfaceContainerLowest,
      shape: Border(
        bottom: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: AppWorkoutRunnerTokens.supersetPreviewImageSize,
                  height: AppWorkoutRunnerTokens.supersetPreviewImageSize,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (thumbnail == null)
                        ColoredBox(
                          color: context.colorScheme.surfaceContainerHighest,
                        )
                      else
                        CachedNetworkImage(
                          imageUrl: thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => ColoredBox(
                            color: context.colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (_, _, _) => ColoredBox(
                            color: context.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ColoredBox(
                        color: context.colorScheme.shadow.withValues(
                          alpha:
                              AppWorkoutRunnerTokens.mediaGlassSurfaceOpacity,
                        ),
                      ),
                      Center(
                        child: SvgPicture.asset(
                          OutlinedSvgAssets.playCircle,
                          width: AppSizing.iconSm,
                          height: AppSizing.iconSm,
                          colorFilter: ColorFilter.mode(
                            _RunnerColors.mediaForeground(context),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppWhiteSpace.wMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_resolver.memberLetter(block, member)}. ${member.exerciseName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLg.copyWith(
                        color: context.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (target != null) ...[
                      AppWhiteSpace.hXs,
                      Text(
                        target,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _thumbnail(List<ExerciseDetailVideoViewData> videos) {
    for (final video in videos) {
      if (video.hasThumbnail) return video.ogImageUrl;
    }
    return null;
  }

  String? _targetLabel(WorkoutRunnerExerciseItem member) {
    for (final set in member.sets) {
      if (set.setType != SetType.working) continue;
      final reps = _WorkoutRunnerFormatters.repsRange(set);
      return reps == null ? null : AppStrings.targetRepsLabel(reps);
    }
    return null;
  }
}

class _TrainingLogCard extends StatelessWidget {
  const _TrainingLogCard({
    required this.exerciseId,
    required this.sets,
    required this.enabled,
    required this.canLogSet,
    required this.onUpdateSet,
    required this.onToggleCompleted,
    required this.onLogSet,
    required this.onAddSet,
    required this.onAddNote,
  });

  final String exerciseId;
  final List<WorkoutRunnerSetItem> sets;
  final bool enabled;
  final bool canLogSet;
  final void Function(String exerciseId, WorkoutRunnerSetItem set) onUpdateSet;
  final void Function(
    String exerciseId,
    WorkoutRunnerSetItem set,
    bool completed,
  )
  onToggleCompleted;
  final Future<void> Function() onLogSet;
  final VoidCallback onAddSet;
  final VoidCallback? onAddNote;

  @override
  Widget build(BuildContext context) {
    final activeSet = _WorkoutRunnerSetSelection.firstIncomplete(sets);
    var warmupNumber = 0;
    var workingNumber = 0;

    return Container(
      key: const ValueKey<String>('workout_runner_training_log'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(
            alpha: AppWorkoutRunnerTokens.subtleBorderOpacity,
          ),
          width: AppSizing.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(
              alpha: AppWorkoutRunnerTokens.shadowOpacity,
            ),
            blurRadius: AppWorkoutRunnerTokens.shadowBlurRadius,
            offset: const Offset(0, AppWorkoutRunnerTokens.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        children: [
          const _TrainingLogHeader(),
          for (final set in sets)
            Builder(
              builder: (context) {
                final isWarmup = set.setType == SetType.warmup;
                if (isWarmup) {
                  warmupNumber++;
                } else {
                  workingNumber++;
                }
                final setLabel = isWarmup
                    ? '${AppStrings.warmupSetPrefix}$warmupNumber'
                    : '${AppStrings.workingSetPrefix}$workingNumber';
                final isActive = set.id == activeSet?.id;
                return _SetLogRow(
                  key: ValueKey<String>('workout_runner_set_row_${set.id}'),
                  set: set,
                  setLabel: setLabel,
                  isActive: isActive,
                  enabled: enabled,
                  canLogSet: canLogSet,
                  onUpdateSet: (updatedSet) =>
                      onUpdateSet(exerciseId, updatedSet),
                  onToggleCompleted: (completed) =>
                      onToggleCompleted(exerciseId, set, completed),
                  onLogSet: onLogSet,
                );
              },
            ),
          _TrainingLogFooter(
            enabled: enabled,
            addSetLabel: AppStrings.addSet,
            onAddSet: onAddSet,
            onAddNote: onAddNote,
          ),
        ],
      ),
    );
  }
}

class _TrainingLogHeader extends StatelessWidget {
  const _TrainingLogHeader({this.isSuperset = false});

  final bool isSuperset;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.labelMd.copyWith(
      color: context.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppWorkoutRunnerTokens.setRowHorizontalPadding,
        vertical: AppWorkoutRunnerTokens.trainingLogHeaderVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: AppSizing.divider,
          ),
        ),
      ),
      child: _SetGrid(
        isSuperset: isSuperset,
        set: _GridLabel(
          label: AppStrings.setNumberColumn,
          style: labelStyle,
          alignment: Alignment.centerLeft,
        ),
        previous: _GridLabel(
          label: AppStrings.previousColumn,
          style: labelStyle,
        ),
        target: _GridLabel(label: AppStrings.targetColumn, style: labelStyle),
        log: _GridLabel(
          label: AppStrings.logColumn,
          style: labelStyle,
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }
}

class _GridLabel extends StatelessWidget {
  const _GridLabel({
    required this.label,
    required this.style,
    this.alignment = Alignment.center,
  });

  final String label;
  final TextStyle style;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, maxLines: 1, style: style),
      ),
    );
  }
}

class _SetGrid extends StatelessWidget {
  const _SetGrid({
    required this.set,
    required this.previous,
    required this.target,
    required this.log,
    this.isSuperset = false,
  });

  final bool isSuperset;
  final Widget set;
  final Widget previous;
  final Widget target;
  final Widget log;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: isSuperset ? 3 : 2, child: set),
        AppWhiteSpace.wSm,
        Expanded(flex: 3, child: previous),
        AppWhiteSpace.wSm,
        Expanded(flex: 4, child: target),
        AppWhiteSpace.wSm,
        Expanded(flex: 3, child: log),
      ],
    );
  }
}

class _SetLogRow extends StatelessWidget {
  const _SetLogRow({
    super.key,
    required this.set,
    required this.setLabel,
    required this.isActive,
    required this.enabled,
    required this.canLogSet,
    required this.onUpdateSet,
    required this.onToggleCompleted,
    required this.onLogSet,
    this.grouped = false,
    this.groupActive = false,
    this.groupSurface,
  });

  final bool grouped;
  final bool groupActive;
  final Color? groupSurface;
  final WorkoutRunnerSetItem set;
  final String setLabel;
  final bool isActive;
  final bool enabled;
  final bool canLogSet;
  final ValueChanged<WorkoutRunnerSetItem> onUpdateSet;
  final ValueChanged<bool> onToggleCompleted;
  final Future<void> Function() onLogSet;

  @override
  Widget build(BuildContext context) {
    final isCompleted = set.completed;
    final isUpcoming = !isActive && !isCompleted && !grouped;
    final accent = _RunnerColors.accent(context);
    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppWorkoutRunnerTokens.setRowHorizontalPadding,
        vertical: grouped
            ? (groupActive
                  ? AppWorkoutRunnerTokens.standardSetRowVerticalPadding
                  : AppWorkoutRunnerTokens.supersetSetRowVerticalPadding)
            : isActive
            ? AppWorkoutRunnerTokens.activeSetRowVerticalPadding
            : AppWorkoutRunnerTokens.standardSetRowVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: grouped
            ? null
            : isActive
            ? accent.withValues(
                alpha: AppWorkoutRunnerTokens.activeRowSurfaceOpacity,
              )
            : context.colorScheme.surfaceContainerLowest,
        border: grouped
            ? null
            : Border(
                bottom: BorderSide(
                  color: context.colorScheme.outlineVariant,
                  width: AppSizing.divider,
                ),
              ),
      ),
      child: _SetGrid(
        isSuperset: grouped,
        set: Align(
          alignment: Alignment.centerLeft,
          child: ColoredBox(
            color: groupSurface ?? accent.withValues(alpha: 0),
            child: Text(
              setLabel,
              style: (isActive ? AppTextStyles.bodyLg : AppTextStyles.bodyMd)
                  .copyWith(
                    color: isActive || groupActive
                        ? accent
                        : context.colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
            ),
          ),
        ),
        previous: Center(
          child: Text(
            AppStrings.unavailableValue,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        target: isActive
            ? _ActiveSetInputs(set: set, onChanged: onUpdateSet)
            : _SetTargetSummary(set: set, completed: isCompleted),
        log: Align(
          alignment: Alignment.centerRight,
          child: _SetLogAction(
            setId: set.id,
            completed: isCompleted,
            active: isActive,
            enabled: enabled && (isCompleted || (isActive && canLogSet)),
            onPressed: isActive
                ? () async {
                    await onLogSet();
                  }
                : isCompleted
                ? () => onToggleCompleted(false)
                : null,
          ),
        ),
      ),
    );

    return Stack(
      children: [
        Opacity(
          opacity: isUpcoming ? AppWorkoutRunnerTokens.upcomingRowOpacity : 1,
          child: content,
        ),
        if (isActive)
          Positioned(
            left: 0,
            top: AppWorkoutRunnerTokens.activeRailInset,
            bottom: AppWorkoutRunnerTokens.activeRailInset,
            width: AppWorkoutRunnerTokens.activeRailWidth,
            child: DecoratedBox(
              key: ValueKey<String>('workout_runner_active_rail_${set.id}'),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppRadius.sm),
                  bottomRight: Radius.circular(AppRadius.sm),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActiveSetInputs extends StatelessWidget {
  const _ActiveSetInputs({required this.set, required this.onChanged});

  final WorkoutRunnerSetItem set;
  final ValueChanged<WorkoutRunnerSetItem> onChanged;

  @override
  Widget build(BuildContext context) {
    final initialWeight = set.actualWeightKg ?? set.prescribedWeightKg;
    final initialReps =
        set.actualReps ?? _WorkoutRunnerFormatters.targetReps(set);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppWorkoutRunnerTokens.setInputMaxWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RunnerEditableField(
              key: ValueKey<String>('workout_runner_weight_input_${set.id}'),
              initialValue: initialWeight == null
                  ? ''
                  : _WorkoutRunnerFormatters.number(initialWeight),
              label: AppStrings.kilogramsAbbreviation,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (value) => onChanged(
                _WorkoutRunnerSetMutations.copyWithActuals(
                  set,
                  weightKg: value,
                ),
              ),
            ),
            AppWhiteSpace.hSm,
            _RunnerEditableField(
              key: ValueKey<String>('workout_runner_reps_input_${set.id}'),
              initialValue: initialReps?.toString() ?? '',
              label: AppStrings.repsColumn,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => onChanged(
                _WorkoutRunnerSetMutations.copyWithActuals(set, reps: value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunnerEditableField extends StatefulWidget {
  const _RunnerEditableField({
    super.key,
    required this.initialValue,
    required this.label,
    required this.keyboardType,
    required this.inputFormatters,
    required this.onChanged,
  });

  final String initialValue;
  final String label;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String> onChanged;

  @override
  State<_RunnerEditableField> createState() => _RunnerEditableFieldState();
}

class _RunnerEditableFieldState extends State<_RunnerEditableField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_RunnerEditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      final selection = _controller.selection;
      _controller.value = TextEditingValue(
        text: widget.initialValue,
        selection:
            selection.isValid && selection.end <= widget.initialValue.length
            ? selection
            : TextSelection.collapsed(offset: widget.initialValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.labelSm.copyWith(
      color: context.colorScheme.onSurfaceVariant,
      fontSize: AppFontSizes.xxs,
      fontWeight: FontWeight.w500,
    );
    return SizedBox(
      height: AppWorkoutRunnerTokens.setInputHeight,
      child: AppTextField(
        controller: _controller,
        labelText: widget.label,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        textAlign: TextAlign.center,
        isDense: true,
        borderRadius: AppRadius.full,
        fillColor: context.colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        style: AppTextStyles.bodyMd.copyWith(
          color: context.colorScheme.onSurface,
        ),
        labelStyle: labelStyle,
        floatingLabelStyle: labelStyle,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

class _SetTargetSummary extends StatelessWidget {
  const _SetTargetSummary({required this.set, required this.completed});

  final WorkoutRunnerSetItem set;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final value = completed
        ? _WorkoutRunnerFormatters.actual(set)
        : _WorkoutRunnerFormatters.target(set);
    final valueStyle = AppTextStyles.bodySm.copyWith(
      color: context.colorScheme.onSurface,
    );

    if (set.setType == SetType.warmup) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.setTypeWarmup,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, textAlign: TextAlign.center, style: valueStyle),
        ],
      );
    }

    return Text(value, textAlign: TextAlign.center, style: valueStyle);
  }
}

class _SetLogAction extends StatelessWidget {
  const _SetLogAction({
    required this.setId,
    required this.completed,
    required this.active,
    required this.enabled,
    required this.onPressed,
  });

  final String setId;
  final bool completed;
  final bool active;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = _RunnerColors.accent(context);
    final visualSize = active
        ? AppWorkoutRunnerTokens.activeSetActionSize
        : AppWorkoutRunnerTokens.setActionSize;
    final fill = active
        ? accent
        : completed
        ? context.colorScheme.surfaceContainerHighest
        : context.colorScheme.surfaceContainerLowest;
    final foreground = active
        ? _RunnerColors.onAccent(context)
        : context.colorScheme.onSurfaceVariant;

    return Semantics(
      key: ValueKey<String>('workout_runner_set_hit_target_$setId'),
      button: enabled,
      checked: completed,
      label: completed ? AppStrings.setCompleted : AppStrings.markCompleted,
      child: SizedBox(
        width: AppWorkoutRunnerTokens.activeSetActionSize,
        height: AppWorkoutRunnerTokens.activeSetActionSize,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            customBorder: const CircleBorder(),
            child: Center(
              child: Ink(
                key: ValueKey<String>('workout_runner_set_action_$setId'),
                width: visualSize,
                height: visualSize,
                decoration: ShapeDecoration(
                  color: fill,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: active
                          ? accent
                          : context.colorScheme.outlineVariant,
                      width: AppSizing.divider,
                    ),
                  ),
                ),
                child: (completed || active)
                    ? Center(
                        child: SvgPicture.asset(
                          OutlinedSvgAssets.materialCheck,
                          width: active ? AppSizing.iconLg : AppSizing.iconSm,
                          height: active ? AppSizing.iconLg : AppSizing.iconSm,
                          colorFilter: ColorFilter.mode(
                            foreground,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrainingLogFooter extends StatelessWidget {
  const _TrainingLogFooter({
    required this.enabled,
    required this.addSetLabel,
    required this.onAddSet,
    required this.onAddNote,
  });

  final bool enabled;
  final String addSetLabel;
  final VoidCallback onAddSet;
  final VoidCallback? onAddNote;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: context.colorScheme.onSurface,
      side: BorderSide(color: context.colorScheme.outlineVariant),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.buttonVertical,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: context.colorScheme.surfaceContainerLow.withValues(
        alpha: AppWorkoutRunnerTokens.mediaGlassBorderOpacity,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              key: const ValueKey<String>('workout_runner_add_set'),
              onPressed: enabled ? onAddSet : null,
              style: buttonStyle,
              icon: SvgPicture.asset(
                OutlinedSvgAssets.materialAdd,
                width: AppSizing.iconS,
                height: AppSizing.iconS,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(addSetLabel.toUpperCase()),
              ),
            ),
          ),
          AppWhiteSpace.wControlGap,
          Expanded(
            child: OutlinedButton.icon(
              key: const ValueKey<String>('workout_runner_add_note'),
              onPressed: enabled ? onAddNote : null,
              style: buttonStyle,
              icon: SvgPicture.asset(
                OutlinedSvgAssets.materialEditNote,
                width: AppSizing.iconS,
                height: AppSizing.iconS,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(AppStrings.addNote.toUpperCase()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('workout_runner_insight'),
      padding: const EdgeInsets.all(AppWorkoutRunnerTokens.horizontalPadding),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(
            alpha: AppWorkoutRunnerTokens.subtleBorderOpacity,
          ),
          width: AppSizing.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppWorkoutRunnerTokens.insightIconSize,
            height: AppWorkoutRunnerTokens.insightIconSize,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLowest,
              shape: BoxShape.circle,
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              OutlinedSvgAssets.materialLightBulb,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                _RunnerColors.accent(context),
                BlendMode.srcIn,
              ),
            ),
          ),
          AppWhiteSpace.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.insightForProgress,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppWhiteSpace.hXs,
                Text(
                  AppStrings.insightPlaceholder,
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextExerciseCard extends StatelessWidget {
  const _NextExerciseCard({required this.data, required this.onTap});

  final _NextExerciseData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey<String>('workout_runner_next_exercise'),
      color: context.colorScheme.surfaceContainerLowest,
      elevation: AppWorkoutRunnerTokens.nextExerciseElevation,
      shadowColor: context.colorScheme.shadow.withValues(
        alpha: AppWorkoutRunnerTokens.shadowOpacity,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(
            alpha: AppWorkoutRunnerTokens.subtleBorderOpacity,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppWorkoutRunnerTokens.nextExerciseMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: AppWorkoutRunnerTokens.nextExerciseIconSize,
                  height: AppWorkoutRunnerTokens.nextExerciseIconSize,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colorScheme.outlineVariant,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    OutlinedSvgAssets.link,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      data.isSuperset
                          ? _RunnerColors.accent(context)
                          : context.colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                AppWhiteSpace.wMd,
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Text(
                            AppStrings.upNext.toUpperCase(),
                            style: AppTextStyles.labelMd.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              letterSpacing:
                                  AppWorkoutRunnerTokens.eyebrowLetterSpacing,
                            ),
                          ),
                          if (data.isSuperset)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: context.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                              child: Text(
                                AppStrings.superset.toUpperCase(),
                                style: AppTextStyles.labelSm.copyWith(
                                  color:
                                      context.colorScheme.onSecondaryContainer,
                                  fontSize: AppFontSizes.xxs,
                                ),
                              ),
                            ),
                        ],
                      ),
                      AppWhiteSpace.hXs,
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.primary.exerciseName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyLg.copyWith(
                                color: context.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          AppWhiteSpace.wSm,
                          SvgPicture.asset(
                            OutlinedSvgAssets.chevronRight,
                            width: AppSizing.iconSm,
                            height: AppSizing.iconSm,
                            colorFilter: ColorFilter.mode(
                              context.colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                      if (data.linked != null) ...[
                        AppWhiteSpace.hXs,
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                left: AppSpacing.sm,
                                right: AppSpacing.sm,
                              ),
                              width: AppSizing.divider,
                              height: AppSizing.iconXxs,
                              color: context.colorScheme.outlineVariant,
                            ),
                            Expanded(
                              child: Text(
                                data.linked!.exerciseName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutRunnerActionBar extends StatelessWidget {
  const _WorkoutRunnerActionBar({
    required this.canLogSet,
    required this.logLabel,
    required this.onLogSet,
    required this.onFinish,
  });

  final bool canLogSet;
  final String logLabel;
  final Future<void> Function() onLogSet;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final accent = _RunnerColors.accent(context);
    final onAccent = _RunnerColors.onAccent(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppWorkoutRunnerTokens.glassBlurSigma,
          sigmaY: AppWorkoutRunnerTokens.glassBlurSigma,
        ),
        child: Container(
          key: const ValueKey<String>('workout_runner_bottom_actions'),
          padding: EdgeInsets.only(
            left: AppWorkoutRunnerTokens.horizontalPadding,
            top: AppWorkoutRunnerTokens.actionBarVerticalPadding,
            right: AppWorkoutRunnerTokens.horizontalPadding,
            bottom:
                bottomInset + AppWorkoutRunnerTokens.actionBarVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surface.withValues(
              alpha: AppWorkoutRunnerTokens.actionSurfaceOpacity,
            ),
            border: Border(
              top: BorderSide(
                color: context.colorScheme.outlineVariant,
                width: AppSizing.divider,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppWorkoutRunnerTokens.innerMaxContentWidth,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: AppWorkoutRunnerTokens.actionBarButtonHeight,
                      child: FilledButton(
                        key: const ValueKey<String>('workout_runner_log_set'),
                        onPressed: canLogSet
                            ? () async {
                                await onLogSet();
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: onAccent,
                          disabledBackgroundColor: accent.withValues(
                            alpha: AppWorkoutRunnerTokens.upcomingRowOpacity,
                          ),
                          disabledForegroundColor: onAccent.withValues(
                            alpha: AppWorkoutRunnerTokens.subtleBorderOpacity,
                          ),
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            logLabel,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: canLogSet
                                  ? onAccent
                                  : onAccent.withValues(
                                      alpha: AppWorkoutRunnerTokens
                                          .subtleBorderOpacity,
                                    ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppWhiteSpace.wMd,
                  Expanded(
                    child: SizedBox(
                      height: AppWorkoutRunnerTokens.actionBarButtonHeight,
                      child: FilledButton(
                        key: const ValueKey<String>('workout_runner_finish'),
                        onPressed: onFinish,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              context.colorScheme.surfaceContainerHighest,
                          foregroundColor: context.colorScheme.onSurface,
                          elevation: 0,
                          side: BorderSide(
                            color: context.colorScheme.outlineVariant,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.finish,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: context.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextExerciseData {
  const _NextExerciseData({required this.primary, this.linked});

  final WorkoutRunnerExerciseItem primary;
  final WorkoutRunnerExerciseItem? linked;

  bool get isSuperset => primary.supersetGroupId != null;

  static _NextExerciseData? find(
    WorkoutRunnerSessionViewData session,
    WorkoutRunnerBlock currentBlock,
  ) {
    final currentIds = currentBlock.members.map((member) => member.id).toSet();

    WorkoutRunnerExerciseItem? primary;
    for (var index = 0; index < session.exercises.length; index++) {
      final candidate = session.exercises[index];
      if (currentIds.contains(candidate.id)) continue;
      if (_WorkoutRunnerSetSelection.hasIncomplete(candidate.sets)) {
        primary = candidate;
        break;
      }
    }
    if (primary == null) return null;

    WorkoutRunnerExerciseItem? linked;
    final groupId = primary.supersetGroupId;
    if (groupId != null) {
      final resolvedPrimary = primary;
      final linkedCandidates = session.exercises
          .where(
            (exercise) =>
                exercise.id != resolvedPrimary.id &&
                exercise.supersetGroupId == groupId &&
                _WorkoutRunnerSetSelection.hasIncomplete(exercise.sets),
          )
          .toList();
      linkedCandidates.sort(
        (a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0),
      );
      linked = linkedCandidates.isEmpty ? null : linkedCandidates.first;
    }

    return _NextExerciseData(primary: primary, linked: linked);
  }
}

class _WorkoutRunnerSetSelection {
  _WorkoutRunnerSetSelection._();

  static WorkoutRunnerSetItem? firstIncomplete(
    List<WorkoutRunnerSetItem> sets,
  ) {
    for (final set in sets) {
      if (!set.completed && !set.skipped) return set;
    }
    return null;
  }

  static bool hasIncomplete(List<WorkoutRunnerSetItem> sets) =>
      firstIncomplete(sets) != null;
}

class _WorkoutRunnerSetMutations {
  _WorkoutRunnerSetMutations._();

  static WorkoutRunnerSetItem copyWithActuals(
    WorkoutRunnerSetItem set, {
    String? weightKg,
    String? reps,
  }) {
    return WorkoutRunnerSetItem(
      id: set.id,
      exerciseId: set.exerciseId,
      setIndex: set.setIndex,
      setType: set.setType,
      performedAt: set.performedAt,
      completed: set.completed,
      skipped: set.skipped,
      setIntent: set.setIntent,
      prescribedRepsMin: set.prescribedRepsMin,
      prescribedRepsMax: set.prescribedRepsMax,
      prescribedRepsExact: set.prescribedRepsExact,
      prescribedWeightKg: set.prescribedWeightKg,
      prescribedRpeMin: set.prescribedRpeMin,
      prescribedRpeMax: set.prescribedRpeMax,
      actualReps: reps != null
          ? (reps.isEmpty ? null : int.tryParse(reps))
          : set.actualReps,
      actualWeightKg: weightKg != null
          ? (weightKg.isEmpty ? null : double.tryParse(weightKg))
          : set.actualWeightKg,
      actualDurationSeconds: set.actualDurationSeconds,
      actualDistanceMeters: set.actualDistanceMeters,
      actualRpe: set.actualRpe,
      actualRir: set.actualRir,
      restSeconds: set.restSeconds,
      notes: set.notes,
    );
  }
}

class _WorkoutRunnerFormatters {
  _WorkoutRunnerFormatters._();

  static String number(num value) => value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  static int? targetReps(WorkoutRunnerSetItem set) =>
      set.prescribedRepsExact ?? set.prescribedRepsMin ?? set.prescribedRepsMax;

  static String target(WorkoutRunnerSetItem set) {
    final weight = set.prescribedWeightKg;
    final reps = repsRange(set);
    if (weight != null && reps != null) return '${number(weight)} \u00d7 $reps';
    if (weight != null) {
      return '${number(weight)} ${AppStrings.metricWeightUnit}';
    }
    if (reps != null) return reps;
    return AppStrings.unavailableValue;
  }

  static String actual(WorkoutRunnerSetItem set) {
    final weight = set.actualWeightKg;
    final reps = set.actualReps;
    if (weight != null && reps != null) return '${number(weight)} \u00d7 $reps';
    if (weight != null) {
      return '${number(weight)} ${AppStrings.metricWeightUnit}';
    }
    if (reps != null) return reps.toString();
    return target(set);
  }

  static String? repsRange(WorkoutRunnerSetItem set) {
    final exact = set.prescribedRepsExact;
    if (exact != null) return exact.toString();
    final minimum = set.prescribedRepsMin;
    final maximum = set.prescribedRepsMax;
    if (minimum != null && maximum != null) {
      return minimum == maximum ? '$minimum' : '$minimum\u2013$maximum';
    }
    if (minimum != null) return '$minimum+';
    if (maximum != null) return '\u2264$maximum';
    return null;
  }
}

class _RunnerColors {
  _RunnerColors._();

  static Color accent(BuildContext context) =>
      Theme.brightnessOf(context) == Brightness.dark
      ? context.colorScheme.primary
      : context.colorScheme.secondary;

  static Color onAccent(BuildContext context) =>
      Theme.brightnessOf(context) == Brightness.dark
      ? context.colorScheme.onPrimary
      : context.colorScheme.onSecondary;

  static Color mediaForeground(BuildContext context) =>
      Theme.brightnessOf(context) == Brightness.dark
      ? context.colorScheme.onSurface
      : context.colorScheme.onSecondary;
}
