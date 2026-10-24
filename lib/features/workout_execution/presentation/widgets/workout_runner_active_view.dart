import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/rest_timer_widget.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_error_banner.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_header.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_training_log.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Keeps the current exercise, set logging and rest controls within reach.
class WorkoutRunnerActiveView extends ConsumerStatefulWidget {
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
    this.onToggleSkipped,
    this.errorMessage,
    this.onRetry,
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
  final void Function(
    String exerciseId,
    WorkoutRunnerSetItem set,
    bool skipped,
  )?
  onToggleSkipped;
  final Future<void> Function() onLogSet;
  final VoidCallback onAddSet;
  final void Function(String exerciseId, WorkoutRunnerSetItem set) onAddNote;
  final ValueChanged<int> onShowExercise;
  final VoidCallback onFinish;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  ConsumerState<WorkoutRunnerActiveView> createState() =>
      _WorkoutRunnerActiveViewState();
}

class _WorkoutRunnerActiveViewState
    extends ConsumerState<WorkoutRunnerActiveView> {
  bool _logging = false;

  Future<void> _logSet() async {
    if (_logging || widget.isPaused || !widget.canLogSet) return;
    setState(() => _logging = true);
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      if (widget.showRestTimer) widget.onDismissRestTimer();
      await widget.onLogSet();
      if (mounted) HapticFeedback.lightImpact();
    } finally {
      if (mounted) setState(() => _logging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.isPaused && !_logging;
    final next = _NextBlock.find(widget.session, widget.block);
    return _RunnerLayout(
      header: KeyedSubtree(
        key: const ValueKey<String>('workout_runner_current_exercise'),
        child: WorkoutRunnerHeader(
          workoutTitle: widget.session.name,
          exerciseTitle: widget.blockTitle,
          workoutStartedAt: widget.session.startedAt,
          pausedDurationSeconds: widget.session.durationSeconds,
          isPaused: widget.isPaused,
          onClose: widget.onClose,
          onSubstitute: enabled ? widget.onSubstitute : null,
          showSubstitute: !widget.block.isSuperset,
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.errorMessage != null) ...[
            WorkoutRunnerErrorBanner(
              message: widget.errorMessage!,
              onRetry: widget.onRetry,
            ),
            AppWhiteSpace.hLg,
          ],
          if (widget.isPaused) ...[
            _PausedBanner(onContinue: widget.onContinue),
            AppWhiteSpace.hLg,
          ],
          if (widget.block.isSuperset)
            _SupersetGuides(
              block: widget.block,
              onShowExercise: widget.onShowExercise,
            )
          else
            _ExerciseGuide(
              exerciseId: widget.activeExercise.exerciseId,
              onPressed: () =>
                  widget.onShowExercise(widget.activeExercise.exerciseId),
            ),
          AppWhiteSpace.hLg,
          _SessionProgress(session: widget.session),
          AppWhiteSpace.hMd,
          WorkoutRunnerTrainingLog(
            block: widget.block,
            activeSet: widget.activeSet,
            enabled: enabled,
            canLogSet: widget.canLogSet && enabled,
            onUpdateSet: widget.onUpdateSet,
            onToggleCompleted: widget.onToggleCompleted,
            onToggleSkipped: widget.onToggleSkipped,
            onLogSet: _logSet,
            onAddSet: widget.onAddSet,
            onAddNote: widget.onAddNote,
            onShowExercise: widget.onShowExercise,
          ),
          if (next != null) ...[
            AppWhiteSpace.hLg,
            _NextBlockCard(
              block: next,
              onPressed: () =>
                  widget.onShowExercise(next.members.first.exerciseId),
            ),
          ],
          AppWhiteSpace.hLg,
        ],
      ),
      resting: widget.showRestTimer,
      footer: widget.showRestTimer
          ? RestTimerWidget(
              key: ValueKey<String>(
                'workout_runner_rest_timer_${widget.restTimerSerial}',
              ),
              seconds: widget.restSeconds,
              onDismiss: widget.onDismissRestTimer,
            )
          : _RunnerActions(
              canLog: widget.canLogSet && enabled,
              logging: _logging,
              onLog: _logSet,
              onFinish: _logging ? null : widget.onFinish,
            ),
    );
  }
}

