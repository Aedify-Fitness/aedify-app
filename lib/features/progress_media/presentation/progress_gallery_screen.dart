import 'package:aedify/features/progress_media/application/progress_gallery_providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_gallery.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_components.dart';
import 'package:aedify/features/progress_media/presentation/progress_photo_components.dart';
import 'package:aedify/features/progress_media/presentation/progress_reminder_screen.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProgressGalleryScreen extends ConsumerStatefulWidget {
  const ProgressGalleryScreen({super.key});
  @override
  ConsumerState<ProgressGalleryScreen> createState() =>
      _ProgressGalleryScreenState();
}

class _ProgressGalleryScreenState extends ConsumerState<ProgressGalleryScreen> {
  ProgressMediaType? _type;
  ProgressMediaPose? _pose;
  DateTimeRange? _range;
  ProgressGalleryFilter _filter = const ProgressGalleryFilter();
  void _update() => setState(
    () => _filter = ProgressGalleryFilter(
      type: _type,
      pose: _pose,
      from: _range?.start,
      through: _range?.end,
    ),
  );
  Future<void> _dates(List<ProgressMediaSession> sessions) async {
    final days = sessions.map((s) => s.capturedAt.toLocal()).toList()..sort();
    final range = await showDateRangePicker(
      context: context,
      firstDate: days.first,
      lastDate: days.last,
      initialDateRange: _range,
    );
    if (!mounted || range == null) return;
    _range = range;
    _update();
  }

  @override
  Widget build(BuildContext context) {
    final timeline = ref.watch(ProgressMediaProviders.timelineProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.progressMedia),
        actions: [
          IconButton(
            key: const ValueKey('progress_storage'),
            tooltip: AppStrings.progressStorage,
            onPressed: () =>
                context.pushNamed(AppRoutes.progressStorage().name),
            icon: const ProgressPhotoIcon(OutlinedSvgAssets.circleStack),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: timeline.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: ProgressGalleryMessage(
              message: AppErrorStrings.progressMediaUnavailable,
              retry: () =>
                  ref.invalidate(ProgressMediaProviders.timelineProvider),
            ),
          ),
          data: (sessions) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppProgressPhotoTokens.maxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProgressGalleryHeading(
                            sessions.isEmpty
                                ? AppStrings.progressEmpty
                                : AppStrings.progressTimeline,
                          ),
                          Text(
                            sessions.isEmpty
                                ? AppStrings.progressEmptyHint
                                : AppStrings.progressLocal,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            key: const ValueKey('progress_new'),
                            onPressed: () => context.pushNamed(
                              AppRoutes.progressCapture().name,
                            ),
                            child: const Text(AppStrings.progressNewSession),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton(
                            key: const ValueKey('progress_compare'),
                            onPressed: sessions.length < 2
                                ? null
                                : () => context.pushNamed(
                                    AppRoutes.progressCompare().name,
                                  ),
                            child: const Text(AppStrings.progressCompare),
                          ),
                          if (sessions.length == 1)
                            const Text(AppStrings.progressCompareNeedsTwo),
                          if (sessions.isNotEmpty) ...[
                            const ProgressReminderSummary(),
                            const SizedBox(height: AppSpacing.lg),
                            ExpansionTile(
                              title: const Text(AppStrings.filters),
                              childrenPadding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              children: [
                                DropdownButtonFormField<ProgressMediaType>(
                                  key: ValueKey('type_$_type'),
                                  initialValue: _type,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: AppStrings.progressMediaType,
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text(AppStrings.filterAll),
                                    ),
                                    for (final type in ProgressMediaType.values)
                                      DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          ProgressGalleryLabels.type(type),
                                        ),
                                      ),
                                  ],
                                  onChanged: (v) {
                                    _type = v;
                                    _update();
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                DropdownButtonFormField<ProgressMediaPose>(
                                  key: ValueKey('pose_$_pose'),
                                  initialValue: _pose,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: AppStrings.progressPose,
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text(AppStrings.filterAll),
                                    ),
                                    for (final pose
                                        in ProgressPhotoLabels.poses)
                                      DropdownMenuItem(
                                        value: pose,
                                        child: Text(
                                          ProgressPhotoLabels.pose(pose),
                                        ),
                                      ),
                                  ],
                                  onChanged: (v) {
                                    _pose = v;
                                    _update();
                                  },
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                TextButton(
                                  onPressed: () => _dates(sessions),
                                  child: Text(
                                    _range == null
                                        ? AppStrings.progressDateRange
                                        : AppStrings.progressDateRangeLabel(
                                            ProgressGalleryLabels.date(
                                              _range!.start,
                                            ),
                                            ProgressGalleryLabels.date(
                                              _range!.end,
                                            ),
                                          ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _type = null;
                                    _pose = null;
                                    _range = null;
                                    _update();
                                  },
                                  child: const Text(AppStrings.clearFilters),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (sessions.isNotEmpty) _ProgressTimeline(filter: _filter),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressTimeline extends ConsumerWidget {
  const _ProgressTimeline({required this.filter});
  final ProgressGalleryFilter filter;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(ProgressGalleryProviders.filteredProvider(filter))
      .when(
        loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => SliverToBoxAdapter(
          child: ProgressGalleryMessage(
            message: AppErrorStrings.progressMediaUnavailable,
            retry: () {
              ref.invalidate(ProgressMediaProviders.timelineProvider);
              ref.invalidate(ProgressGalleryProviders.filteredProvider(filter));
            },
          ),
        ),
        data: (sessions) => sessions.isEmpty
            ? const SliverToBoxAdapter(
                child: ProgressGalleryMessage(
                  message: AppStrings.progressNoMatches,
                ),
              )
            : SliverList.builder(
                itemCount: sessions.length,
                itemBuilder: (_, i) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppProgressPhotoTokens.maxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: AppSpacing.sm,
                      ),
                      child: _ProgressSessionCard(session: sessions[i]),
                    ),
                  ),
                ),
              ),
      );
}

class _ProgressSessionCard extends ConsumerWidget {
  const _ProgressSessionCard({required this.session});
  final ProgressMediaSession session;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(
      ProgressGalleryProviders.detailProvider(session.id),
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('progress_session_${session.id}'),
        onTap: () => context.pushNamed(
          AppRoutes.progressSession().name,
          pathParameters: {'id': session.id},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ProgressGalleryLabels.session(session)),
              ProgressSessionBadges(session: session),
              detail.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => TextButton(
                  onPressed: () => ref.invalidate(
                    ProgressGalleryProviders.detailProvider(session.id),
                  ),
                  child: const Text(AppStrings.retry),
                ),
                data: (value) {
                  final originals = value == null
                      ? <ProgressMediaItem>[]
                      : ProgressGalleryPolicy.originals(value);
                  final original = originals.firstOrNull;
                  if (original == null) {
                    return const Text(AppErrorStrings.progressSavedMissing);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProgressSavedImage(item: original),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final item in originals)
                            Text(
                              item.file.type == ProgressMediaItemType.video
                                  ? AppStrings.progressVideoTitle
                                  : ProgressPhotoLabels.pose(item.file.pose),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
