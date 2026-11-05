import 'package:aedify/features/progress_media/application/progress_gallery_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/presentation/progress_photo_components.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

abstract final class ProgressGalleryLabels {
  static String type(ProgressMediaType type) => switch (type) {
    ProgressMediaType.photoSet => AppStrings.progressPhotos,
    ProgressMediaType.video => AppStrings.exerciseVideos,
    ProgressMediaType.both => AppStrings.progressMixed,
  };
  static String date(DateTime date) =>
      DateFormat.yMMMd().format(date.toLocal());
  static String session(ProgressMediaSession session) =>
      AppStrings.progressSessionLabel(
        date(session.capturedAt),
        DateFormat.jm().format(session.capturedAt.toLocal()),
        type(session.mediaType),
      );
}

class ProgressGalleryBody extends StatelessWidget {
  const ProgressGalleryBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.marginMobile,
      vertical: AppSpacing.lg,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppProgressPhotoTokens.maxWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

class ProgressGalleryMessage extends StatelessWidget {
  const ProgressGalleryMessage({super.key, required this.message, this.retry});
  final String message;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.lg,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        if (retry != null)
          TextButton(onPressed: retry, child: const Text(AppStrings.retry)),
      ],
    ),
  );
}

class ProgressSavedImage extends ConsumerWidget {
  const ProgressSavedImage({super.key, required this.item});
  final ProgressMediaItem item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ProgressGalleryProviders.imageProvider(item);
    final image = ref.watch(provider);
    final label = item.file.type == ProgressMediaItemType.video
        ? AppStrings.progressVideoTitle
        : ProgressPhotoLabels.pose(item.file.pose);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ColoredBox(
            color: context.colorScheme.surfaceContainerLow,
            child: AspectRatio(
              aspectRatio: AppProgressPhotoTokens.previewAspectRatio,
              child: image.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => ProgressGalleryMessage(
                  message: AppErrorStrings.progressSavedPreview,
                  retry: () => ref.invalidate(provider),
                ),
                data: (bytes) => bytes == null
                    ? ProgressGalleryMessage(
                        message: AppStrings.progressPhotoPreviewUnavailable,
                        retry: () => ref.invalidate(provider),
                      )
                    : Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                        semanticLabel: label,
                        errorBuilder: (_, _, _) => ProgressGalleryMessage(
                          message: AppErrorStrings.progressSavedPreview,
                          retry: () => ref.invalidate(provider),
                        ),
                      ),
              ),
            ),
          ),
        ),
        if (!item.isFileAvailable)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(AppErrorStrings.progressSavedMissing),
          ),
      ],
    );
  }
}

/// Side-by-side at normal phone widths; stacked when large text needs more room.
class ProgressComparisonColumns extends StatelessWidget {
  const ProgressComparisonColumns({
    super.key,
    required this.first,
    required this.second,
    this.stacked = false,
  });
  final Widget first;
  final Widget second;
  final bool stacked;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (stacked ||
          constraints.maxWidth < AppProgressGalleryTokens.comparisonMinWidth ||
          MediaQuery.textScalerOf(context).scale(AppFontSizes.md) /
                  AppFontSizes.md >=
              AppProgressPhotoTokens.singleColumnTextScale) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            first,
            const SizedBox(height: AppSpacing.lg),
            second,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: second),
        ],
      );
    },
  );
}

class ProgressSessionBadges extends StatelessWidget {
  const ProgressSessionBadges({super.key, required this.session});
  final ProgressMediaSession session;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.xs,
    children: [
      if (session.isBaseline)
        const Chip(label: Text(AppStrings.progressBaseline)),
      if (session.mediaType != ProgressMediaType.video)
        Chip(
          label: Text(
            session.isCompletePoseSet
                ? AppStrings.progressComplete
                : AppStrings.progressIncomplete,
          ),
        ),
    ],
  );
}

class ProgressGalleryHeading extends StatelessWidget {
  const ProgressGalleryHeading(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Text(
      text,
      style: AppTextStyles.headlineMd.copyWith(
        color: context.colorScheme.onSurface,
      ),
    ),
  );
}
