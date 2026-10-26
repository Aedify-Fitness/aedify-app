import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_detail_style.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_step_audio_button.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps the exercise steps readable alongside their local audio controls.
class ExerciseDetailInstructions extends ConsumerWidget {
  const ExerciseDetailInstructions({super.key, required this.detail});

  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioStates = ref.watch(
      AppProviders.exerciseStepAudioControllerProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.instructions,
          style: ExerciseDetailStyle.heading(context),
        ),
        AppWhiteSpace.hSm,
        if (detail.steps.isEmpty)
          Text(
            AppStrings.customExerciseNoSteps,
            style: ExerciseDetailStyle.body(
              context,
            ).copyWith(color: context.colorScheme.onSurfaceVariant),
          )
        else ...[
          Text(
            AppStrings.exerciseInstructionsAudioHint,
            style: ExerciseDetailStyle.small(context),
          ),
          AppWhiteSpace.hMd,
          ...detail.steps.asMap().entries.map((entry) {
            final stepState =
                audioStates['${detail.id}:${entry.key}'] ??
                const ExerciseStepAudioState.idle();

            return _InstructionStep(
              exerciseId: detail.id,
              stepIndex: entry.key,
              text: entry.value,
              isActive: stepState.isBusy,
            );
          }),
        ],
      ],
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.exerciseId,
    required this.stepIndex,
    required this.text,
    required this.isActive,
  });

  final int exerciseId;
  final int stepIndex;
  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      selected: isActive,
      child: AnimatedContainer(
        key: ValueKey<String>(
          'exercise_step_${stepIndex}_${isActive ? 'active' : 'idle'}',
        ),
        duration: ExerciseDetailStyle.motionDuration(context),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.controlGap,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isActive ? ExerciseDetailStyle.panel(context) : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isActive && MediaQuery.highContrastOf(context)
              ? Border.all(color: ExerciseDetailStyle.accent(context))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.exerciseStepLabel(stepIndex + 1),
                    style: ExerciseDetailStyle.label(context).copyWith(
                      color: isActive
                          ? ExerciseDetailStyle.accent(context)
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppWhiteSpace.hSm,
                  Text(text, style: ExerciseDetailStyle.body(context)),
                ],
              ),
            ),
            AppWhiteSpace.wControlGap,
            ExerciseStepAudioButton(
              exerciseId: exerciseId,
              stepIndex: stepIndex,
              text: text,
            ),
          ],
        ),
      ),
    );
  }
}
