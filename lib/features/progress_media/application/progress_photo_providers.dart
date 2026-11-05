import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/application/progress_photo_controller.dart';
import 'package:aedify/features/progress_media/data/progress_photo_file_service.dart';
import 'package:aedify/features/progress_media/data/progress_photo_picker.dart';
import 'package:aedify/features/progress_media/domain/progress_photo_draft.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

abstract final class ProgressPhotoProviders {
  static final idProvider = Provider<String Function()>(
    (ref) => const Uuid().v4,
  );
  static final pickerProvider = Provider<ProgressPhotoPicker>(
    (ref) => ImagePickerProgressPhotoPicker(
      files: ref.watch(AppProviders.localFileStoreProvider),
    ),
  );
  static final filesProvider = Provider<ProgressPhotoFileService>(
    (ref) => ProgressPhotoFileService(
      files: ref.watch(AppProviders.localFileStoreProvider),
      repository: ref.watch(ProgressMediaProviders.repositoryProvider),
      newId: ref.watch(idProvider),
    ),
  );
  static final unitsProvider = FutureProvider.autoDispose<PreferredUnit>((
    ref,
  ) async {
    try {
      return (await ref
                  .read(AppProviders.profileRepositoryProvider)
                  .getProfile())
              ?.preferredUnits ??
          PreferredUnit.metric;
    } catch (_) {
      throw ProgressPhotoFailure.storage;
    }
  }, retry: (_, _) => null);
  static final recoveryProvider =
      AsyncNotifierProvider<ProgressPhotoRecovery, RecoveredProgressPhoto>(
        ProgressPhotoRecovery.new,
      );
  static final controllerProvider =
      AsyncNotifierProvider.autoDispose<
        ProgressPhotoController,
        ProgressPhotoState
      >(ProgressPhotoController.new, retry: (_, _) => null);
}

/// Started once by the app; recovered media always awaits local review.
class ProgressPhotoRecovery extends AsyncNotifier<RecoveredProgressPhoto> {
  @override
  Future<RecoveredProgressPhoto> build() async {
    try {
      return await ref.read(ProgressPhotoProviders.pickerProvider).recover();
    } catch (_) {
      return const RecoveredProgressPhoto(
        failure: ProgressPhotoFailure.invalid,
      );
    }
  }

  void consume() => state = const AsyncData(RecoveredProgressPhoto());
}
