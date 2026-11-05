import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_photo_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

abstract final class ProgressPhotoLabels {
  static const poses = [
    ProgressMediaPose.front,
    ProgressMediaPose.back,
    ProgressMediaPose.leftSide,
    ProgressMediaPose.rightSide,
  ];
  static String pose(ProgressMediaPose pose) => switch (pose) {
    ProgressMediaPose.front => AppStrings.bodymapFront,
    ProgressMediaPose.back => AppStrings.bodymapBack,
    ProgressMediaPose.leftSide => AppStrings.progressPhotoLeft,
    ProgressMediaPose.rightSide => AppStrings.progressPhotoRight,
    _ => AppStrings.progressPhotoRecovered,
  };
}

class ProgressPhotoIcon extends StatelessWidget {
  const ProgressPhotoIcon(this.asset, {super.key});
  final String asset;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: AppSizing.iconMd,
    height: AppSizing.iconMd,
    colorFilter: ColorFilter.mode(
      context.colorScheme.onSurfaceVariant,
      BlendMode.srcIn,
    ),
  );
}

class ProgressPhotoPanel extends StatelessWidget {
  const ProgressPhotoPanel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: child,
  );
}

class ProgressPhotoSlot extends StatelessWidget {
  const ProgressPhotoSlot({
    super.key,
    required this.pose,
    required this.photo,
    required this.busy,
    required this.onChoose,
    required this.onRemove,
  });
  final ProgressMediaPose pose;
  final PreparedProgressPhoto? photo;
  final bool busy;
  final VoidCallback onChoose;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    final label = ProgressPhotoLabels.pose(pose);
    final action = photo == null
        ? AppStrings.progressPhotoAdd
        : AppStrings.progressPhotoReplace;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: AppStrings.progressPhotoAction(action, label),
          image: photo != null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Material(
              color: context.colorScheme.surfaceContainerLow,
              child: InkWell(
                key: ValueKey('photo_choose_${pose.name}'),
                onTap: busy ? null : onChoose,
                child: AspectRatio(
                  aspectRatio: AppProgressPhotoTokens.previewAspectRatio,
                  child: photo == null
                      ? const Center(
                          child: ProgressPhotoIcon(OutlinedSvgAssets.photo),
                        )
                      : Image.memory(
                          photo!.preview,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) => const Center(
                            child: Text(
                              AppStrings.progressPhotoPreviewUnavailable,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: context.theme.brightness == Brightness.dark
              ? AppTextStylesDark.labelMd
              : AppTextStyles.labelMd,
        ),
        Wrap(
          spacing: AppSpacing.xs,
          children: [
            TextButton(
              key: ValueKey('photo_action_${pose.name}'),
              onPressed: busy ? null : onChoose,
              child: Text(
                action,
                semanticsLabel: AppStrings.progressPhotoAction(action, label),
              ),
            ),
            if (photo != null)
              IconButton(
                key: ValueKey('photo_remove_${pose.name}'),
                tooltip: AppStrings.progressPhotoAction(
                  AppStrings.progressPhotoRemove,
                  label,
                ),
                onPressed: busy ? null : onRemove,
                icon: const ProgressPhotoIcon(OutlinedSvgAssets.trash),
              ),
          ],
        ),
      ],
    );
  }
}

abstract final class ProgressPhotoSourceSheet {
  static Future<ProgressMediaSource?> show(
    BuildContext context, {
    bool recovered = false,
    bool video = false,
  }) => showModalBottomSheet<ProgressMediaSource>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              video
                  ? (recovered
                        ? AppStrings.progressVideoRecoveredSource
                        : AppStrings.progressVideoSource)
                  : recovered
                  ? AppStrings.progressPhotoRecoveredSource
                  : AppStrings.progressPhotoSource,
              style: AppTextStyles.headlineMd,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final source in [
              ProgressMediaSource.camera,
              ProgressMediaSource.gallery,
            ])
              TextButton.icon(
                key: ValueKey('photo_source_${source.name}'),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    AppProgressPhotoTokens.controlSize,
                  ),
                ),
                onPressed: () => context.pop(source),
                icon: ProgressPhotoIcon(
                  source == ProgressMediaSource.camera
                      ? OutlinedSvgAssets.camera
                      : OutlinedSvgAssets.photo,
                ),
                label: Text(
                  source == ProgressMediaSource.camera
                      ? AppStrings.progressPhotoCamera
                      : AppStrings.progressPhotoGallery,
                ),
              ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    ),
  );
}
