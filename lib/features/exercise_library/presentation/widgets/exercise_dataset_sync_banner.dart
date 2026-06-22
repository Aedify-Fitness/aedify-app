import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_dataset_sync_status_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseDatasetSyncBanner extends ConsumerWidget {
  const ExerciseDatasetSyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(
      AppProviders.exerciseDatasetSyncControllerProvider,
    );

    return syncState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        if (state.isSynced && !state.isOffline) {
          return const SizedBox.shrink();
        }

        if (state.isLoading) {
          return ExerciseDatasetSyncStatusCard(
            title: AppStrings.exerciseLibrarySyncInProgress,
            message: _progressMessage(state),
            isLoading: true,
          );
        }

        if (state.needsInitialSync && !state.isOffline) {
          return ExerciseDatasetSyncStatusCard(
            title: AppStrings.exerciseLibrarySyncRequired,
            message: AppStrings.exerciseLibraryTapToDownload,
            actionLabel: AppStrings.download,
            onAction: () => ref
                .read(
                  AppProviders.exerciseDatasetSyncControllerProvider.notifier,
                )
                .initialize(),
          );
        }

        if (state.phase == ExerciseDatasetSyncPhase.unavailableOffline) {
          return ExerciseDatasetSyncStatusCard(
            title: AppStrings.exerciseLibrarySyncRequired,
            message: AppStrings.exerciseLibrarySyncUnavailableOffline,
          );
        }

        if (state.phase == ExerciseDatasetSyncPhase.updateRequired) {
          return ExerciseDatasetSyncStatusCard(
            title: AppStrings.exerciseLibraryUpdateRequired,
            message:
                state.failure?.message ??
                AppStrings.exerciseLibraryUpdateRequired,
            actionLabel: AppStrings.exerciseLibraryRetry,
            onAction: state.failure?.retryable == true
                ? () => ref
                      .read(
                        AppProviders
                            .exerciseDatasetSyncControllerProvider
                            .notifier,
                      )
                      .retry()
                : null,
          );
        }

        if (state.hasFailure) {
          return ExerciseDatasetSyncStatusCard(
            title: AppStrings.exerciseLibrarySyncFailed,
            message:
                state.failure?.message ?? AppStrings.exerciseLibrarySyncFailed,
            actionLabel: state.failure?.retryable == true
                ? AppStrings.exerciseLibraryRetry
                : null,
            onAction: state.failure?.retryable == true
                ? () => ref
                      .read(
                        AppProviders
                            .exerciseDatasetSyncControllerProvider
                            .notifier,
                      )
                      .retry()
                : null,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String _progressMessage(ExerciseDatasetSyncState state) {
    switch (state.phase) {
      case ExerciseDatasetSyncPhase.checkingManifest:
        return 'Checking for updates...';
      case ExerciseDatasetSyncPhase.downloading:
        return 'Downloading...';
      case ExerciseDatasetSyncPhase.importing:
        return 'Importing exercises...';
      default:
        return '';
    }
  }
}
