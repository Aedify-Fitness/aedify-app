import 'package:aedify/features/progress_media/application/progress_gallery_providers.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_components.dart';
import 'package:aedify/features/progress_media/presentation/progress_photo_components.dart';
import 'package:aedify/features/progress_media/presentation/progress_video_panel.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProgressSessionScreen extends ConsumerStatefulWidget {
  const ProgressSessionScreen({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<ProgressSessionScreen> createState() =>
      _ProgressSessionScreenState();
}

class _ProgressSessionScreenState extends ConsumerState<ProgressSessionScreen> {
  bool _busy = false;
  String? _message;
  Future<void> _baseline() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final failure = await ref
        .read(ProgressGalleryProviders.actionsProvider)
        .setBaseline(widget.sessionId);
    if (mounted) {
      setState(() {
        _busy = false;
        _message = failure?.message ?? AppStrings.progressBaselineSaved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ProgressGalleryProviders.detailProvider(widget.sessionId);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.progressPhotoDetails),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => ref.invalidate(provider),
            child: const Text(AppStrings.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ref
            .watch(provider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: ProgressGalleryMessage(
                  message: AppErrorStrings.progressMediaUnavailable,
                  retry: () => ref.invalidate(provider),
                ),
              ),
              data: (details) => details == null
                  ? ProgressGalleryMessage(
                      message: AppErrorStrings.progressSavedMissing,
                      retry: () => ref.invalidate(provider),
                    )
                  : ProgressGalleryBody(
                      children: [
                        ProgressGalleryHeading(
                          ProgressGalleryLabels.session(details.session),
                        ),
                        ProgressSessionBadges(session: details.session),
                        if (_message != null)
                          Semantics(liveRegion: true, child: Text(_message!)),
                        if (!details.session.isBaseline)
                          OutlinedButton(
                            onPressed: _busy ? null : _baseline,
                            child: const Text(AppStrings.progressSetBaseline),
                          ),
                        const SizedBox(height: AppSpacing.md),
                        _ProgressSnapshot(details: details),
                        const ProgressGalleryHeading(AppStrings.notes),
                        Text(details.session.notes ?? ''),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => showDialog<void>(
                                  context: context,
                                  builder: (_) => _ProgressNotesDialog(
                                    initial: details.session.notes ?? '',
                                    sessionId: widget.sessionId,
                                  ),
                                ),
                          child: const Text(AppStrings.progressEditNotes),
                        ),
                        for (final pose in ProgressPhotoLabels.poses) ...[
                          if (details.items.any(
                            (i) =>
                                i.file.type == ProgressMediaItemType.photo &&
                                i.file.pose == pose,
                          )) ...[
                            ProgressGalleryHeading(
                              ProgressPhotoLabels.pose(pose),
                            ),
                            ProgressSavedImage(
                              item: details.items.firstWhere(
                                (i) =>
                                    i.file.type ==
                                        ProgressMediaItemType.photo &&
                                    i.file.pose == pose,
                              ),
                            ),
                          ],
                        ],
                        for (final video in details.items.where(
                          (i) => i.file.type == ProgressMediaItemType.video,
                        ))
                          ProgressSavedVideo(item: video),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(AppStrings.progressLocal),
                      ],
                    ),
            ),
      ),
    );
  }
}

class ProgressSavedVideo extends StatefulWidget {
  const ProgressSavedVideo({super.key, required this.item});
  final ProgressMediaItem item;
  @override
  State<ProgressSavedVideo> createState() => _ProgressSavedVideoState();
}

class _ProgressSavedVideoState extends State<ProgressSavedVideo> {
  bool _show = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const ProgressGalleryHeading(AppStrings.progressVideoTitle),
      if (widget.item.file.durationSeconds != null)
        Text(
          AppStrings.progressVideoDuration(widget.item.file.durationSeconds!),
        ),
      if (!_show || !widget.item.isFileAvailable)
        ProgressSavedImage(item: widget.item),
      if (widget.item.isFileAvailable) ...[
        if (_show)
          ProgressSavedVideoPlayer(path: widget.item.file.relativePath)
        else
          OutlinedButton(
            key: ValueKey('saved_video_${widget.item.file.id}'),
            onPressed: () => setState(() => _show = true),
            child: const Text(AppStrings.progressPlayVideo),
          ),
        const Text(AppStrings.progressSavedVideoMuted),
      ],
    ],
  );
}

class _ProgressNotesDialog extends ConsumerStatefulWidget {
  const _ProgressNotesDialog({required this.initial, required this.sessionId});
  final String initial;
  final String sessionId;
  @override
  ConsumerState<_ProgressNotesDialog> createState() =>
      _ProgressNotesDialogState();
}

class _ProgressNotesDialogState extends ConsumerState<_ProgressNotesDialog> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initial,
  );
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final failure = await ref
        .read(ProgressGalleryProviders.actionsProvider)
        .updateNotes(widget.sessionId, _text.text);
    if (!mounted) return;
    if (failure == null) {
      context.pop();
      return;
    }
    setState(() {
      _busy = false;
      _error = failure.message;
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      scrollable: true,
      title: const Text(AppStrings.progressEditNotes),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const ValueKey('saved_notes'),
            controller: _text,
            enabled: !_busy,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(labelText: AppStrings.notes),
          ),
          if (_error != null) Text(_error!),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => context.pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: const Text(AppStrings.save),
        ),
      ],
    ),
  );
}

class _ProgressSnapshot extends ConsumerWidget {
  const _ProgressSnapshot({required this.details});
  final ProgressMediaSessionDetails details;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = details.measurements;
    final provider = ProgressPhotoProviders.unitsProvider;
    return ref
        .watch(provider)
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => ProgressGalleryMessage(
            message: AppErrorStrings.progressMediaUnavailable,
            retry: () => ref.invalidate(provider),
          ),
          data: (unit) {
            final measurements = <(String, double?)>[
              (AppStrings.progressWaist, snapshot?.waistCm),
              (AppStrings.filterChest, snapshot?.chestCm),
              (AppStrings.progressHips, snapshot?.hipsCm),
              (AppStrings.progressLeftArm, snapshot?.leftArmCm),
              (AppStrings.progressRightArm, snapshot?.rightArmCm),
              (AppStrings.progressLeftThigh, snapshot?.leftThighCm),
              (AppStrings.progressRightThigh, snapshot?.rightThighCm),
            ];
            final weight =
                details.session.bodyweightKg ?? snapshot?.bodyweightKg;
            if (weight == null &&
                measurements.every((entry) => entry.$2 == null)) {
              return const SizedBox.shrink();
            }
            return ProgressPhotoPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ProgressGalleryHeading(
                    AppStrings.progressMeasurementSnapshot,
                  ),
                  if (weight != null)
                    Text(
                      AppStrings.progressMeasurement(
                        AppStrings.bodyweight,
                        unit.toDisplayWeight(weight).toStringAsFixed(1),
                        unit.weightUnit,
                      ),
                    ),
                  for (final entry in measurements)
                    if (entry.$2 != null)
                      Text(
                        AppStrings.progressMeasurement(
                          entry.$1,
                          unit.toDisplayHeight(entry.$2!).toStringAsFixed(1),
                          unit.heightUnit,
                        ),
                      ),
                ],
              ),
            );
          },
        );
  }
}
