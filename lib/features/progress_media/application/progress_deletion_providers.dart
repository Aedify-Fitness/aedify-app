import 'dart:async';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/application/progress_gallery_providers.dart';
import 'package:aedify/features/progress_media/application/progress_video_providers.dart';
import 'package:aedify/features/progress_media/application/progress_reminder_providers.dart';
import 'package:aedify/features/progress_media/data/progress_media_deletion_service.dart';
import 'package:aedify/features/progress_media/domain/progress_deletion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class ProgressDeletionProviders {
  static final serviceProvider = Provider<ProgressMediaDeletionService>(
    (ref) => ProgressMediaDeletionService(
      database: ref.watch(AppProviders.appDatabaseProvider),
      files: ref.watch(AppProviders.localFileStoreProvider),
      now: ref.watch(ProgressMediaProviders.clockProvider),
      activeDrafts: () =>
          ref.read(ProgressPhotoProviders.filesProvider).activeDraftSessionIds,
    ),
  );
  static final controllerProvider =
      AsyncNotifierProvider<ProgressDeletionController, ProgressCleanupStatus>(
        ProgressDeletionController.new,
        retry: (_, _) => null,
      );
}

class ProgressDeletionController extends AsyncNotifier<ProgressCleanupStatus> {
  bool _busy = false;
  @override
  Future<ProgressCleanupStatus> build() =>
      ref.read(ProgressDeletionProviders.serviceProvider).status();
  Future<ProgressCleanupStatus> recover() async {
    if (_busy) {
      return state.asData?.value ??
          const ProgressCleanupStatus(retryNeeded: true);
    }
    _busy = true;
    try {
      final result = await ref
          .read(ProgressDeletionProviders.serviceProvider)
          .recover();
      if (ref.mounted) state = AsyncData(result);
      return result;
    } catch (_) {
      if (ref.mounted) {
        state = const AsyncData(ProgressCleanupStatus(retryNeeded: true));
      }
      return const ProgressCleanupStatus(retryNeeded: true);
    } finally {
      _busy = false;
    }
  }

  Future<ProgressCleanupStatus> deleteSession(String id) => _delete(
    () => ref.read(ProgressDeletionProviders.serviceProvider).deleteSession(id),
  );
  Future<ProgressCleanupStatus> deleteItem(String sessionId, String itemId) =>
      _delete(
        () => ref
            .read(ProgressDeletionProviders.serviceProvider)
            .deleteItem(sessionId, itemId),
      );
  Future<ProgressCleanupStatus> deleteAll() => _delete(
    () => ref.read(ProgressDeletionProviders.serviceProvider).deleteAll(),
  );
  Future<ProgressCleanupStatus> _delete(
    Future<ProgressCleanupStatus> Function() action,
  ) async {
    if (_busy) throw ProgressDeletionFailure.unavailable;
    _busy = true;
    try {
      // Detach old readers/players before deleting their local files.
      ref.invalidate(ProgressVideoProviders.previewProvider);
      ref.invalidate(ProgressGalleryProviders.imageProvider);
      final result = await action();
      if (ref.mounted) {
        ref.invalidate(ProgressGalleryProviders.imageProvider);
        ref.invalidate(ProgressMediaProviders.timelineProvider);
        ref.invalidate(ProgressGalleryProviders.detailProvider);
        state = AsyncData(result);
        await ref
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
      }
      return result;
    } catch (_) {
      throw ProgressDeletionFailure.unavailable;
    } finally {
      _busy = false;
    }
  }
}