class _RunnerLayout extends StatelessWidget {
  const _RunnerLayout({
    required this.header,
    required this.content,
    required this.footer,
    required this.resting,
  });
  final Widget header;
  final Widget content;
  final Widget footer;
  final bool resting;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scrollsHeader =
          constraints.maxHeight <
              AppWorkoutRunnerTokens.compactViewportHeight ||
          MediaQuery.textScalerOf(context).scale(AppFontSizes.sm) >
              AppFontSizes.sm * AppWorkoutRunnerTokens.largeTextBreakpoint;
      return Column(
        children: [
          if (!scrollsHeader) header,
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey<String>('workout_runner_scroll_view'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  if (scrollsHeader) header,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppWorkoutRunnerTokens.horizontalPadding,
                      vertical: AppSpacing.md,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppWorkoutRunnerTokens.innerMaxContentWidth,
                        ),
                        child: content,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (resting)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    constraints.maxHeight *
                    AppWorkoutRunnerTokens.restMaxHeightFactor,
              ),
              child: SingleChildScrollView(child: footer),
            )
          else
            footer,
        ],
      );
    },
  );
}

class _SessionProgress extends StatelessWidget {
  const _SessionProgress({required this.session});
  final WorkoutRunnerSessionViewData session;

  @override
  Widget build(BuildContext context) {
    final sets = session.exercises.expand((exercise) => exercise.sets).toList();
    final completed = sets.where((set) => set.completed).length;
    final skipped = sets.where((set) => set.skipped).length;
    return Semantics(
      label: AppStrings.progressLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                AppStrings.runnerSetProgress(completed, sets.length),
                style: WorkoutRunnerStyle.small(context),
              ),
              if (skipped > 0)
                Text(
                  AppStrings.runnerSkippedSets(skipped),
                  style: WorkoutRunnerStyle.small(context),
                ),
            ],
          ),
          AppWhiteSpace.hSm,
          LinearProgressIndicator(
            value: sets.isEmpty ? 0 : completed / sets.length,
            minHeight: AppWorkoutRunnerTokens.progressTrackHeight,
            color: WorkoutRunnerStyle.accent(context),
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ],
      ),
    );
  }
}

