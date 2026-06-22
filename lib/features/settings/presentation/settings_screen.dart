import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_dataset_status_tile.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(
      AppProviders.exerciseDatasetSyncControllerProvider,
    );

    final libraryVersion = syncState.whenOrNull(
      data: (state) => state.libraryVersion,
    );
    final schemaVersion = syncState.whenOrNull(data: (_) => null);
    final exerciseCount = syncState.whenOrNull(data: (_) => null);
    final syncStatusLabel = syncState.when(
      loading: () => AppStrings.exerciseLibrarySyncing,
      error: (_, _) => AppStrings.exerciseLibrarySyncFailedLabel,
      data: (state) {
        if (state.isSynced) return AppStrings.exerciseLibrarySynced;
        if (state.needsInitialSync) {
          return AppStrings.exerciseLibraryNeverSynced;
        }
        if (state.hasFailure) return AppStrings.exerciseLibrarySyncFailedLabel;
        return AppStrings.exerciseLibrarySyncing;
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        children: [
          ExerciseDatasetStatusTile(
            libraryVersion: libraryVersion,
            schemaVersion: schemaVersion,
            exerciseCount: exerciseCount,
            syncStatusLabel: syncStatusLabel,
          ),
        ],
      ),
    );
  }
}
