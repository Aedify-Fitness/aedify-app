import 'dart:async';
import 'dart:typed_data';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/data/progress_gallery_file_service.dart';
import 'package:aedify/features/progress_media/domain/progress_gallery.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class ProgressGalleryProviders {
  static final detailProvider = FutureProvider.autoDispose
      .family<ProgressMediaSessionDetails?, String>((ref, id) async {
        // Notes/baseline/deletion changes invalidate open details and comparisons.
        ref.watch(ProgressMediaProviders.timelineProvider);
        try {
          return await ref
              .watch(ProgressMediaProviders.repositoryProvider)
              .getSessionDetails(id);
        } catch (_) {
          throw ProgressMediaFailure.unavailable;
        }
      }, retry: (_, _) => null);
  static final filteredProvider = FutureProvider.autoDispose
      .family<List<ProgressMediaSession>, ProgressGalleryFilter>((
        ref,
        filter,
      ) async {
        final sessions = await ref.watch(
          ProgressMediaProviders.timelineProvider.future,
        );
        final matches = <ProgressMediaSession>[];
        for (final session in sessions) {
          if (!filter.matches(session)) continue;
          if (filter.pose != null) {
            final detail = await ref.watch(detailProvider(session.id).future);
            if (detail == null ||
                !detail.items.any(
                  (i) =>
                      i.file.type == ProgressMediaItemType.photo &&
                      i.file.pose == filter.pose,
                )) {
              continue;
            }
          }
          matches.add(session);
        }
        return List.unmodifiable(matches);
      }, retry: (_, _) => null);
  static final filesProvider = Provider<ProgressGalleryFileService>(
    (ref) => ProgressGalleryFileService(
      ref.watch(AppProviders.localFileStoreProvider),
    ),
  );
  static final imageProvider = FutureProvider.autoDispose
      .family<Uint8List?, ProgressMediaItem>((ref, item) async {
        final files = ref.watch(filesProvider);
        final bytes = await files.preview(item);
        if (bytes != null) {
          if (!ref.mounted) {
            await files.evict(bytes);
            return null;
          }
          ref.onDispose(
            () => unawaited(files.evict(bytes).catchError((Object _) {})),
          );
        }
        return bytes;
      }, retry: (_, _) => null);
  static final actionsProvider = Provider<ProgressGalleryActions>(
    (ref) => ProgressGalleryActions(ref),
  );
}

/// Persistence actions return fixed failures while preserving the displayed input.
class ProgressGalleryActions {
  ProgressGalleryActions(this._ref);
  final Ref _ref;
  Future<ProgressMediaFailure?> setBaseline(String id) => _run(
    () => _ref.read(ProgressMediaProviders.repositoryProvider).setBaseline(id),
  );
  Future<ProgressMediaFailure?> updateNotes(String id, String notes) => _run(
    () => _ref
        .read(ProgressMediaProviders.repositoryProvider)
        .updateNotes(id, notes),
  );
  Future<ProgressMediaFailure?> _run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } catch (_) {
      return ProgressMediaFailure.unavailable;
    }
  }
}