class _ExerciseGuide extends ConsumerWidget {
  const _ExerciseGuide({required this.exerciseId, required this.onPressed});
  final int exerciseId;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref
        .watch(AppProviders.exerciseDetailControllerProvider(exerciseId))
        .asData
        ?.value;
    final thumbnail = detail?.videos
        .where((video) => video.hasThumbnail)
        .firstOrNull
        ?.ogImageUrl;
    final foreground = context.theme.brightness == Brightness.dark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondary;
    return AspectRatio(
      aspectRatio: AppWorkoutRunnerTokens.mediaAspectRatio,
      child: Material(
        key: const ValueKey<String>('workout_runner_media'),
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const ValueKey<String>('workout_runner_media_guide'),
          onTap: onPressed,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ExcludeSemantics(child: _GuideThumbnail(thumbnail: thumbnail)),
              if (thumbnail != null)
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          context.colorScheme.scrim.withValues(
                            alpha: AppWorkoutRunnerTokens.mediaScrimOpacity,
                          ),
                          context.colorScheme.scrim.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Material(
                    color: thumbnail == null
                        ? WorkoutRunnerStyle.panel(context)
                        : context.colorScheme.scrim.withValues(
                            alpha: AppWorkoutRunnerTokens.mediaScrimOpacity,
                          ),
                    shape: const StadiumBorder(),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: AppWorkoutRunnerTokens.controlSize,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              OutlinedSvgAssets.bookOpen,
                              width: AppSizing.iconSm,
                              height: AppSizing.iconSm,
                              colorFilter: ColorFilter.mode(
                                thumbnail == null
                                    ? WorkoutRunnerStyle.accent(context)
                                    : foreground,
                                BlendMode.srcIn,
                              ),
                            ),
                            AppWhiteSpace.wSm,
                            Flexible(
                              child: Text(
                                AppStrings.formGuidance,
                                style: WorkoutRunnerStyle.label(context)
                                    .copyWith(
                                      color: thumbnail == null
                                          ? context.colorScheme.onSurface
                                          : foreground,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideThumbnail extends StatelessWidget {
  const _GuideThumbnail({this.thumbnail});
  final String? thumbnail;
  @override
  Widget build(BuildContext context) => thumbnail == null
      ? const _GuideFallback()
      : CachedNetworkImage(
          imageUrl: thumbnail!,
          fit: BoxFit.cover,
          placeholder: (_, _) => const _GuideFallback(),
          errorWidget: (_, _, _) => const _GuideFallback(),
        );
}

class _GuideFallback extends StatelessWidget {
  const _GuideFallback();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colorScheme.surfaceContainerHigh,
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: WorkoutRunnerStyle.panel(context),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          OutlinedSvgAssets.videoCamera,
          width: AppSizing.iconLg,
          height: AppSizing.iconLg,
          colorFilter: ColorFilter.mode(
            WorkoutRunnerStyle.accent(context),
            BlendMode.srcIn,
          ),
        ),
      ),
    ),
  );
}

class _SupersetGuides extends StatelessWidget {
  const _SupersetGuides({required this.block, required this.onShowExercise});
  final WorkoutRunnerBlock block;
  final ValueChanged<int> onShowExercise;

  @override
  Widget build(BuildContext context) => Material(
    color: WorkoutRunnerStyle.panel(context),
    borderRadius: BorderRadius.circular(AppRadius.xl),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (final member in block.members)
          _SupersetMemberGuide(
            member: member,
            letter: const WorkoutRunnerBlockResolver().memberLetter(
              block,
              member,
            ),
            onPressed: () => onShowExercise(member.exerciseId),
          ),
      ],
    ),
  );
}

class _SupersetMemberGuide extends ConsumerWidget {
  const _SupersetMemberGuide({
    required this.member,
    required this.letter,
    required this.onPressed,
  });
  final WorkoutRunnerExerciseItem member;
  final String letter;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnail = ref
        .watch(AppProviders.exerciseDetailControllerProvider(member.exerciseId))
        .asData
        ?.value
        ?.videos
        .where((video) => video.hasThumbnail)
        .firstOrNull
        ?.ogImageUrl;
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.controlGap,
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: AppWorkoutRunnerTokens.supersetPreviewImageSize,
                  height: AppWorkoutRunnerTokens.supersetPreviewImageSize,
                  child: _GuideThumbnail(thumbnail: thumbnail),
                ),
              ),
            ),
            AppWhiteSpace.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$letter. ${member.exerciseName}',
                    style: WorkoutRunnerStyle.label(context),
                  ),
                  AppWhiteSpace.hXs,
                  Text(
                    AppStrings.exerciseGuide,
                    style: WorkoutRunnerStyle.caption(context),
                  ),
                ],
              ),
            ),
            AppWhiteSpace.wSm,
            SvgPicture.asset(
              OutlinedSvgAssets.chevronRight,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                WorkoutRunnerStyle.accent(context),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PausedBanner extends StatelessWidget {
  const _PausedBanner({required this.onContinue});
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: WorkoutRunnerStyle.selectedFill(context),
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.workoutInterrupted,
          style: WorkoutRunnerStyle.label(
            context,
          ).copyWith(color: WorkoutRunnerStyle.selectedForeground(context)),
        ),
        AppWhiteSpace.hSm,
        TextButton(
          onPressed: onContinue,
          style: TextButton.styleFrom(
            foregroundColor: WorkoutRunnerStyle.selectedForeground(context),
            minimumSize: const Size.fromHeight(
              AppWorkoutRunnerTokens.controlSize,
            ),
          ),
          child: const Text(AppStrings.continueWorkout),
        ),
      ],
    ),
  );
}

