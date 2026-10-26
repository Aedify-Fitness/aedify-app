import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_detail_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        return _AudioIconControl(
          asset: OutlinedSvgAssets.speakerWave,
          label: AppStrings.playStepAudio,
          foreground: ExerciseDetailStyle.accent(context),
          background: colorScheme.surfaceContainerLow,
          onPressed: () {
            ref
                .read(AppProviders.exerciseStepAudioControllerProvider.notifier)
                .playStep(
                  exerciseId: exerciseId,
                  stepIndex: stepIndex,
                  text: text,
                );
          },
        );

      case ExerciseStepAudioPhase.checkingCache:
      case ExerciseStepAudioPhase.generating:
        return Semantics(
          label: AppStrings.audioGenerating,
          liveRegion: true,
          child: SizedBox(
            width: AppExerciseDetailTokens.controlSize,
            height: AppExerciseDetailTokens.controlSize,
            child: Center(
              child: SizedBox(
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizing.strokeWidth,
                  color: ExerciseDetailStyle.accent(context),
                ),
              ),
            ),
          ),
        );

      case ExerciseStepAudioPhase.speaking:
        return _AudioIconControl(
          asset: OutlinedSvgAssets.stop,
          label: AppStrings.stopStepAudio,
          foreground: ExerciseDetailStyle.actionForeground(context),
          background: ExerciseDetailStyle.actionFill(context),
          onPressed: () {
            ref
                .read(AppProviders.exerciseStepAudioControllerProvider.notifier)
                .stop(exerciseId, stepIndex);
          },
        );

      case ExerciseStepAudioPhase.unavailable:
        return _AudioIconControl(
          asset: OutlinedSvgAssets.speakerXMark,
          label: AppStrings.audioUnavailable,
          foreground: colorScheme.onSurfaceVariant,
          background: colorScheme.surfaceContainerLow,
          onPressed: null,
        );

      case ExerciseStepAudioPhase.failed:
        final errorMessage =
            stepState.errorMessage ?? AppStrings.audioUnavailable;
        return _AudioIconControl(
          asset: OutlinedSvgAssets.speakerXMark,
          label: errorMessage,
          foreground: colorScheme.error,
          background: colorScheme.errorContainer,
          onPressed: () {
            ref
                .read(AppProviders.exerciseStepAudioControllerProvider.notifier)
                .playStep(
                  exerciseId: exerciseId,
                  stepIndex: stepIndex,
                  text: text,
                );
          },
        );
    }
  }
}

class _AudioIconControl extends StatelessWidget {
  const _AudioIconControl({
    required this.asset,
    required this.label,
    required this.foreground,
    required this.background,
    required this.onPressed,
  });

  final String asset;
  final String label;
  final Color foreground;
  final Color background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppExerciseDetailTokens.controlSize,
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background,
          foregroundColor: foreground,
          disabledForegroundColor: foreground,
          shape: const CircleBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.controlGap,
            vertical: AppSpacing.controlGap,
          ),
        ),
        icon: SvgPicture.asset(
          asset,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
        ),
      ),
    );
  }
}
