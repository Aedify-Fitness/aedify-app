import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_controller.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_phase.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_state.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/cancel_workout_dialog.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/complete_workout_sheet.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/rest_timer_widget.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_error_banner.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_header.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_resume_banner.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutRunnerScreen extends ConsumerStatefulWidget {
  const WorkoutRunnerScreen.resume({super.key})
    : mode = WorkoutRunnerMode.resume,
      savedWorkoutId = null,
      programId = null,
      programWorkoutId = null;

  const WorkoutRunnerScreen.savedWorkout({
    super.key,
    required this.savedWorkoutId,
  }) : mode = WorkoutRunnerMode.savedWorkout,
       programId = null,
       programWorkoutId = null;

  const WorkoutRunnerScreen.programWorkout({
    super.key,
    required this.programId,
    required this.programWorkoutId,
  }) : mode = WorkoutRunnerMode.programWorkout,
       savedWorkoutId = null;

  final WorkoutRunnerMode mode;
  final String? savedWorkoutId;
  final String? programId;
  final String? programWorkoutId;

  @override
  ConsumerState<WorkoutRunnerScreen> createState() =>
      _WorkoutRunnerScreenState();
}

class _WorkoutRunnerScreenState extends ConsumerState<WorkoutRunnerScreen> {
  bool _showRestTimer = false;
  final _restSeconds = 90;

  @override
  Widget build(BuildContext context) {
    final arg = (
      mode: widget.mode,
      savedWorkoutId: widget.savedWorkoutId,
      programId: widget.programId,
      programWorkoutId: widget.programWorkoutId,
    );
    final stateAsync = ref.watch(
      AppProviders.workoutRunnerControllerProvider(arg),
    );

    return Scaffold(
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.workoutRunnerLoadFailed,
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(
                  AppProviders.workoutRunnerControllerProvider(arg),
                ),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
        data: (state) => _WorkoutRunnerBody(
          state: state,
          mode: widget.mode,
          savedWorkoutId: widget.savedWorkoutId,
          programId: widget.programId,
          programWorkoutId: widget.programWorkoutId,
          restSeconds: _restSeconds,
          showRestTimer: _showRestTimer,
          onSetLogged: () => setState(() => _showRestTimer = true),
          onDismissRestTimer: () => setState(() => _showRestTimer = false),
        ),
      ),
    );
  }
}

class _WorkoutRunnerBody extends ConsumerWidget {
  const _WorkoutRunnerBody({
    required this.state,
    required this.mode,
    required this.savedWorkoutId,
    required this.programId,
    required this.programWorkoutId,
    required this.restSeconds,
    required this.showRestTimer,
    required this.onSetLogged,
    required this.onDismissRestTimer,
  });

