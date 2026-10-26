import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_policy.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/features/workout_execution/application/weight_suggestion_providers.dart';
import 'package:aedify/features/workout_execution/domain/weight_suggestion.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/weight_suggestion_strings.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/shared/components/app_bottom_sheet.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_button_styles.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A small, opt-in hint above the existing grid; no new logging columns.
class WorkoutRunnerWeightSuggestion extends ConsumerStatefulWidget {
  const WorkoutRunnerWeightSuggestion({
    super.key,
    required this.session,
    required this.exercise,
    required this.set,
    required this.enabled,
    required this.onUse,
  });
  final WorkoutRunnerSessionViewData session;
  final WorkoutRunnerExerciseItem exercise;
  final WorkoutRunnerSetItem set;
  final bool enabled;
  final ValueChanged<WeightSuggestion> onUse;
  @override
  ConsumerState<WorkoutRunnerWeightSuggestion> createState() =>
      _WorkoutRunnerWeightSuggestionState();
}

class _WorkoutRunnerWeightSuggestionState
    extends ConsumerState<WorkoutRunnerWeightSuggestion> {
  WeightSuggestionTarget? _target;

  Future<void> _chooseTarget(WeightSuggestionTarget? current) async {
    final result = await AppBottomSheet.show<WeightSuggestionTarget>(
      context,
      title: WeightSuggestionStrings.estimateWeight,
      child: _TargetForm(
        initial: current ?? const WeightSuggestionTarget(5, 8),
      ),
    );
    if (result != null && mounted && widget.enabled) {
      if (WeightSuggestionTarget.fromSet(widget.set) == null) {
        ref
            .read(
              WeightSuggestionProviders.targetsProvider(
                widget.session.sessionId,
              ).notifier,
            )
            .setTarget(widget.exercise.id, result);
      }
      setState(() => _target = result);
    }
  }

  Future<void> _explain(WeightSuggestion suggestion) =>
      AppBottomSheet.show<void>(
        context,
        title: WeightSuggestionStrings.title,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  WeightSuggestionStrings.suggested(suggestion.weightKg),
                  style: WorkoutRunnerStyle.heading(context),
                ),
                AppWhiteSpace.hSm,
                Text(
                  WeightSuggestionStrings.target(suggestion.target),
                  style: WorkoutRunnerStyle.label(context),
                ),
                AppWhiteSpace.hMd,
                Text(
                  WeightSuggestionStrings.reference(suggestion),
                  style: WorkoutRunnerStyle.body(context),
                ),
                AppWhiteSpace.hMd,
                Text(
                  WeightSuggestionStrings.calculation(suggestion),
                  style: WorkoutRunnerStyle.body(context),
                ),
                AppWhiteSpace.hMd,
                Text(
                  WeightSuggestionStrings.method,
                  style: WorkoutRunnerStyle.small(context),
                ),
                AppWhiteSpace.hSm,
                Text(
                  WeightSuggestionStrings.rounding,
                  style: WorkoutRunnerStyle.small(context),
                ),
                AppWhiteSpace.hMd,
                Text(
                  WeightSuggestionStrings.hint,
                  style: WorkoutRunnerStyle.body(context),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (WorkoutRunnerSetPolicy.loggingType(
              widget.set,
              snapshot: widget.exercise.loggingType,
            ) !=
            ExerciseLoggingType.repsWeight ||
        widget.set.completed ||
        widget.set.skipped ||
        widget.set.setType != SetType.working) {
      return const SizedBox.shrink();
    }
    final rememberedTarget = ref.watch(
      WeightSuggestionProviders.targetsProvider(widget.session.sessionId),
    )[widget.exercise.id];
    final result = ref.watch(
      WeightSuggestionProviders.viewProvider((
        session: widget.session,
        exercise: widget.exercise,
        set: widget.set,
        target:
            _target ??
            (WeightSuggestionTarget.fromSet(widget.set) == null
                ? rememberedTarget
                : null),
      )),
    );
    return result.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppErrorStrings.weightSuggestionUnavailable,
              style: WorkoutRunnerStyle.small(context),
            ),
            TextButton(
              onPressed: widget.enabled
                  ? () => ref.invalidate(
                      WeightSuggestionProviders.evidenceProvider(
                        widget.set.exerciseId,
                      ),
                    )
                  : null,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
      data: (data) {
        if (!data.supported) return const SizedBox.shrink();
        final suggestion = data.suggestion;
        return Container(
          key: const Key('runner_weight_suggestion'),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (data.target != null)
                Text(
                  WeightSuggestionStrings.setTarget(
                    widget.exercise.exerciseName,
                    widget.set.setIndex,
                    data.target!,
                  ),
                  style: WorkoutRunnerStyle.caption(context),
                ),
              Text(
                suggestion == null
                    ? data.target == null
                          ? WeightSuggestionStrings.enterTarget
                          : WeightSuggestionStrings.noHistory
                    : WeightSuggestionStrings.suggested(suggestion.weightKg),
                style: suggestion == null
                    ? WorkoutRunnerStyle.small(context)
                    : WorkoutRunnerStyle.label(context),
              ),
              if (suggestion != null && widget.set.actualWeightKg != null)
                Text(
                  WeightSuggestionStrings.existingWeight,
                  style: WorkoutRunnerStyle.small(context),
                ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  if (suggestion != null)
                    TextButton(
                      key: const Key('runner_use_suggested_weight'),
                      style: TextButton.styleFrom(
                        foregroundColor: WorkoutRunnerStyle.accent(context),
                        textStyle: WorkoutRunnerStyle.label(context),
                      ),
                      onPressed:
                          widget.enabled && widget.set.actualWeightKg == null
                          ? () => widget.onUse(suggestion)
                          : null,
                      child: const Text(WeightSuggestionStrings.useWeight),
                    ),
                  TextButton(
                    key: const Key('runner_choose_weight_target'),
                    style: TextButton.styleFrom(
                      foregroundColor: WorkoutRunnerStyle.accent(context),
                      textStyle: WorkoutRunnerStyle.label(context),
                    ),
                    onPressed: widget.enabled
                        ? () => _chooseTarget(data.target)
                        : null,
                    child: Text(
                      data.target == null
                          ? WeightSuggestionStrings.estimateWeight
                          : WeightSuggestionStrings.changeTarget,
                    ),
                  ),
                  if (suggestion != null)
                    IconButton(
                      key: const Key('runner_weight_suggestion_reason'),
                      tooltip: WeightSuggestionStrings.why,
                      onPressed: () => _explain(suggestion),
                      style: IconButton.styleFrom(
                        minimumSize: const Size.square(
                          AppWorkoutRunnerTokens.controlSize,
                        ),
                      ),
                      icon: SvgPicture.asset(
                        OutlinedSvgAssets.informationCircle,
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        colorFilter: ColorFilter.mode(
                          WorkoutRunnerStyle.accent(context),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TargetForm extends StatefulWidget {
  const _TargetForm({required this.initial});
  final WeightSuggestionTarget initial;
  @override
  State<_TargetForm> createState() => _TargetFormState();
}

class _TargetFormState extends State<_TargetForm> {
  late final _reps = TextEditingController(
    text: widget.initial.reps.toString(),
  );
  late final _rpe = TextEditingController(
    text: WeightSuggestionStrings.number(widget.initial.rpe),
  );
  String? _error;
  @override
  void dispose() {
    _reps.dispose();
    _rpe.dispose();
    super.dispose();
  }

  void _submit() {
    final reps = int.tryParse(_reps.text.trim());
    final rpe = double.tryParse(_rpe.text.trim());
    final target = reps == null || rpe == null
        ? null
        : WeightSuggestionTarget(reps, rpe);
    if (target == null || !target.valid) {
      setState(() => _error = AppErrorStrings.weightSuggestionTargetInvalid);
      return;
    }
    context.pop(target);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            WeightSuggestionStrings.noChange,
            style: WorkoutRunnerStyle.small(context),
          ),
          AppWhiteSpace.hMd,
          AppTextField(
            key: const Key('weight_estimate_target_reps'),
            controller: _reps,
            labelText: WeightSuggestionStrings.reps,
            keyboardType: TextInputType.number,
          ),
          AppWhiteSpace.hMd,
          AppTextField(
            key: const Key('weight_estimate_target_rpe'),
            controller: _rpe,
            labelText: WeightSuggestionStrings.rpe,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          if (_error != null) ...[
            AppWhiteSpace.hSm,
            Text(
              _error!,
              style: WorkoutRunnerStyle.small(
                context,
              ).copyWith(color: context.colorScheme.error),
            ),
          ],
          AppWhiteSpace.hMd,
          FilledButton(
            key: const Key('weight_estimate_calculate'),
            onPressed: _submit,
            style: AppButtonStyles.primary(
              context,
              minimumHeight: AppWorkoutRunnerTokens.controlSize,
            ),
            child: const Text(WeightSuggestionStrings.calculate),
          ),
        ],
      ),
    ),
  );
}
