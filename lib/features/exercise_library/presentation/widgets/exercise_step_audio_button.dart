import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseStepAudioButton extends ConsumerWidget {
  const ExerciseStepAudioButton({
    super.key,
    required this.exerciseId,
    required this.stepIndex,
    required this.text,
  });

  final int exerciseId;
  final int stepIndex;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '$exerciseId:$stepIndex';
    final stateMap = ref.watch(
      AppProviders.exerciseStepAudioControllerProvider,
    );
    final stepState = stateMap[key] ?? const ExerciseStepAudioState.idle();

    final colorScheme = context.colorScheme;

    switch (stepState.phase) {
      case ExerciseStepAudioPhase.idle:
        return Tooltip(
          message: AppStrings.playStepAudio,
          child: AppIconButton(
            asset: OutlinedSvgAssets.play,
            semanticLabel: AppStrings.playStepAudio,
            iconSize: AppSizing.iconSm,
            color: colorScheme.onSurfaceVariant,
            backgroundColor: colorScheme.surfaceContainerLow,
            onPressed: () {
              ref
                  .read(
                    AppProviders.exerciseStepAudioControllerProvider.notifier,
                  )
                  .playStep(
                    exerciseId: exerciseId,
                    stepIndex: stepIndex,
                    text: text,
                  );
            },
          ),
        );

      case ExerciseStepAudioPhase.checkingCache:
      case ExerciseStepAudioPhase.generating:
        return Semantics(
          label: AppStrings.audioGenerating,
          child: SizedBox(
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            child: Center(
              child: SizedBox(
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizing.strokeWidth,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );

      case ExerciseStepAudioPhase.speaking:
        return Tooltip(
          message: AppStrings.stopStepAudio,
          child: AppIconButton(
            asset: OutlinedSvgAssets.stop,
            semanticLabel: AppStrings.stopStepAudio,
            iconSize: AppSizing.iconSm,
            color: colorScheme.onSecondaryContainer,
            backgroundColor: colorScheme.secondaryContainer,
            onPressed: () {
              ref
                  .read(
                    AppProviders.exerciseStepAudioControllerProvider.notifier,
                  )
                  .stop(exerciseId, stepIndex);
            },
          ),
        );

      case ExerciseStepAudioPhase.unavailable:
        return Tooltip(
          message: AppStrings.audioUnavailable,
          child: AppIconButton(
            asset: OutlinedSvgAssets.speakerXMark,
            semanticLabel: AppStrings.audioUnavailable,
            iconSize: AppSizing.iconSm,
            color: colorScheme.outline,
            backgroundColor: colorScheme.surfaceContainerLow,
            onPressed: null,
          ),
        );

      case ExerciseStepAudioPhase.failed:
        final errorMessage =
            stepState.errorMessage ?? AppStrings.audioUnavailable;
        return Tooltip(
          message: errorMessage,
          child: AppIconButton(
            asset: OutlinedSvgAssets.speakerXMark,
            semanticLabel: errorMessage,
            iconSize: AppSizing.iconSm,
            color: colorScheme.error,
            backgroundColor: colorScheme.errorContainer,
            onPressed: () {
              ref
                  .read(
                    AppProviders.exerciseStepAudioControllerProvider.notifier,
                  )
                  .playStep(
                    exerciseId: exerciseId,
                    stepIndex: stepIndex,
                    text: text,
                  );
            },
          ),
        );
    }
  }
}