  final WorkoutRunnerState state;
  final WorkoutRunnerMode mode;
  final String? savedWorkoutId;
  final String? programId;
  final String? programWorkoutId;
  final int restSeconds;
  final bool showRestTimer;
  final VoidCallback onSetLogged;
  final VoidCallback onDismissRestTimer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.phase == WorkoutRunnerPhase.failure) {
      return WorkoutRunnerErrorBanner(
        message: state.errorMessage ?? AppStrings.workoutRunnerLoadFailed,
      );
    }
    if (state.phase == WorkoutRunnerPhase.blocked) {
      return WorkoutRunnerErrorBanner(
        message: state.errorMessage ?? AppStrings.noActiveWorkout,
      );
    }
    if (state.phase == WorkoutRunnerPhase.completed) {
      return Center(
        child: Text(
          AppStrings.workoutCompleted,
          style: context.textTheme.titleLarge,
        ),
      );
    }
    if (!state.hasSession && mode == WorkoutRunnerMode.resume) {
      return Center(
        child: Text(
          AppStrings.noActiveWorkout,
          style: context.textTheme.bodyLarge,
        ),
      );
    }
    if (state.hasRecoveredSession && state.phase == WorkoutRunnerPhase.ready) {
      final controller = ref.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: mode,
          savedWorkoutId: savedWorkoutId,
          programId: programId,
          programWorkoutId: programWorkoutId,
        )).notifier,
      );
      return WorkoutRunnerResumeBanner(
        onResume: () => controller.resumeRecoveredSession(),
        onDiscard: () => controller.discardRecoveredSession(),
      );
    }
    if (state.session == null) {
      return Center(
        child: Text(
          AppStrings.noActiveWorkout,
          style: context.textTheme.bodyLarge,
        ),
      );
    }

    final session = state.session!;
    final controller = ref.read(
      AppProviders.workoutRunnerControllerProvider((
        mode: mode,
        savedWorkoutId: savedWorkoutId,
        programId: programId,
        programWorkoutId: programWorkoutId,
      )).notifier,
    );

    final currentExercise = _findFirstIncomplete(session);

    return Column(
      children: [
        WorkoutRunnerHeader(
          title: session.name,
          onComplete: () =>
              _showCompleteSheet(context, ref, session, controller),
          onCancel: () => _showCancelDialog(context, controller),
          isCompleting: state.isCompleting,
        ),
        if (state.phase == WorkoutRunnerPhase.paused)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            color: context.colorScheme.primaryContainer,
            child: Row(
              children: [
                Text(
                  AppStrings.workoutInterrupted,
                  style: context.textTheme.bodyMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => controller.continueWorkout(),
                  child: Text(AppStrings.continueWorkout),
                ),
              ],
            ),
          ),
        _InsightBanner(),
        if (currentExercise != null)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _ExerciseDetailView(
                exercise: currentExercise,
                controller: controller,
                onSetLogged: onSetLogged,
              ),
            ),
          )
        else
          Expanded(
            child: Center(
              child: Text(
                AppStrings.workoutCompleted,
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
        if (showRestTimer)
          RestTimerWidget(seconds: restSeconds, onDismiss: onDismissRestTimer),
        if (currentExercise != null)
          _BottomActions(
            exerciseId: currentExercise.exerciseId,
            substituteLabel: AppStrings.substitute,
            guideLabel: AppStrings.exerciseGuide,
          ),
      ],
    );
  }

  void _showCompleteSheet(
    BuildContext context,
    WidgetRef ref,
    WorkoutRunnerSessionViewData session,
    WorkoutRunnerController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => CompleteWorkoutSheet(
        session: session,
        onComplete: (draft) async {
          Navigator.of(context).pop();
          await controller.completeWorkout();
          ref.invalidate(
            AppProviders.workoutRunnerControllerProvider((
              mode: mode,
              savedWorkoutId: savedWorkoutId,
              programId: programId,
              programWorkoutId: programWorkoutId,
            )),
          );
          if (context.mounted) {
            context.pop();
          }
        },
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    WorkoutRunnerController controller,
  ) {
    showDialog(
      context: context,
      builder: (_) =>
          CancelWorkoutDialog(onConfirm: () => controller.cancelWorkout()),
    );
  }

  static WorkoutRunnerExerciseItem? _findFirstIncomplete(
    WorkoutRunnerSessionViewData session,
  ) {
    for (final ex in session.exercises) {
      for (final set in ex.sets) {
        if (!set.completed && !set.skipped) return ex;
      }
    }
    return null;
  }
}

class _InsightBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer.withAlpha(51),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.colorScheme.secondary.withAlpha(25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.colorScheme.secondary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: SvgPicture.asset(
              OutlinedSvgAssets.sparkles,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.insightForProgress,
                  style: context.textTheme.labelMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppStrings.insightPlaceholder,
                  style: context.textTheme.bodySmall?.copyWith(
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

class _ExerciseDetailView extends ConsumerWidget {
  const _ExerciseDetailView({
    required this.exercise,
    required this.controller,
    required this.onSetLogged,
  });

  final WorkoutRunnerExerciseItem exercise;
  final WorkoutRunnerController controller;
  final VoidCallback onSetLogged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      AppProviders.exerciseDetailControllerProvider(exercise.exerciseId),
    );
    final detail = detailAsync.asData?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(exercise.exerciseName, style: context.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        if (detail != null) ...[
          _VideoHero(videos: detail.videos),
          const SizedBox(height: AppSpacing.md),
          _MuscleFocusSection(muscles: detail.primaryMuscles),
          const SizedBox(height: AppSpacing.md),
          _StepsSection(steps: detail.steps),
          const SizedBox(height: AppSpacing.md),
        ],
        _SetTable(
          sets: exercise.sets,
          controller: controller,
          exercise: exercise,
          onSetLogged: onSetLogged,
        ),
      ],
    );
  }
}

