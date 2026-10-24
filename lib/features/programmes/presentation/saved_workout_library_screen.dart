import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/presentation/widgets/archive_item_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/delete_item_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/saved_workout_list_tile.dart';
import 'package:aedify/shared/components/create_action_fab.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/saved_workout_library_style.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/app_bottom_navigation_scope.dart';

class SavedWorkoutLibraryScreen extends ConsumerWidget {
  const SavedWorkoutLibraryScreen({super.key, this.embedded = false});

  final bool embedded;

  double _bottomClearance(BuildContext context) => embedded
      ? AppBottomNavigationScope.contentClearance(
          context,
          fallback: AppSpacing.lg,
        )
      : AppBottomNavigationScope.contentClearanceWithFloatingActionButton(
          context,
          fallback: AppSpacing.xxl + AppSpacing.xl,
        );

  void _create(BuildContext context) =>
      context.pushNamed(AppRoutes.workoutBuilderCreate().name);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(
      AppProviders.savedWorkoutLibraryControllerProvider,
    );

    final clearance = _bottomClearance(context);
    return Scaffold(
      key: const Key('saved_workout_library_screen'),
      backgroundColor: context.colorScheme.surface,
      floatingActionButton: embedded
          ? null
          : Padding(
              padding: EdgeInsets.only(
                bottom: AppBottomNavigationScope.floatingActionButtonLift(
                  context,
                ),
              ),
              child: CreateActionFab(onPressed: () => _create(context)),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLibraryTokens.maxContentWidth,
          ),
          child: asyncState.when(
            loading: () =>
                _LibraryMessage(bottomClearance: clearance, loading: true),
            error: (error, stack) => _LibraryMessage(
              bottomClearance: clearance,
              error: true,
              heading: AppStrings.workoutLibraryLoadFailed,
              icon: OutlinedSvgAssets.exclamationCircle,
              onRetry: () => ref
                  .read(
                    AppProviders.savedWorkoutLibraryControllerProvider.notifier,
                  )
                  .reload(),
            ),
            data: (state) {
              if (state.isLoading) {
                return _LibraryMessage(
                  bottomClearance: clearance,
                  loading: true,
                );
              }
              if (state.errorCode != null) {
                return _LibraryMessage(
                  bottomClearance: clearance,
                  error: true,
                  icon: OutlinedSvgAssets.exclamationCircle,
                  heading:
                      state.errorMessage ?? AppStrings.workoutLibraryLoadFailed,
                  onRetry: () => ref
                      .read(
                        AppProviders
                            .savedWorkoutLibraryControllerProvider
                            .notifier,
                      )
                      .reload(),
                );
              }
              if (state.isEmpty) {
                return _LibraryMessage(
                  bottomClearance: clearance,
                  heading: AppStrings.noSavedWorkoutsYet,
                  message: AppStrings.noSavedWorkoutsYetHint,
                  icon: OutlinedSvgAssets.clipboardDocumentList,
                );
              }
              final activeSessionAsync = ref.watch(
                AppProviders.activeWorkoutSessionProvider,
              );
              final activeSession = activeSessionAsync.asData?.value;

              return _ListView(
                items: state.items,
                bottomClearance: clearance,
                hasActiveSession:
                    activeSessionAsync.isLoading ||
                    activeSessionAsync.hasError ||
                    activeSession != null,
                activeSessionWorkoutId: activeSession?.savedWorkoutId,
                onTap: (id) {
                  context.pushNamed(
                    AppRoutes.workoutDetail().name,
                    pathParameters: {'workoutId': id},
                  );
                },
                onPlay: (id) {
                  context.pushNamed(
                    AppRoutes.workoutRunnerSavedWorkout().name,
                    pathParameters: {'id': id},
                  );
                },
                onResume: () {
                  context.pushNamed(AppRoutes.workoutRunnerActive().name);
                },
                onEdit: (id) {
                  context.pushNamed(
                    AppRoutes.workoutBuilderEdit().name,
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
                          const SnackBar(
                            content: Text(AppStrings.workoutDeleted),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LibraryMessage extends StatelessWidget {
  const _LibraryMessage({
    required this.bottomClearance,
    this.loading = false,
    this.error = false,
    this.heading,
    this.message,
    this.icon,
    this.onRetry,
  });

  final double bottomClearance;
  final bool loading;
  final bool error;
  final String? heading;
  final String? message;
  final String? icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final minHeight =
          (constraints.maxHeight - AppSpacing.xl - bottomClearance).clamp(
            0.0,
            double.infinity,
          );
      return SingleChildScrollView(
        key: const Key('saved_workout_library_message'),
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.xl,
          bottom: bottomClearance,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Center(
            child: Semantics(
              liveRegion: error,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (loading)
                    const CircularProgressIndicator(
                      semanticsLabel: AppStrings.loading,
                    )
                  else if (icon != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        icon!,
                        width: AppSizing.iconLg,
                        height: AppSizing.iconLg,
                        colorFilter: ColorFilter.mode(
                          error
                              ? context.colorScheme.error
                              : SavedWorkoutLibraryStyle.accent(context),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  if (heading != null) ...[
                    AppWhiteSpace.hMd,
                    Text(
                      heading!,
                      textAlign: TextAlign.center,
                      style: SavedWorkoutLibraryStyle.heading(context),
                    ),
                  ],
                  if (message != null) ...[
                    AppWhiteSpace.hSm,
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: SavedWorkoutLibraryStyle.body(context),
                    ),
                  ],
                  if (onRetry != null) ...[
                    AppWhiteSpace.hMd,
                    FilledButton(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppLibraryTokens.controlSize,
                        ),
                        foregroundColor:
                            SavedWorkoutLibraryStyle.actionForeground(context),
                        backgroundColor: SavedWorkoutLibraryStyle.actionFill(
                          context,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.buttonVertical,
                        ),
                        textStyle: SavedWorkoutLibraryStyle.label(
                          context,
                        ).copyWith(inherit: false),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ListView extends StatelessWidget {
  const _ListView({
    required this.items,
    required this.bottomClearance,
    required this.hasActiveSession,
    required this.activeSessionWorkoutId,
    required this.onTap,
    required this.onPlay,
    required this.onResume,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final List<SavedWorkoutListItem> items;
  final double bottomClearance;
  final bool hasActiveSession;
  final String? activeSessionWorkoutId;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onPlay;
  final VoidCallback onResume;
  final ValueChanged<String> onEdit;
  final ValueChanged<String> onArchive;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) => ListView.builder(
    key: const Key('saved_workout_library_list'),
    padding: EdgeInsets.only(
      left: AppSpacing.md,
      top: AppSpacing.md,
      right: AppSpacing.md,
      bottom: bottomClearance,
    ),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return Padding(
        padding: EdgeInsets.only(
          bottom: index < items.length - 1 ? AppSpacing.md : 0,
        ),
        child: SavedWorkoutListTile(
          item: item,
          hasActiveSession: hasActiveSession,
          activeSessionWorkoutId: activeSessionWorkoutId,
          onTap: () => onTap(item.id),
          onPlay: () => onPlay(item.id),
          onResume: onResume,
          onEdit: () => onEdit(item.id),
          onArchive: () => onArchive(item.id),
          onDelete: () => onDelete(item.id),
        ),
      );
    },
  );
}
