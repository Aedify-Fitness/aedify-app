import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_colors.dart';
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
        return IconButton(
          icon: SvgPicture.asset(
            OutlinedSvgAssets.play,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(
              colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            ref
                .read(AppProviders.exerciseStepAudioControllerProvider.notifier)
                .playStep(
                  exerciseId: exerciseId,
                  stepIndex: stepIndex,
                  text: text,
                );
          },
          tooltip: AppStrings.playStepAudio,
        );

      case ExerciseStepAudioPhase.checkingCache:
      case ExerciseStepAudioPhase.generating:
        return Container(
          width: AppSpacing.lg,
          height: AppSpacing.lg,
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: CircularProgressIndicator(
            strokeWidth: AppSizing.divider * 2,
            color: colorScheme.onSurfaceVariant,
          ),
        );

      case ExerciseStepAudioPhase.speaking:
        return IconButton(
          icon: SvgPicture.asset(
            OutlinedSvgAssets.stop,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
          ),
          onPressed: () {
            ref
                .read(AppProviders.exerciseStepAudioControllerProvider.notifier)
                .stop(exerciseId, stepIndex);
          },
          tooltip: AppStrings.stopStepAudio,
        );

      case ExerciseStepAudioPhase.unavailable:
        return IconButton(
          icon: SvgPicture.asset(
            OutlinedSvgAssets.speakerXMark,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(
              colorScheme.brightness == Brightness.light
                  ? AedifyLightColors.surfaceVariantFaded
                  : AedifyDarkColors.surfaceVariantFaded,
              BlendMode.srcIn,
            ),
          ),
          onPressed: null,
          tooltip: AppStrings.audioUnavailable,
        );

      case ExerciseStepAudioPhase.failed:
        return IconButton(
          icon: SvgPicture.asset(
            OutlinedSvgAssets.speakerXMark,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(colorScheme.error, BlendMode.srcIn),
          ),
          onPressed: () {
            ref
                .read(AppProviders.exerciseStepAudioControllerProvider.notifier)
                .playStep(
                  exerciseId: exerciseId,
                  stepIndex: stepIndex,
                  text: text,
                );
          },
          tooltip: stepState.errorMessage ?? AppStrings.audioUnavailable,
        );
    }
  }
}
