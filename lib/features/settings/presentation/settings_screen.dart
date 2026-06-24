import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_dataset_status_tile.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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
    final schemaVersion = syncState.whenOrNull(
      data: (state) => state.schemaVersion,
    );
    final exerciseCount = syncState.whenOrNull(
      data: (state) => state.exerciseCount,
    );
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
          ListTile(
            leading: SvgPicture.asset(
              OutlinedSvgAssets.user,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            title: const Text(AppStrings.profile),
            trailing: SvgPicture.asset(
              OutlinedSvgAssets.chevronRight,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            onTap: () => context.pushNamed(AppRoutes.profile().name),
          ),
          const Divider(),
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
