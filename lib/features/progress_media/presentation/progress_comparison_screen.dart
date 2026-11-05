import 'package:aedify/features/progress_media/application/progress_gallery_providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_gallery.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_components.dart';
import 'package:aedify/features/progress_media/presentation/progress_photo_components.dart';
import 'package:aedify/features/progress_media/presentation/progress_session_screen.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressComparisonScreen extends ConsumerStatefulWidget {
  const ProgressComparisonScreen({super.key});
  @override
  ConsumerState<ProgressComparisonScreen> createState() =>
      _ProgressComparisonScreenState();
}

class _ProgressComparisonScreenState
    extends ConsumerState<ProgressComparisonScreen> {
  ProgressComparisonMode _mode = ProgressComparisonMode.baselineLatest;
  String? _first;
  String? _second;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.progressCompare)),
    body: SafeArea(
      top: false,
      child: ref
          .watch(ProgressMediaProviders.timelineProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: ProgressGalleryMessage(
                message: AppErrorStrings.progressMediaUnavailable,
                retry: () =>
                    ref.invalidate(ProgressMediaProviders.timelineProvider),
              ),
            ),
            data: (sessions) {
              if (sessions.length < 2) {
                return const ProgressGalleryMessage(
                  message: AppStrings.progressCompareNeedsTwo,
                );
              }
              final first = sessions.any((s) => s.id == _first)
                  ? _first
                  : sessions[1].id;
              final second = sessions.any((s) => s.id == _second)
                  ? _second
                  : sessions.first.id;
              final pair = ProgressComparisonPolicy.select(
                sessions,
                _mode,
                first: first,
                second: second,
              );
              return ProgressGalleryBody(
                children: [
                  const Text(AppStrings.progressCompareHint),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final mode in ProgressComparisonMode.values)
                        ChoiceChip(
                          key: ValueKey('compare_${mode.name}'),
                          label: Text(switch (mode) {
                            ProgressComparisonMode.baselineLatest =>
                              AppStrings.progressBaselineLatest,
                            ProgressComparisonMode.previousLatest =>
                              AppStrings.progressPreviousLatest,
                            ProgressComparisonMode.anyTwo =>
                              AppStrings.progressAnyTwo,
                          }),
                          selected: _mode == mode,
                          onSelected: (_) => setState(() => _mode = mode),
                        ),
                    ],
                  ),
                  if (_mode == ProgressComparisonMode.anyTwo) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ProgressSessionSelector(
                      key: ValueKey('first_$first'),
                      label: AppStrings.progressFirstSession,
                      value: first!,
                      sessions: sessions,
                      onChanged: (v) => setState(() => _first = v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProgressSessionSelector(
                      key: ValueKey('second_$second'),
                      label: AppStrings.progressSecondSession,
                      value: second!,
                      sessions: sessions,
                      onChanged: (v) => setState(() => _second = v),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  if (pair == null)
                    const ProgressGalleryMessage(
                      message: AppStrings.progressNoPair,
                    )
                  else
                    _ProgressComparedMedia(
                      key: ValueKey(pair),
                      first: pair.first,
                      second: pair.second,
                    ),
                ],
              );
            },
          ),
    ),
  );
}

class _ProgressSessionSelector extends StatelessWidget {
  const _ProgressSessionSelector({
    super.key,
    required this.label,
    required this.value,
    required this.sessions,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<ProgressMediaSession> sessions;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final session in sessions)
        DropdownMenuItem(
          value: session.id,
          child: Text(
            ProgressGalleryLabels.session(session),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ],
    onChanged: onChanged,
  );
}

class _ProgressComparedMedia extends ConsumerWidget {
  const _ProgressComparedMedia({
    super.key,
    required this.first,
    required this.second,
  });
  final String first;
  final String second;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(ProgressGalleryProviders.detailProvider(first));
    final b = ref.watch(ProgressGalleryProviders.detailProvider(second));
    if (a.isLoading || b.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (a.hasError || b.hasError) {
      return ProgressGalleryMessage(
        message: AppErrorStrings.progressMediaUnavailable,
        retry: () {
          ref.invalidate(ProgressGalleryProviders.detailProvider(first));
          ref.invalidate(ProgressGalleryProviders.detailProvider(second));
        },
      );
    }
    final firstDetails = a.asData?.value;
    final secondDetails = b.asData?.value;
    if (firstDetails == null || secondDetails == null) {
      return const ProgressGalleryMessage(
        message: AppErrorStrings.progressSavedMissing,
      );
    }
    final pairs = ProgressComparisonPolicy.photoPairs(
      firstDetails,
      secondDetails,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pairs.isEmpty)
          const ProgressGalleryMessage(
            message: AppStrings.progressNoMatchingPose,
          ),
        for (final pair in pairs) ...[
          ProgressGalleryHeading(ProgressPhotoLabels.pose(pair.pose)),
          ProgressComparisonColumns(
            first: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(ProgressGalleryLabels.session(firstDetails.session)),
                const SizedBox(height: AppSpacing.sm),
                ProgressSavedImage(item: pair.first),
              ],
            ),
            second: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(ProgressGalleryLabels.session(secondDetails.session)),
                const SizedBox(height: AppSpacing.sm),
                ProgressSavedImage(item: pair.second),
              ],
            ),
          ),
        ],
        if (firstDetails.items.any(
              (i) => i.file.type == ProgressMediaItemType.video,
            ) ||
            secondDetails.items.any(
              (i) => i.file.type == ProgressMediaItemType.video,
            )) ...[
          const SizedBox(height: AppSpacing.lg),
          ProgressComparisonColumns(
            stacked: true,
            first: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(ProgressGalleryLabels.session(firstDetails.session)),
                for (final item in firstDetails.items.where(
                  (i) => i.file.type == ProgressMediaItemType.video,
                ))
                  ProgressSavedVideo(item: item),
              ],
            ),
            second: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(ProgressGalleryLabels.session(secondDetails.session)),
                for (final item in secondDetails.items.where(
                  (i) => i.file.type == ProgressMediaItemType.video,
                ))
                  ProgressSavedVideo(item: item),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