class _NextBlockCard extends StatelessWidget {
  const _NextBlockCard({required this.block, required this.onPressed});
  final WorkoutRunnerBlock block;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Material(
    key: const ValueKey<String>('workout_runner_next_exercise'),
    color: WorkoutRunnerStyle.panel(context),
    borderRadius: BorderRadius.circular(AppRadius.xl),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: AppWorkoutRunnerTokens.nextExerciseIconSize,
              height: AppWorkoutRunnerTokens.nextExerciseIconSize,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                block.isSuperset
                    ? OutlinedSvgAssets.link
                    : OutlinedSvgAssets.arrowRight,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(
                  WorkoutRunnerStyle.accent(context),
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
                    block.isSuperset
                        ? '${AppStrings.upNext} · ${AppStrings.superset}'
                        : AppStrings.upNext,
                    style: WorkoutRunnerStyle.caption(context),
                  ),
                  AppWhiteSpace.hSm,
                  for (final member in block.members)
                    Text(
                      member.exerciseName,
                      style: WorkoutRunnerStyle.body(context),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RunnerActions extends StatelessWidget {
  const _RunnerActions({
    required this.canLog,
    required this.logging,
    required this.onLog,
    required this.onFinish,
  });
  final bool canLog;
  final bool logging;
  final VoidCallback onLog;
  final VoidCallback? onFinish;
  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const ValueKey<String>('workout_runner_bottom_actions'),
    color: context.colorScheme.surface,
    child: SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppWorkoutRunnerTokens.maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppWorkoutRunnerTokens.horizontalPadding,
              vertical: AppSpacing.controlGap,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final finish = FilledButton.tonal(
                  key: const ValueKey<String>('workout_runner_finish'),
                  onPressed: onFinish,
                  style: FilledButton.styleFrom(
                    foregroundColor: context.colorScheme.onSurface,
                    backgroundColor: context.colorScheme.surfaceContainerHigh,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(
                      AppWorkoutRunnerTokens.actionBarButtonHeight,
                    ),
                    textStyle: WorkoutRunnerStyle.label(
                      context,
                    ).copyWith(inherit: false),
                  ),
                  child: const Text(AppStrings.finish),
                );
                final log = FilledButton(
                  key: const ValueKey<String>('workout_runner_log_set'),
                  onPressed: canLog && !logging ? onLog : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: WorkoutRunnerStyle.actionFill(context),
                    foregroundColor: WorkoutRunnerStyle.actionForeground(
                      context,
                    ),
                    minimumSize: const Size.fromHeight(
                      AppWorkoutRunnerTokens.actionBarButtonHeight,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    textStyle: WorkoutRunnerStyle.label(
                      context,
                    ).copyWith(inherit: false),
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (logging) ...[
                        SizedBox(
                          width: AppSizing.iconSm,
                          height: AppSizing.iconSm,
                          child: CircularProgressIndicator(
                            color: WorkoutRunnerStyle.actionForeground(context),
                            strokeWidth: AppSizing.strokeWidth,
                            semanticsLabel: AppStrings.loading,
                          ),
                        ),
                        AppWhiteSpace.wSm,
                      ],
                      const Flexible(
                        child: Text(
                          AppStrings.logSet,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
                final largeText =
                    MediaQuery.textScalerOf(context).scale(AppFontSizes.sm) >
                    AppFontSizes.sm *
                        AppWorkoutRunnerTokens.largeTextBreakpoint;
                return largeText
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [log, AppWhiteSpace.hXs, finish],
                      )
                    : Row(
                        children: [
                          Expanded(flex: 2, child: log),
                          AppWhiteSpace.wSm,
                          Expanded(child: finish),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

abstract final class _NextBlock {
  static WorkoutRunnerBlock? find(
    WorkoutRunnerSessionViewData session,
    WorkoutRunnerBlock current,
  ) {
    final currentIds = current.members.map((member) => member.id).toSet();
    for (final exercise in session.exercises) {
      if (currentIds.contains(exercise.id)) continue;
      if (exercise.sets.any((set) => !set.completed && !set.skipped)) {
        return const WorkoutRunnerBlockResolver().blockFor(
          session.exercises,
          exercise,
        );
      }
    }
    return null;
  }
}