class _VideoHero extends StatelessWidget {
  const _VideoHero({required this.videos});

  final List<ExerciseDetailVideoViewData> videos;

  @override
  Widget build(BuildContext context) {
    final hasVideo = videos.isNotEmpty;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceDim,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasVideo)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: SizedBox.expand(
                child: Center(
                  child: SvgPicture.asset(
                    OutlinedSvgAssets.playCircle,
                    width: AppSizing.iconXxl,
                    height: AppSizing.iconXxl,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSurfaceVariant.withAlpha(77),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            )
          else
            Center(
              child: SvgPicture.asset(
                OutlinedSvgAssets.playCircle,
                width: AppSizing.iconXxl,
                height: AppSizing.iconXxl,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurfaceVariant.withAlpha(77),
                  BlendMode.srcIn,
                ),
              ),
            ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colorScheme.surface.withAlpha(230),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withAlpha(30),
                  blurRadius: AppRadius.md,
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                OutlinedSvgAssets.play,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleFocusSection extends StatelessWidget {
  const _MuscleFocusSection({required this.muscles});

  final List<String> muscles;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.muscleFocus, style: context.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: muscles
                  .map(
                    (m) => Chip(
                      label: Text(m),
                      backgroundColor: context.colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: context.colorScheme.onSecondaryContainer,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.executionSteps,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: context.colorScheme.onSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetTable extends ConsumerStatefulWidget {
  const _SetTable({
    required this.sets,
    required this.controller,
    required this.exercise,
    required this.onSetLogged,
  });

  final List<WorkoutRunnerSetItem> sets;
  final WorkoutRunnerController controller;
  final WorkoutRunnerExerciseItem exercise;
  final VoidCallback onSetLogged;

  @override
  ConsumerState<_SetTable> createState() => _SetTableState();
}

class _SetTableState extends ConsumerState<_SetTable> {
  int _activeSetIndex = 0;

  @override
  void initState() {
    super.initState();
    _findActive();
  }

  void _findActive() {
    for (var i = 0; i < widget.sets.length; i++) {
      if (!widget.sets[i].completed && !widget.sets[i].skipped) {
        _activeSetIndex = i;
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                SizedBox(width: 32, child: Center(child: Text('#'))),
                Expanded(child: Text(AppStrings.previous)),
                SizedBox(width: 80, child: Text(AppStrings.weightKg)),
                SizedBox(width: 60, child: Text(AppStrings.reps)),
              ],
            ),
          ),
          ...widget.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            final isActive = index == _activeSetIndex;
            final isCompleted = set.completed;
            final isSkipped = set.skipped;
            final previousLabel = set.prescribedWeightKg != null
                ? '${set.prescribedWeightKg!.toStringAsFixed(set.prescribedWeightKg! == set.prescribedWeightKg!.truncateToDouble() ? 0 : 1)}kg \u00d7 ${set.prescribedRepsMin ?? '—'}'
                : '—';
            final actualWeight = set.actualWeightKg;
            final actualReps = set.actualReps;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? context.colorScheme.surfaceContainerHighest
                    : isCompleted
                    ? context.colorScheme.primaryContainer.withAlpha(77)
                    : isSkipped
                    ? context.colorScheme.surfaceContainerHighest.withAlpha(128)
                    : null,
                border: isActive
                    ? Border.all(color: context.colorScheme.secondary, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: isActive
                          ? Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: context.colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: context.colorScheme.onSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              '${index + 1}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      isCompleted && actualWeight != null
                          ? '${actualWeight.toStringAsFixed(actualWeight == actualWeight.truncateToDouble() ? 0 : 1)}kg \u00d7 ${actualReps ?? '—'}'
                          : previousLabel,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: isActive
                        ? _EditableField(
                            initialValue: actualWeight != null
                                ? (actualWeight ==
                                          actualWeight.truncateToDouble()
                                      ? actualWeight.toInt().toString()
                                      : actualWeight.toString())
                                : '',
                            onChanged: (value) {
                              widget.controller.updateSet(
                                exerciseId: widget.exercise.id,
                                setId: set.id,
                                updatedSet:
                                    _WorkoutRunnerSetMutations.copyWithActuals(
                                      set,
                                      weightKg: double.tryParse(value),
                                    ),
                              );
                            },
                          )
                        : Text(
                            actualWeight != null
                                ? (actualWeight ==
                                          actualWeight.truncateToDouble()
                                      ? actualWeight.toInt().toString()
                                      : actualWeight.toString())
                                : '—',
                            style: context.textTheme.bodyMedium,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  SizedBox(
                    width: 60,
                    child: isActive
                        ? _EditableField(
                            initialValue: actualReps?.toString() ?? '',
                            onChanged: (value) {
                              widget.controller.updateSet(
                                exerciseId: widget.exercise.id,
                                setId: set.id,
                                updatedSet:
                                    _WorkoutRunnerSetMutations.copyWithActuals(
                                      set,
                                      reps: int.tryParse(value),
                                    ),
                              );
                            },
                          )
                        : Text(
                            actualReps?.toString() ?? '—',
                            style: context.textTheme.bodyMedium,
                          ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final activeSet = widget.sets[_activeSetIndex];
                  final s = activeSet;
                  widget.controller.toggleSetCompleted(
                    exerciseId: widget.exercise.id,
                    setId: s.id,
                    completed: true,
                  );
                  setState(() {
                    _activeSetIndex++;
                  });
                  widget.onSetLogged();
                },
                icon: SvgPicture.asset(
                  OutlinedSvgAssets.checkCircle,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.onSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                label: Text('${AppStrings.logSet} ${_activeSetIndex + 1}'),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.secondary,
                  foregroundColor: context.colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _WorkoutRunnerSetMutations {
  _WorkoutRunnerSetMutations._();

  static WorkoutRunnerSetItem copyWithActuals(
    WorkoutRunnerSetItem set, {
    double? weightKg,
    int? reps,
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
      prescribedWeightKg: set.prescribedWeightKg,
      prescribedRpeMin: set.prescribedRpeMin,
      prescribedRpeMax: set.prescribedRpeMax,
      actualReps: reps ?? set.actualReps,
      actualWeightKg: weightKg ?? set.actualWeightKg,
      actualDurationSeconds: set.actualDurationSeconds,
      actualDistanceMeters: set.actualDistanceMeters,
      actualRpe: set.actualRpe,
      actualRir: set.actualRir,
      notes: set.notes,
    );
  }
}

class _EditableField extends StatefulWidget {
  const _EditableField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text &&
        widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: widget.onChanged,
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.exerciseId,
    required this.substituteLabel,
    required this.guideLabel,
  });

  final int exerciseId;
  final String substituteLabel;
  final String guideLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.comingSoon)),
                );
              },
              icon: SvgPicture.asset(
                OutlinedSvgAssets.arrowsRightLeft,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
              ),
              label: Text(substituteLabel),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: () {
                context.pushNamed(
                  AppRoutes.exerciseDetail().name,
                  pathParameters: {'id': exerciseId.toString()},
                );
              },
              icon: SvgPicture.asset(
                OutlinedSvgAssets.questionMarkCircle,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
              ),
              label: Text(guideLabel),
            ),
          ),
        ],
      ),
    );
  }
}
