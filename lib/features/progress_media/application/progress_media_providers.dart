import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/progress_media/data/drift_progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_media_repository.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feature-owned injection with explicit async loading/error/empty/data states.
abstract final class ProgressMediaProviders {
  static final clockProvider = Provider<DateTime Function()>(
    (ref) => DateTime.now,
  );
  static final repositoryProvider = Provider<ProgressMediaRepository>(
    (ref) => DriftProgressMediaRepository(
      database: ref.watch(AppProviders.appDatabaseProvider),
      fileStore: ref.watch(AppProviders.localFileStoreProvider),
      now: ref.watch(clockProvider),
    ),
  );
  static final timelineProvider =
      StreamProvider.autoDispose<List<ProgressMediaSession>>(
        (ref) => ref.watch(repositoryProvider).watchTimeline(),
        retry: (_, _) => null,
      );
}
