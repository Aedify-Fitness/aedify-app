import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/presentation/widgets/archive_item_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/delete_item_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/saved_workout_list_tile.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class SavedWorkoutLibraryScreen extends ConsumerWidget {
  const SavedWorkoutLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(
      AppProviders.savedWorkoutLibraryControllerProvider,
    );

    return Scaffold(
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          message: AppStrings.workoutLibraryLoadFailed,
          onRetry: () => ref
              .read(AppProviders.savedWorkoutLibraryControllerProvider.notifier)
              .reload(),
        ),
        data: (state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorCode != null) {
            return _ErrorView(
              message:
                  state.errorMessage ?? AppStrings.workoutLibraryLoadFailed,
              onRetry: () => ref
                  .read(
                    AppProviders.savedWorkoutLibraryControllerProvider.notifier,
                  )
                  .reload(),
            );
          }
          if (state.isEmpty) {
            return const _EmptyView();
          }
          return _ListView(
            items: state.items,
            onStart: (id) {
              context.pushNamed(
                AppRoutes.workoutRunnerSavedWorkout().name,
                pathParameters: {'id': id},
              );
            },
            onArchive: (id) {
              showDialog(
                context: context,
                builder: (_) => ArchiveItemDialog(
                  title: AppStrings.archiveSavedWorkoutConfirm,
                  message: '',
                  confirmLabel: AppStrings.archiveWorkout,
                  onConfirm: () {
                    ref
                        .read(
                          AppProviders
                              .savedWorkoutLibraryControllerProvider
                              .notifier,
                        )
                        .archiveWorkout(id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.savedWorkoutArchived),
                      ),
                    );
                  },
                ),
              );
            },
            onDelete: (id) {
              showDialog(
                context: context,
                builder: (_) => DeleteItemDialog(
                  title: AppStrings.deleteSavedWorkoutConfirm,
                  message: '',
                  onConfirm: () {
                    ref
                        .read(
                          AppProviders
                              .savedWorkoutLibraryControllerProvider
                              .notifier,
                        )
                        .deleteWorkout(id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.workoutDeleted)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.exclamationCircle,
            width: AppSizing.iconLg,
            height: AppSizing.iconLg,
            colorFilter: ColorFilter.mode(
              context.colorScheme.error,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.clipboardDocumentList,
            width: AppSizing.iconLg,
            height: AppSizing.iconLg,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.noSavedWorkoutsYet,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.noSavedWorkoutsYetHint,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({
    required this.items,
    required this.onStart,
    required this.onArchive,
    required this.onDelete,
  });

  final List items;
  final void Function(String id) onStart;
  final void Function(String id) onArchive;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return SavedWorkoutListTile(
          item: item,
          onTap: () => context.pushNamed(
            AppRoutes.workoutBuilderEdit().name,
            pathParameters: {'id': item.id},
          ),
          onStart: () => onStart(item.id),
          onArchive: () => onArchive(item.id),
          onDelete: () => onDelete(item.id),
        );
      },
    );
  }
}
